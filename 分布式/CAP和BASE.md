# CAP和BASE

## CAP

- C - Consistent ，一致性
- A - Availability ，可用性
- P - Partition tolerance ，分区容忍性

------

> <font color='#02C874' size=4>**在网络分区发生时，两个分布式节点之间无法进行通信，我们对一个节点进行的修改操 作将无法同步到另外一个节点，所以数据的「一致性」将无法满足，因为两个分布式节点的 数据不再保持一致。除非我们牺牲「可用性」，也就是暂停分布式节点服务，在网络分区发 生时，不再提供修改数据的功能，直到网络状况完全恢复正常再继续对外提供服务。**</font>

<font color='red' size=5>**一句话概括 CAP 原理就是——网络分区发生时，一致性和可用性两难全。**</font>

------

## BASE

> - <font color='#02C874'>**BA - Basically Available：基本可用**</font>
>
>   <font color='#02C874'>**在故障时允许“损失部分可用性”：如**</font>
>
>   > - <font color='red'>**响应时间上的损失：故障后响应时间变长**</font>
>   > - <font color='red'>**功能上的损失：降级响应**</font>
>
> - <font color='#02C874'>**S - 软状态（弱状态）：允许系统中的数据存在中间状态（即数据副本之间同步时存在中间状态，有一定时延）。**</font>
>
> - <font color='#02C874'>**E - Eventually Consistent：最终一致性**</font>

