# HashMap和HashTable/HashSet的区别

## **1、HashMap 和 Hashtable 的区别**

1. **线程是否安全：** HashMap 是非线程安全的，Hashtable 是线程安全的；==Hashtable 内部的方法基本都经过 `synchronized` 修饰。==（如果你要保证线程安全的话就使用 ConcurrentHashMap 吧！）；
2. **效率：** 因为线程安全的问题，HashMap 要比 Hashtable 效率高一点。另外，==Hashtable 基本被淘汰==，不要在代码中使用它；
3. **对 Null key 和 Null value 的支持：**<font color='red'> HashMap 中，null 可以作为键，这样的键只有一个，可以有一个或多个键所对应的值为 null。但是在 Hashtable 中 put 进的键值只要有一个 null，直接抛出 NullPointerException。</font>
4. **初始容量大小和每次扩充容量大小的不同 ：** ① 创建时如果不指定容量初始值，Hashtable 默认的初始大小为 11，之后每次扩充，容量变为原来的 2n+1。HashMap 默认的初始化大小为 16。之后每次扩充，容量变为原来的 2 倍。② 创建时如果给定了容量初始值，那么 ==Hashtable 会直接使用你给定的大小==，**<font color='red'> 而 HashMap 会将其扩充为 2 的幂次方大小。</font>**
5. **底层数据结构：** JDK1.8 以后的 HashMap 在解决哈希冲突时有了较大的变化，当链表长度大于阈值（默认为 8）时，将链表转化为==红黑树==，以减少搜索时间。Hashtable 没有这样的机制。

------



## **2、HashSet 和 HashMap 区别**

如果你看过 HashSet 源码的话就应该知道：HashSet 底层就是基于 HashMap 实现的。（HashSet 的源码非常非常少，因为除了 clone() 方法、writeObject()方法、readObject()方法是 HashSet 自己不得不实现之外，其他方法都是直接调用 HashMap 中的方法。）

