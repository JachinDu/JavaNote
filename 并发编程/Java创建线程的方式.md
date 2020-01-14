# Java创建线程的方式



> 1.继承Thread类
>
> 2.实现Runnable接口
>
> 3.使用Callable和Future

**<font color='blue'>2、3方法都要调用`new Thread(Runnable args)`，将接口实现类作为参数传入，注意，`Thread`只接收Runnable对象，而Callable不是Runnable子接口，需要包装为FutureTask对象才可。</font>**

------



## 1.继承Thead类创建线程

（1）继承Thread类并重写run方法

（2）创建线程对象

（3）调用该线程对象的start()方法来启动线程

```java
public class CreateThreadTest {
    public static void main(String[] args) {
        new ThreadTest().start();
        new ThreadTest().start();
    }
}

class ThreadTest extends Thread{
    private int i = 0;

    @Override
    public void run() {
        for (; i < 100; i++) {
            System.out.println(Thread.currentThread().getName() + " is running: " + i);
        }
    }
}
```





## 2.实现Runnable接口创建线程

（1）定义一个类实现Runnable接口，并重写该接口的run()方法

（2）**<font color='red'>创建 Runnable实现类的对象，作为创建Thread对象的target参数</font>**，此Thread对象才是真正的线程对象

（3）调用线程对象的start()方法来启动线程

```java
public class CreateThreadTest {
    public static void main(String[] args) {
        RunnableTest runnableTest = new RunnableTest();
        new Thread(runnableTest, "线程1").start();
        new Thread(runnableTest, "线程2").start();
    }
}

class RunnableTest implements Runnable{
    private int i = 0;

    @Override
    public void run() {
        for (; i < 100; i++) {
            System.out.println(Thread.currentThread().getName()  + " is running: " + i);
        }
    }
}
```



## 3.使用Callable接口和Future创建线程

和Runnable接口不一样，**<font color='red'>Callable接口提供了一个call()方法作为线程执行体，call()方法比run()方法功能要强大：call()方法可以有返回值，可以声明抛出异常</font>**。

```java
public interface Callable<V> {
    V call() throws Exception;
}
复制代码
```



Java5提供了Future接口来接收Callable接口中call()方法的返回值。**<font color='blue'> Callable接口是 Java5 新增的接口，不是Runnable接口的子接口，所以Callable对象不能直接作为Thread对象的target</font>**。针对这个问题，引入了RunnableFuture接口，**<font color='red'>RunnableFuture接口是Runnable接口和Future接口的子接口，可以作为Thread对象的target </font>**。同时，Java5提供了一个RunnableFuture接口的实现类：FutureTask ，<font color='red'>FutureTask可以作为Thread对象的target。</font>



![image-20200105152909226](/Users/jc/Documents/JavaNote/并发编程/image-20200105152909226.png)

------



介绍了相关概念之后，使用Callable和Future创建线程的步骤如下：

（1）定义一个类实现Callable接口，并重写call()方法，该call()方法将作为线程执行体，并且有返回值

（2）创建Callable实现类的实例，<font color='red'>使用FutureTask类来包装Callable对象</font>

（3）<font color='red'>使用FutureTask对象作为Thread对象的target创建并启动线程</font>

（4）<font color='red'>调用FutureTask对象的get()方法来获得子线程执行结束后的返回值</font>

```java
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;

public class CreateThreadTest {
    public static void main(String[] args) {
        CallableTest callableTest = new CallableTest();
        FutureTask<Integer> futureTask = new FutureTask<>(callableTest);
        new Thread(futureTask).start();
        try {
            System.out.println("子线程的返回值: " + futureTask.get());
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }
    }
}

class CallableTest implements Callable{

    @Override
    public Integer call() throws Exception {
        int sum = 0;
        for (int i = 1; i < 101; i++) {
            sum += i;
        }
        System.out.println(Thread.currentThread().getName() + " is running: " + sum);
        return sum;
    }
}
```



------



## 4.实现Runnable/Callable接口相比继承Thread类的优势

（1）适合多个线程进行**==资源共享==**

（2）可以避免java中单继承的限制

（3）增加程序的健壮性，代码和数据独立

（4）**<font color='red'>线程池只能放入Runable或Callable接口实现类，不能直接放入继承Thread的类</font>**

## 5.Callable和Runnable的区别

(1) Callable重写的是call()方法，Runnable重写的方法是run()方法

(2) call()方法执行后可以有返回值，run()方法没有返回值

(3) call()方法可以抛出==异常==，run()方法不可以

(4) ==运行Callable任务可以拿到一个Future对象，表示异步计算的结果 。通过Future对象可以了解任务执行情况，可取消任务的执行，还可获取执行结果==

