# Spring 事务管理

参考：https://juejin.im/post/5b00c52ef265da0b95276091

https://juejin.im/entry/5a8fe57e5188255de201062b





# 1、事务隔离级别

对应于数据库中的事务隔离级别：

> - **TransactionDefinition.==ISOLATION_DEFAULT==:**	使用后端数据库默认的隔离级别，Mysql 默认采用的 ==***REPEATABLE_READ***==隔离级别 Oracle 默认采用的 ==READ_COMMITTED==隔离级别.
>
> - **TransactionDefinition.==ISOLATION_READ_UNCOMMITTED==:** 最低的隔离级别，允许读取尚未提交的数据变更，**可能会导致脏读、幻读或不可重复读**
>
> - **TransactionDefinition.==ISOLATION_READ_COMMITTED==:** 	允许读取并发事务已经提交的数据，**可以阻止脏读，但是幻读或不可重复读仍有可能发生**
>
> - **TransactionDefinition.==ISOLATION_REPEATABLE_READ==:** 	对同一字段的多次读取结果都是一致的，除非数据是被本身事务自己所修改，**可以阻止脏读和不可重复读，但幻读仍有可能发生。**
>
> - **TransactionDefinition.==*ISOLATION_SERIALIZABLE*==:** 	最高的隔离级别，完全服从ACID的隔离级别。所有的事务依次逐个执行，这样事务之间就完全不可能产生干扰，也就是说，**该级别可以防止脏读、不可重复读以及幻读**。但是这将严重影响程序的性能。通常情况下也不会用到该级别。

------



## 2、事务传播行为

事务传播行为用来描述由**<font color='red'>某一个事务传播行为修饰的方法被嵌套进另一个方法的时事务如何传播。</font>**

例如：

```java
public void methodA(){
    methodB();
    //doSomething
 }
 
 @Transaction(Propagation=XXX)
 public void methodB(){
    //doSomething
 }
```

> 代码中`methodA()`方法嵌套调用了`methodB()`方法，`methodB()`的事务传播行为由`@Transaction(Propagation=XXX)`设置决定。这里需要注意的是`methodA()`并没有开启事务，某一个事务传播行为修饰的方法并不是必须要在开启事务的外围方法中调用，即==可在非事务的方法内调用==。

------



### ==Spring的七种事务传播行为==

> **==支持当前事务的情况：==**
>
> - **TransactionDefinition.==*PROPAGATION_REQUIRED*==：** 如果当前存在事务，则加入该事务；<font color='red'>如果当前没有事务，则创建一个新的事务。</font>
> - **TransactionDefinition.==*PROPAGATION_SUPPORTS*==：** 如果当前存在事务，则加入该事务；<font color='red'>如果当前没有事务，则以非事务的方式继续运行。</font>
> - **TransactionDefinition.PROPAGATION_MANDATORY：** 如果当前存在事务，则加入该事务；<font color='red'>如果当前没有事务，则抛出异常。（mandatory：强制性）</font>
>
> **==不支持当前事务的情况：==**
>
> - **TransactionDefinition.PROPAGATION_REQUIRES_NEW：** <font color='red'>创建一个新的事务，如果当前存在事务，则把当前事务挂起。</font>
> - **TransactionDefinition.PROPAGATION_NOT_SUPPORTED：** <font color='red'>以非事务方式运行，如果当前存在事务，则把当前事务挂起。</font>
> - **TransactionDefinition.PROPAGATION_NEVER：**<font color='red'> 以非事务方式运行，如果当前存在事务，则抛出异常。</font>
>
> **==其他情况：==**
>
> - **TransactionDefinition.PROPAGATION_NESTED：** 如果当前存在事务，<font color='red'>则创建一个事务作为当前事务的==嵌套事务==来运行</font>；如果当前没有事务，则该取值等价于TransactionDefinition.PROPAGATION_REQUIRED。