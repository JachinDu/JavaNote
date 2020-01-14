# 序列化与serialVersionUID



## 1、序列化

对象的序列化主要有两种用途:

- 把对象序列化成字节码，保存到指定介质上(如磁盘等)
- 用于网络传输

被序列化的实例所属类需要实现`Serializable`接口：



## 2、serialVersionUID



`serialVersionUID`适用于Java的序列化机制。

简单来说，Java的序列化机制是**<font color='red'>通过判断类的`serialVersionUID`来验证版本一致性的</font>**。

在进行反序列化时，JVM会把传来的**<font color='red'>字节流中的`serialVersionUID`与本地相应实体类的`serialVersionUID`进行比较</font>**，如果相同就认为是一致的，可以进行反序列化，否则就会出现序列化版本不一致的异常，即是`InvalidCastException`。

**具体的序列化过程是这样的**：序列化操作的时候系统会把当前类的`serialVersionUID`写入到序列化文件中，当反序列化时系统会去检测文件中的`serialVersionUID`，判断它是否与当前类的`serialVersionUID`一致，如果一致就说明序列化类的版本与当前类版本是一样的，可以反序列化成功，否则失败。



## 3、为什么建议显式指定serialVersionUID？

举例说明：

假设我们有一个Person类，我们进行如下操作：

> 1. 先将其序列化到本地。然后再反序列化。（正常）
> 2. **<font color='red'>我们给Person类增加一个字段后，不修改UID，这时，再反序列化。（正常）（兼容）</font>**
> 3. **<font color='red'>但如果增加字段后修改了UID，则反序列化时由于JVM监测到字节流中的`serialVersionUID`与当前Person类中的不同，抛出异常。</font>**

------

由此可知：

​	`serialVersionUID` 就是控制版本是否兼容的，若我们认为修改的 Person 是向后兼容的，则不修改 serialVersionUID；反之，则提高 serialVersionUID的值。

​	**<font color='red'>若不显式定义 serialVersionUID 的值，Java 会根据类细节自动生成 serialVersionUID 的值，如果对类的源代码作了修改，再重新编译，新生成的类文件的serialVersionUID的取值有可能也会发生变化。</font>**这样就无法做到版本兼容了。

