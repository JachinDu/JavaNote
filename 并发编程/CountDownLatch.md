# CountDownLatch

CountDownLatch 中文有的叫做计数器，也有翻译为计数锁，<mark>其最大的作用不是为了加锁，而是通过计数达到等待的功能</mark>，主要有两种形式的等待：

> 1. <mark>让一组线程在全部启动完成之后，再一起执行</mark>（先启动的线程需要阻塞等待后启动的线程，直到一组线程全部都启动完成后，再一起执行）；
> 2. <mark>主线程等待另外一组线程都执行完成之后，再继续执行。</mark>

> CountDownLatch 有两个比较重要的 API，分别是 await 和 countDown，==管理着线程能否获得锁和锁的释放（也可以称为对 state 的计数增加和减少）。==

------

## &sect; await

await 我们可以叫做等待，也可以叫做==加锁==，有两种不同入参的方法，源码如下：

```java
public void await() throws InterruptedException {
    sync.acquireSharedInterruptibly(1);
}
// 带有超时时间的，最终都会转化成毫秒
public boolean await(long timeout, TimeUnit unit)
    throws InterruptedException {
    return sync.tryAcquireSharedNanos(1, unit.toNanos(timeout));
}
```

两个方法底层使用的都是 sync，sync 是一个同步器，是 CountDownLatch 的内部类实现的，如下：

```java
private static final class Sync extends AbstractQueuedSynchronizer {}
```

可以看出来 Sync 继承了 AbstractQueuedSynchronizer，具备了同步器的通用功能。

无参 await 底层使用的是 acquireSharedInterruptibly 方法，有参的使用的是 tryAcquireSharedNanos 方法，这两个方法都是 AQS 的方法，底层实现很相似，主要分成两步：

> 1. 使用子类的 tryAcquireShared 方法尝试获得锁，如果获取了锁直接返回，获取不到锁走 2；
> 2. 获取不到锁，用 Node 封装一下当前线程，追加到同步队列的尾部，等待在合适的时机去获得锁。

第二步是 AQS 已经实现了，第一步 tryAcquireShared 方法是交给 Sync 实现的，源码如下：

```java
// 如果当前同步器的状态是 0 的话，表示可获得锁
protected int tryAcquireShared(int acquires) {
    return (getState() == 0) ? 1 : -1;
}
```

获得锁的代码也很简单，直接根据同步器的 state 字段来进行判断，但还是有两点需要注意一下：

1. 获得锁时，==state 的值不会发生变化，像 ReentrantLock 在获得锁时，会把 state + 1，但 CountDownLatch 不会；==
2. CountDownLatch 的 state 并不是 AQS 的默认值 0，而是可以赋值的，是在 CountDownLatch 初始化的时候赋值的，代码如下：

```java
// 初始化,count 代表 state 的初始化值
public CountDownLatch(int count) {
    if (count < 0) throw new IllegalArgumentException("count < 0");
    // new Sync 底层代码是 state = count;
    this.sync = new Sync(count);
}
```

这里的==**初始化的 count 和一般的锁意义不太一样，count 表示我们希望等待的线程数**==。

------

## &sect; countDown

countDown 中文翻译为倒计时，每调用一次，都会使 state 减一，底层调用的方法如下：

```java
public void countDown() {
    sync.releaseShared(1);
}
```

releaseShared 是 AQS 定义的方法，方法主要分成两步：

> 1. 尝试释放锁（tryReleaseShared），锁释放失败直接返回，释放成功走 2；
> 2. 释放当前节点的后置等待节点。

第二步 AQS 已经实现了，第一步是 Sync 实现的，我们一起来看下 tryReleaseShared 方法的实现源码：

```java
// 对 state 进行递减，直到 state 变成 0；
// state 递减为 0 时，返回 true，其余返回 false
protected boolean tryReleaseShared(int releases) {
    // 自旋保证 CAS 一定可以成功
    for (;;) {
        int c = getState();
        // state 已经是 0 了，直接返回 false
        if (c == 0)
            return false;
        // 对 state 进行递减
        int nextc = c-1;
        if (compareAndSetState(c, nextc))
            return nextc == 0;
    }
}
```

从源码中可以看到，只有到 count 递减到 0 时，countDown 才会返回 true。