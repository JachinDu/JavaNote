# Spring 事务管理

参考：https://juejin.im/post/5b00c52ef265da0b95276091

https://juejin.im/entry/5a8fe57e5188255de201062b





## 1、事务隔离级别

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

------

## 3、@Transactional

> Spring 事务管理分为编码式和声明式的两种方式。编程式事务指的是通过编码方式实现事务；<font color='red'>**声明式事务基于 AOP,将具体业务逻辑与事务处理解耦。声明式事务管理使业务代码逻辑不受污染**</font>, 因此在实际使用中声明式事务用的比较多。声明式事务有两种方式，一种是在配置文件（xml）中做相关的事务规则声明，另一种是基于@Transactional 注解的方式。注释配置是目前流行的使用方式，因此本文将着重介绍基于@Transactional 注解的事务管理。

------

### @Transactional属性：

| 属性名           | 说明                                                         |
| :--------------- | :----------------------------------------------------------- |
| name             | 当在配置文件中有多个 TransactionManager , 可以用该属性指定选择哪个事务管理器。 |
| propagation      | 事务的传播行为，默认值为 REQUIRED。                          |
| isolation        | 事务的隔离度，默认值采用 DEFAULT。                           |
| timeout          | 事务的超时时间，默认值为-1。如果超过该时间限制但事务还没有完成，则自动回滚事务。 |
| read-only        | 指定事务是否为只读事务，默认值为 false；为了忽略那些不需要事务的方法，比如读取数据，可以设置 read-only 为 true。 |
| rollback-for     | 用于指定能够触发事务回滚的异常类型，如果有多个异常类型需要指定，各类型之间可以通过逗号分隔。 |
| no-rollback- for | 抛出 no-rollback-for 指定的异常类型，不回滚事务。            |

------

除此以外，==@Transactional 注解也可以添加到类级别上。当把@Transactional 注解放在类级别时，表示所有该类的公共方法都配置相同的事务属性信息。==当类级别配置了@Transactional，方法级别也配置了@Transactional，应用程序会以方法级别的事务属性信息来管理事务，换言之，方法级别的事务属性信息会覆盖类级别的相关配置信息。

------

### 实现机制：

> Spring Framework 默认使用 AOP 代理，<font color='red'>***在代码运行时生成一个代理对象，根据@Transactional 的属性配置信息，这个代理对象决定该声明@Transactional 的目标方法是否由==拦截器 TransactionInterceptor 来使用拦截==，在 TransactionInterceptor 拦截时，会在在目标方法开始执行之前创建并加入事务，并执行目标方法的逻辑, 最后根据执行情况是否出现异常，利用抽象==事务管理器AbstractPlatformTransactionManager 操作数据源 DataSource 提交或回滚事务。==***</font>

------

![img](../PicSource/image001.jpg)