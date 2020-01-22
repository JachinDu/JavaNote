# ConcurrentHashMap

## jdk1.7:

![img](../PicSource/5cd1d2c5ce95c.jpg)

> - **元素封装为HashEntry，同jdk1.7的HashMap**
> - **分段锁+链表**



## jdk1.8

主要有两方面的优化：

> - **<font color='red'>底层由链表 --> 链表 + 红黑树</font>**
>
> - **<font color='red'>CAS + synchronized 实现锁链表头/根节点（不是segment锁了）</font>**
>
> - **元素封装为Node<K,V>，同jdk1.8的HashMap**
>
>   ```java
>   static class Node<K,V> implements Map.Entry<K,V> {
>       final int hash;
>       final K key;
>       volatile V val;
>       volatile Node<K,V> next;
>   ```
>
> - 注意：
>
>   https://mp.weixin.qq.com/s/muiJ2vKK6a68_yCW6XWsVg
>   
>   - **<font color='red'>哈希表是volatile Node<K,V>[]类型，这里的volatile保证的是扩容时对整张哈希表的可见性。</font>**
>   - **<font color='red'>Node<K,V>中的val和next是volatile的，用来保证数组元素的可见性。</font>**



------

![img](../PicSource/5cd1d2ce33795.jpg)





#### put方法

```java
public V put(K key, V value) {
    return putVal(key, value, false);
}

/** Implementation for put and putIfAbsent */
final V putVal(K key, V value, boolean onlyIfAbsent) {
    if (key == null || value == null) throw new NullPointerException();
    int hash = spread(key.hashCode()); // 计算key的hash值
    int binCount = 0;
    for (Node<K,V>[] tab = table;;) {
        Node<K,V> f; int n, i, fh;
        if (tab == null || (n = tab.length) == 0) // 是否需要初始化哈希表
            tab = initTable();
        else if ((f = tabAt(tab, i = (n - 1) & hash)) == null) {// 查看对应hash位置是否有数据
          // 若当前桶为空，则直接使用CAS自旋写入，直至成功。  
          if (casTabAt(tab, i, null,
                         new Node<K,V>(hash, key, value, null)))
                break;                   // no lock when adding to empty bin
        }
      	// 如果定位出的位置为-1（MOVED == -1）,则扩容
        else if ((fh = f.hash) == MOVED)
            tab = helpTransfer(tab, f);
      
      // 利用synchronized锁写入数据，类似于hashmap，只是hashmap没有加锁  
      else {
            V oldVal = null;
            synchronized (f) { // 锁住当前桶
                if (tabAt(tab, i) == f) {
                    if (fh >= 0) {
                        binCount = 1;
                        for (Node<K,V> e = f;; ++binCount) {
                            K ek;
                            if (e.hash == hash &&
                                ((ek = e.key) == key ||
                                 (ek != null && key.equals(ek)))) {
                                oldVal = e.val;
                                if (!onlyIfAbsent)
                                    e.val = value;
                                break;
                            }
                            Node<K,V> pred = e;
                            if ((e = e.next) == null) {
                                pred.next = new Node<K,V>(hash, key,
                                                          value, null);
                                break;
                            }
                        }
                    }
                    else if (f instanceof TreeBin) {
                        Node<K,V> p;
                        binCount = 2;
                        if ((p = ((TreeBin<K,V>)f).putTreeVal(hash, key,
                                                       value)) != null) {
                            oldVal = p.val;
                            if (!onlyIfAbsent)
                                p.val = value;
                        }
                    }
                }
            }
            if (binCount != 0) {
                if (binCount >= TREEIFY_THRESHOLD)
                    treeifyBin(tab, i);
                if (oldVal != null)
                    return oldVal;
                break;
            }
        }
    }
    addCount(1L, binCount);
    return null;
}
```



注意：

> 1. 关于操作volatile数组(哈希表)：
>
>    ```java
>    static final <K,V> Node<K,V> tabAt(Node<K,V>[] tab, int i) {
>        return (Node<K,V>)U.getObjectVolatile(tab, ((long)i << ASHIFT) + ABASE);
>    }
>    ```
>
>    **<font color='red'>tab是一个volatile的`Node<K,V>[]`类型数组，ConcurrentHashMap中获取和设置该数组元素都是通过类似方法(`getObjectVolatile`)实现的，而不是直接访问数组元素。可能是因为volatile数组对数组内元素的可见性保证有待商榷，所以需要特殊的操作方法来保证其内部元素的可见性。</font>**
>
> 2. 关于表的初始化：
>
>    ```java
>    private final Node<K,V>[] initTable() {
>        Node<K,V>[] tab; int sc;
>        while ((tab = table) == null || tab.length == 0) {
>            if ((sc = sizeCtl) < 0)
>              	// 有线程正在初始化
>                Thread.yield(); // 让出时间片
>            else if (U.compareAndSwapInt(this, SIZECTL, sc, -1)) { // 设置为-1说明本线程正在初始化。
>                try {
>                    if ((tab = table) == null || tab.length == 0) {
>                        int n = (sc > 0) ? sc : DEFAULT_CAPACITY;
>                        @SuppressWarnings("unchecked")
>                        Node<K,V>[] nt = (Node<K,V>[])new Node<?,?>[n];
>                        table = tab = nt;
>                        sc = n - (n >>> 2);
>                    }
>                } finally {
>                    sizeCtl = sc;
>                }
>                break;
>            }
>        }
>        return tab;
>    }
>    ```



------



#### get方法

```java
public V get(Object key) {
    Node<K,V>[] tab; Node<K,V> e, p; int n, eh; K ek;
    int h = spread(key.hashCode());
    if ((tab = table) != null && (n = tab.length) > 0 &&
        (e = tabAt(tab, (n - 1) & h)) != null) {
        if ((eh = e.hash) == h) {
          	// 如果对应位置的桶上元素直接是目标值，则返回
            if ((ek = e.key) == key || (ek != null && key.equals(ek)))
                return e.val;
        }
        else if (eh < 0) // 在树形结构上
            return (p = e.find(h, key)) != null ? p.val : null;
      	// 在链表上
        while ((e = e.next) != null) {
            if (e.hash == h &&
                ((ek = e.key) == key || (ek != null && key.equals(ek))))
                return e.val;
        }
    }
    return null;
}
```



## 注意：

**key和value都不能为null**



参考：

https://crossoverjie.top/2018/07/23/java-senior/ConcurrentHashMap/

https://mp.weixin.qq.com/s/r1ErR7EroJt4b83Pm7Xk6g