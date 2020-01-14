# ArrayList和LinkedList对比

### **1. 是否保证线程安全：**

 **ArrayList 和 LinkedList 都是不同步的，也就是不保证线程安全；**

### **2. 底层数据结构：** 

**Arraylist 底层使用的是 Object 数组；LinkedList 底层使用的是==双向链表==数据结构（注意双向链表和双向循环链表的区别：）；**

### **3. 插入和删除：**

① **ArrayList 采用数组存储，所以插入和删除元素的时间复杂度受元素位置的影响。** 比如：执行`add(E e)`方法的时候， ArrayList 会默认在将指定的元素追加到此==列表的末尾==，这种情况时间复杂度就是 O(1)。但是如果要在指定位置 i 插入和删除元素的话（`add(int index, E element)`）==时间复杂度就为 O(n-i)==。因为在进行上述操作的时候集合中第 i 和第 i 个元素之后的(n-i)个元素都要执行向后位/向前==移一位的操作==。 

② **LinkedList 采用链表存储，所以插入，删除元素时间复杂度不受元素位置的影响，都是近似 O(1) 而数组为近似 O(n) 。**

### **4. 是否支持快速随机访问：** 

LinkedList 不支持高效的随机元素访问，而 ArrayList 支持。快速随机访问就是通过元素的序号快速获取元素对象（对应于`get(int index)`方法）。

### **5. 内存空间占用：**

**<font color='red'>ArrayList 的空 间浪费主要体现在在 list 列表的结尾会预留一定的容量空间，而 LinkedList 的空间花费则体现在它的每一个元素都需要消耗比 ArrayList 更多的空间（因为要存放直接后继和直接前驱以及数据）。</font>**



### 6、关于ArrayList初始化大小的问题

```java
ArrayList<Integer> list = new ArrayList<>(size);
```



**<font color='red'>这里初始化了ArrayList的大小，但记住，并没有==”初始化元素“==，因此，在没有add任何元素前，该==list是空的！！！==访问指定位置元素时会抛出越界异常。</font>**



### **补充内容:RandomAccess 接口**

```java
public interface RandomAccess {
}
```

查看源码我们发现实际上 RandomAccess 接口中什么都没有定义。所以，在我看来 RandomAccess 接口不过是一个标识罢了。标识什么？ 标识实现这个接口的类具有随机访问功能。

在 binarySearch() 方法中，它要判断传入的 list 是否 RamdomAccess 的实例，如果是，调用 indexedBinarySearch() 方法，如果不是，那么调用 iteratorBinarySearch() 方法

```java
    public static <T>
    int binarySearch(List<? extends Comparable<? super T>> list, T key) {
        if (list instanceof RandomAccess || list.size()<BINARYSEARCH_THRESHOLD)
            return Collections.indexedBinarySearch(list, key);
        else
            return Collections.iteratorBinarySearch(list, key);
    }
```

ArraysList 实现了 RandomAccess 接口， 而 LinkedList 没有实现。为什么呢？我觉得还是和底层数据结构有关！ArraysList 底层是数组，而 LinkedList 底层是链表。数组天然支持随机访问，时间复杂度为 O(1) ，所以称为快速随机访问。链表需要遍历到特定位置才能访问特定位置的元素，时间复杂度为 O(n) ，所以不支持快速随机访问。，ArraysList 实现了 RandomAccess 接口，就表明了他具有快速随机访问功能。 RandomAccess 接口只是标识，并不是说 ArraysList 实现 RandomAccess 接口才具有快速随机访问功能的！

**下面再总结一下 list 的遍历方式选择：**

- 实现了 RandomAccess 接口的 list，优先选择普通 for 循环 ，其次 foreach,
- 未实现 RandomAccess 接口的 ist， 优先选择 iterator 遍历（foreach 遍历底层也是通过 iterator 实现的），大 size 的数据，千万不要使用普通 for 循环

