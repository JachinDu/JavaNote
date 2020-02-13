# 线程池工作原理(ThreadPoolExecutor 源码简析)

## 0、为什么使用线程池

线程池提供了一种限制和管理资源（包括执行一个任务）。 每个线程池还维护一些基本统计信息，例如已完成任务的数量。

这里借用《Java 并发编程的艺术》提到的来说一下使用线程池的好处：

- **降低资源消耗。** 通过重复利用已创建的线程降低线程创建和销毁造成的消耗。
- **提高响应速度。** 当任务到达时，任务可以不需要的等到线程创建就能立即执行。
- **提高线程的可管理性。** 线程是稀缺资源，如果无限制的创建，不仅会消耗系统资源，还会降低系统的稳定性，使用线程池可以进行统一的分配，调优和监控。

------



先来张开门见山的流程图

![image-20191214211101669](../PicSource/image-20191214211101669.png)

------

![图片描述](../PicSource/5dd217480001b8bf20181042.png)

------



## 1. ThreadPoolExecutor源码简析



<img src="../PicSource/5dd21737000158ad06020618-20200213103900528.png" alt="图片描述-" style="zoom:50%;" />

### 1）一个记录线程池信息的变量ctl



```java
private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0));

private static final int COUNT_BITS = Integer.SIZE - 3;// 前三位表示线程池状态，后29位表示工作线程数
private static final int CAPACITY   = (1 << COUNT_BITS) - 1; // 能表示的最大线程数(29位)

// 线程池状态
private static final int RUNNING    = -1 << COUNT_BITS;
private static final int SHUTDOWN   =  0 << COUNT_BITS;
private static final int STOP       =  1 << COUNT_BITS;
private static final int TIDYING    =  2 << COUNT_BITS;
private static final int TERMINATED =  3 << COUNT_BITS;

// 获取线程池状态（～为按位取反）
private static int runStateOf(int c)     { return c & ~CAPACITY; }
// 获取工作线程数亩
private static int workerCountOf(int c)  { return c & CAPACITY; }
// 构造ctl（将线程池状态和工作线程数织入该变量）
private static int ctlOf(int rs, int wc) { return rs | wc; }
```

> 其中，关于线程池状态具体解释如下：
>
> - RUNNING：最正常的状态：接受新的任务，处理等待队列中的任务
> - SHUTDOWN：<font color='blue'>不接受新的任务提交，但是会继续处理等待队列中的任务</font>
> - STOP：不接受新的任务提交，<font color='blue'>不再处理等待队列中的任务，中断正在执行任务的线程</font>
> - TIDYING：所有的任务都销毁了，workCount 为 0。线程池的状态在转换为 TIDYING 状态时，会执行钩子方法 terminated()
> - TERMINATED：terminated() 方法结束后，线程池的状态就会变成这个



状态转移图如下：

![image-20191214213203276](../PicSource/image-20191214213203276.png)



**<font color = 'red'>后续各类方法都需要该变量来进行线程池状态和线程池工作线程数目的检查</font>**



### 2） 内部类Worker



核心代码截取：

```java
private final class Worker
    extends AbstractQueuedSynchronizer
    implements Runnable
{
    /**
     * This class will never be serialized, but we provide a
     * serialVersionUID to suppress a javac warning.
     */
    private static final long serialVersionUID = 6138294804551838833L;

    /** 真正执行任务的线程 */
    final Thread thread;
    /** 创建worker时初始化的任务，若没有可为null，自己去队列中取 */
    Runnable firstTask;
    /** 此线程完成的任务数 */
    volatile long completedTasks;

    Worker(Runnable firstTask) {
        setState(-1); // inhibit interrupts until runWorker
        this.firstTask = firstTask;
        this.thread = getThreadFactory().newThread(this);
    }

    public void run() {
        runWorker(this);
    }

    ......
}
```



### 3）核心方法execute()



```java
public void execute(Runnable command) {
    if (command == null)
        throw new NullPointerException();
    
    int c = ctl.get();
    // 1.
    if (workerCountOf(c) < corePoolSize) { // 工作线程数少于核心线程数
      	// 添加工作线程，true代表算作核心线程的添加
        if (addWorker(command, true))
            return;
        
        c = ctl.get();
    }
  
    //2.
   	//添加核心线程失败
    // 检查线程池状态是否为RUNNING，然后将任务添加入任务队列
    if (isRunning(c) && workQueue.offer(command)) {
      	// 检查
        int recheck = ctl.get();
      	// 若状态不是RUNNING，就从队列中移除任务
        if (! isRunning(recheck) && remove(command))
          	// 移除成功后执行拒绝策略
            reject(command);
      	// 如果工作线程数为0，则添加一个非核心线程，且初始任务为null
        else if (workerCountOf(recheck) == 0)
            addWorker(null, false);
    }
  	//3.
    // 添加入队列失败，创建非核心线程
    else if (!addWorker(command, false))
      	// 若失败，直接执行拒绝策略
        reject(command);
}
```

> <font color = 'red'>其中第26-27行的代码就是处理，若corePoolSize = 0，且使用无界队列时，防止任务不断入队，但并没有线程来起动执行的情况</font>



### 4）核心方法addWorker()



主要分为两部分：检验创建条件和创建。

```java
private boolean addWorker(Runnable firstTask, boolean core) {
  
  ////////// 1. 检验能否创建工作线程//////////////////////////
    retry:
    for (;;) {
        int c = ctl.get();
        int rs = runStateOf(c);

        // 检查是否满足创建工作线程的条件
        if (rs >= SHUTDOWN &&
            ! (rs == SHUTDOWN &&
               firstTask == null &&
               ! workQueue.isEmpty()))
            return false;

        for (;;) {
            int wc = workerCountOf(c);
            if (wc >= CAPACITY ||
                wc >= (core ? corePoolSize : maximumPoolSize))
                return false;
            if (compareAndIncrementWorkerCount(c))
                break retry;
          	// 由于有并发，重新再读取一下 ctl
            c = ctl.get();  
          
          	// 正常如果是 CAS 失败的话，进到下一个里层的for循环就可以了
            // 可是如果是因为其他线程的操作，导致线程池的状态发生了变更，如有其他线程关闭了这个线程池
            // 那么需要回到外层的for循环
            if (runStateOf(c) != rs)
                continue retry;
          
            // else CAS failed due to workerCount change; retry inner loop
        }
    }

  ////// 2. 创建工作线程 //////////////////////////////////////
  
    boolean workerStarted = false;     // worker 是否已经启动
    boolean workerAdded = false; // 是否已将这个 worker 添加到 workers 这个 HashSet 中
    Worker w = null;
    try {
        w = new Worker(firstTask);
        final Thread t = w.thread;
        if (t != null) {
            final ReentrantLock mainLock = this.mainLock;
          	// 这个是整个类的全局锁，持有这个锁才能让下面的操作“顺理成章”，
            // 因为关闭一个线程池需要这个锁，至少我持有锁的期间，线程池不会被关闭
            mainLock.lock();
            try {
                // Recheck while holding lock.
                // Back out on ThreadFactory failure or if
                // shut down before lock acquired.
                int rs = runStateOf(ctl.get());

              	// 状态判断，结合上文
                if (rs < SHUTDOWN ||
                    (rs == SHUTDOWN && firstTask == null)) {
                    if (t.isAlive()) // 这里理论上该线程不会是启动的
                        throw new IllegalThreadStateException();
                    workers.add(w); // 加入HashSet
                    int s = workers.size();
                    if (s > largestPoolSize)  // largestPoolSize来记录历史最大值
                        largestPoolSize = s;
                    workerAdded = true;
                }
            } finally {
                mainLock.unlock();
            }
            if (workerAdded) {
                t.start(); // 添加成功再启动
                workerStarted = true;
            }
        }
    } finally {
        if (! workerStarted)
          // 启动失败，要回滚一些操作
            addWorkerFailed(w);
    }
    return workerStarted;
}
```



```java
// workers 中删除掉相应的 worker
// workCount 减 1
private void addWorkerFailed(Worker w) {
    final ReentrantLock mainLock = this.mainLock;
    mainLock.lock();
    try {
        if (w != null)
            workers.remove(w);
        decrementWorkerCount();
        // rechecks for termination, in case the existence of this worker was holding up termination
        tryTerminate();
    } finally {
        mainLock.unlock();
    }
}
```



> 其中：
>
> ```java
> if (rs >= SHUTDOWN &&
>             ! (rs == SHUTDOWN &&
>                firstTask == null &&
>                ! workQueue.isEmpty()))
>             return false;
> ```
>
> 简要说明：
>
> 1. 状态大于SHUTDOWN时因不允许提交任务，并且要终止线程，所以不可新建线程。
> 2. 状态等于SHUTDOWN时，提交的任务`firstTask != null`。因为不允许提交任务了。
> 3. 状态等于SHUTDOWN时，任务队列为空，因为不允许提交任务了，所以也无需新线程。
>
> <font color = 'red'>注意，当状态等于SHUTDOWN时，且`firstTask == null`可以创建新线程。</font>



### 5）任务执行run

Worker类中

```java
public void run() {
        runWorker(this);
    }
```



```java
final void runWorker(Worker w) {
    Thread wt = Thread.currentThread();
    Runnable task = w.firstTask;
    w.firstTask = null;
    w.unlock(); // allow interrupts
    boolean completedAbruptly = true;
    try {
      	// 初始化的任务不为null或从任务队列中获取到了任务
        while (task != null || (task = getTask()) != null) {
            w.lock();
            // 如果线程池状态大于等于 STOP，那么意味着该线程也要中断
            if ((runStateAtLeast(ctl.get(), STOP) ||
                 (Thread.interrupted() &&
                  runStateAtLeast(ctl.get(), STOP))) &&
                !wt.isInterrupted())
                wt.interrupt();
            try {
                beforeExecute(wt, task);
                Throwable thrown = null;
                try {
                  // 执行任务
                    task.run();
                } catch (RuntimeException x) {
                    thrown = x; throw x;
                } catch (Error x) {
                    thrown = x; throw x;
                } catch (Throwable x) {
                    thrown = x; throw new Error(x);
                } finally {
                    afterExecute(task, thrown);
                }
            } finally {
                task = null;
              // 完成任务数+1
                w.completedTasks++;
                w.unlock();
            }
        }
        completedAbruptly = false;
    } finally {
        processWorkerExit(w, completedAbruptly);
    }
}
```



### 6）获取任务getTask()



```java
private Runnable getTask() {
    boolean timedOut = false; // Did the last poll() time out?

    for (;;) {
        int c = ctl.get();
        int rs = runStateOf(c);

        // 情况判断，不接受新任务，任务队列空，或STOP
        if (rs >= SHUTDOWN && (rs >= STOP || workQueue.isEmpty())) {
          // CAS减少线程数
            decrementWorkerCount();
          // 返回无任务
            return null;
        }

        int wc = workerCountOf(c);

        //允许核心线程数内的线程回收，或当前线程数超过了核心线程数，那么有可能发生超时关闭
        boolean timed = allowCoreThreadTimeOut || wc > corePoolSize;

        if ((wc > maximumPoolSize || (timed && timedOut))
            && (wc > 1 || workQueue.isEmpty())) {
            if (compareAndDecrementWorkerCount(c))
                return null;
          // compareAndDecrementWorkerCount(c) 失败，线程池中的线程数发生了改变
            continue;
        }
			  // wc <= maximumPoolSize 同时没有超时
        try {
          	// 加入超时等待
            Runnable r = timed ?
                workQueue.poll(keepAliveTime, TimeUnit.NANOSECONDS) :
                workQueue.take();
            if (r != null)
                return r;
            timedOut = true;
        } catch (InterruptedException retry) {
            timedOut = false;
        }
    }
}
```



## 2. 线程池大小的确定 

有一个简单并且适用面比较广的公式：

- **CPU 密集型任务(N+1)：** 这种任务消耗的主要是 CPU 资源，可以将线程数设置为 N（CPU 核心数）+1，比 CPU 核心数多出来的一个线程是为了防止线程偶发的缺页中断，或者其它原因导致的任务暂停而带来的影响。一旦任务暂停，CPU 就会处于空闲状态，而在这种情况下多出来的一个线程就可以充分利用 CPU 的空闲时间。
- **I/O 密集型任务(2N)：** 这种任务应用起来，系统会用大部分的时间来处理 I/O 交互，而线程在处理 I/O 的时间段内不会占用 CPU 来处理，这时就可以将 CPU 交出给其它线程使用。因此在 I/O 密集型任务的应用中，我们可以多配置一些线程，具体的计算方法是 2N。



参考地址：https://juejin.im/entry/59b232ee6fb9a0248d25139a#comment

​				  https://snailclimb.gitee.io/javaguide/#/docs/java/Multithread/JavaConcurrencyAdvancedCommonInterviewQuestions



## 3、Java提供了哪几种线程池

#### Java 主要提供了下面 4 种线程池

- **FixedThreadPool：** 该方法返回一个固定线程数量的线程池。该线程池中的线程数量始终不变。当有一个新的任务提交时，线程池中若有空闲线程，则立即执行。若没有，则新的任务会被暂存在一个任务队列中，待有线程空闲时，便处理在任务队列中的任务。
- **SingleThreadExecutor：** 方法返回一个只有一个线程的线程池。若多余一个任务被提交到该线程池，任务会被保存在一个任务队列中，待线程空闲，按先入先出的顺序执行队列中的任务。
- **CachedThreadPool：** 该方法返回一个可根据实际情况调整线程数量的线程池。线程池的线程数量不确定，但若有空闲线程可以复用，则会优先使用可复用的线程。若所有线程均在工作，又有新的任务提交，则会创建新的线程处理任务。所有线程在当前任务执行完毕后，将返回线程池进行复用。
- **ScheduledThreadPoolExecutor：** 主要用来在给定的延迟后运行任务，或者定期执行任务。ScheduledThreadPoolExecutor 又分为：ScheduledThreadPoolExecutor（包含多个线程）和 SingleThreadScheduledExecutor （只包含一个线程）两种。

#### 各种线程池的适用场景介绍

- **FixedThreadPool：** 适用于为了满足资源管理需求，而需要限制当前线程数量的应用场景。它适用于负载比较重的服务器；
- **SingleThreadExecutor：** 适用于需要保证顺序地执行各个任务并且在任意时间点，不会有多个线程是活动的应用场景；
- **CachedThreadPool：** 适用于执行很多的短期异步任务的小程序，或者是负载较轻的服务器；
- **ScheduledThreadPoolExecutor：** 适用于需要多个后台执行周期任务，同时为了满足资源管理需求而需要限制后台线程的数量的应用场景；
- **SingleThreadScheduledExecutor：** 适用于需要单个后台线程执行周期任务，同时保证顺序地执行各个任务的应用场景。

