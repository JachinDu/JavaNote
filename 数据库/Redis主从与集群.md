# Redis主从与集群

## 1、普通主从

![img](../PicSource/Center.png)

> 优点：
>
> - <font color='#02C874'>**读写分离，通过增加*Slaver*可以提高并发读的能力。**</font>
> - <font color='#02C874'>**提供了master的备份容灾能力**</font>
>
> 缺点：
>
> - <font color='#02C874'>***Master*写能力是瓶颈。**</font>
> - <font color='#02C874'>**Master的存储能力受到单机的限制。**</font>
> - 虽然理论上对*Slaver*没有限制但是<font color='#02C874'>**维护*Slaver*开销总将会变成瓶颈。**</font>
> - <font color='#02C874'>**一旦 Master宕机，Slaver 晋升成 Master，同时需要修改 应用方 的 Master地址，还需要命令所有 Slaver 去 复制 新的Master，整个过程需要 人工干预。**</font>
>
> 

------

## 2、hash slot

![img](../PicSource/Center-20200402230047755.png)

> <font color='#02C874'>**对象保存到Redis之前先经过CRC16哈希到一个指定的Node上，例如Object4最终Hash到了Node1上。**</font>
>
> 2， 每个Node被平均分配了一个Slot段，对应着0-16384，Slot不能重复也不能缺失，否则会导致对象重复存储或无法存储。
>
> 3，<font color='red'> **Node之间也互相监听，一旦有Node退出或者加入，会按照Slot为单位做数据的迁移。例如Node1如果掉线了，0-5640这些Slot将会平均分摊到Node2和Node3上,由于Node2和Node3本身维护的Slot还会在自己身上不会被重新分配，所以迁移过程中不会影响到5641-16384Slot段的使用。**</font>
>
> 
>
> 缺点：每个Node承担着互相监听、高并发数据写入、高并发数据读出，工作任务繁重
>
> 优点：<font color='#02C874'>**将Redis的写操作分摊到了多个节点上，提高写的并发能力，扩容简单。**</font>

------

## 3、集群

![img](../PicSource/Center-20200402230232365.png)

------

