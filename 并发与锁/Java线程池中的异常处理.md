# Java线程池中的异常处理

## &sect; 前置知识

> - 线程池中的任务有两种，一种有返回值，一种无返回值。通常对应着两种提交任务的方法：
>
>   - **submit方法：**==虽然参数是Runnable，但由于返回值为Future，所以通常传入的参数为FutureTask类的对象。（FutureTask间接实现了Runnable接口和Future接口）==
>
>     ```java
>     public Future<?> submit(Runnable task) {
>       if (task == null) throw new NullPointerException();
>       RunnableFuture<Void> ftask = newTaskFor(task, null);
>       execute(ftask);
>       return ftask;
>     }
>     ```
>
>   - **execute方法：**
>
>     ```java
>     public void execute(Runnable command) {
>       if (command == null)
>         throw new NullPointerException();
>       int c = ctl.get();
>       if (workerCountOf(c) < corePoolSize) {
>         if (addWorker(command, true))
>           return;
>         c = ctl.get();
>       }
>       if (isRunning(c) && workQueue.offer(command)) {
>         int recheck = ctl.get();
>         if (! isRunning(recheck) && remove(command))
>           reject(command);
>         else if (workerCountOf(recheck) == 0)
>           addWorker(null, false);
>       }
>       else if (!addWorker(command, false))
>         reject(command);
>     }
>     ```
>
> - 不论是什么类型的任务，最终被包装如ThreadPoolExecutor类中的Worker类，而任务的执行都是通过`runWorker()`方法，这里截取关键部分：
>
>   ```java
>   try {
>     beforeExecute(wt, task);
>     Throwable thrown = null;
>     try {
>       task.run(); // 调用对应任务的run方法！！！
>     } catch (RuntimeException x) {
>       thrown = x; throw x;
>     } catch (Error x) {
>       thrown = x; throw x;
>     } catch (Throwable x) {
>       thrown = x; throw new Error(x);
>     } finally {
>       afterExecute(task, thrown);
>     }
>   } finally {
>     task = null;
>     w.completedTasks++;
>     w.unlock();
>   }
>   ```

------

## &sect; 默认情况存在的问题

> 由前置知识可知，`runWorker()`方法内，若`task.run()`出现异常，会抛出，然后进入`afterExecute(task, thrown)`方法，而该方法默认为空，<font color='red'>***所以默认情况下我们无法得到想要的异常信息。***</font>针对submit和execute提交的有返回值和无返回值的任务，有两种解决方向如下。

------



## &sect; submit提交的有返回值的任务

> 由于任务是FutureTask类的，所以在执行`task.run()`时，执行的是==FutureTask中重写的run()方法==，截取关键部分如下：
>
> ```java
> try {
>     result = c.call();
>      ran = true;
>    } catch (Throwable ex) {
>      result = null;
>      ran = false;
>      setException(ex);
>    }
>    //////
>    protected void setException(Throwable t) {
>      if (UNSAFE.compareAndSwapInt(this, stateOffset, NEW, COMPLETING)) {
>        outcome = t; // ！！！！关键
>        UNSAFE.putOrderedInt(this, stateOffset, EXCEPTIONAL); // final state
>        finishCompletion();
>      }
>    }
>    ```
>    
>    <font color='red'>***可见，任务执行出现异常后，不抛出，而是存入返回值当中。因此，若要获取异常信息则需通过返回值获取，所以可以在try catch中通过FutureTask的get()方法获取返回结果（异常）：***</font>
>    
>    ```java
>    try{
>    	future.get();
>    }catch(xxxException){
>    	// do sth
>    }
>    ```



------

## &sect; 通过execute提交的无返回值的任务

【法1】

> 从前面所讲可以知道，无返回值的任务，即原生Runnable，在执行`task.run()`时若有异常则会抛出，并只能在`afterExecute(task, thrown)`中进行自定义的处理，<font color='red'>***所以可以==自定义线程池==，继承ThreadPoolExecutor并复写其afterExecute(Runnable r, Throwable t)方法。***</font>

------

【法2】

> <font color='red'>***实现`Thread.UncaughtExceptionHandler`接口，并重写实现`void uncaughtException(Thread t, Throwable e);`方法，在该方法中处理异常。并将该handler传递给线程池的ThreadFactory。***</font>
>
> 具体可参考：https://juejin.im/post/5d27c3e6518825451f65ee15