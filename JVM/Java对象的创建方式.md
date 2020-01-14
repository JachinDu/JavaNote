# Java对象的创建方式



常用的创建对象的方式大致有5种：

> - new关键字
> - 反射(2种)
> - clone方法
> - 反序列化



## 1、new关键字

```java
Student student = new Student();
```

Student类想怎么写就怎么写，不多赘述。



## 2、利用反射的两种创建方式

### 1）只能调用无参构造函数

`newInstance()`方法只能调用类的无参构造函数，==因此要求类必须有无参构造函数==。

```java
Student student2 = (Student)Class.forName("Student类全限定名").newInstance();　
// 或者
Student stu = Student.class.newInstance();
```

==注意：若手动添加了有参构造函数，需手动再添加无参构造函数，否则报错：==

```
Exception in thread "main" java.lang.InstantiationException: Student
	at java.lang.Class.newInstance(Class.java:427)
	at CreateInstance.main(CreateInstance.java:16)
Caused by: java.lang.NoSuchMethodException: Student.<init>()
	at java.lang.Class.getConstructor0(Class.java:3082)
	at java.lang.Class.newInstance(Class.java:412)
```



### 2) 调用有参构造函数

利用 `java.lang.reflect.Constructor` 

此方法不要求类中有无参构造函数

```java
Constructor<Student> constructor = Student.class.getConstructor(Integer.class); // 传入参数类型.class，多个参数用逗号隔开
Student stu = constructor.newInstance(123);
```





## 3、使用clone方法创建



要求类要实现`Cloneable`接口，重写clone()方法，==创建过程不调用任何构造函数==

```java
import java.io.Serializable;

/**
 * @description:
 * @Author: JachinDo
 * @Date: 2019/11/28 13:47
 */
public class Student implements Cloneable{
    private int id;
    public Student(int id) {
        this.id = id;
    }

    public void test() {
        System.out.println("Student " + id);
    }
		// 重写clone()方法
    @Override
    protected Object clone() throws CloneNotSupportedException {
        return super.clone(); //super.clone()是一个native方法了
    }
}

// 调用
// Student stu1 = (Student) stu.clone(); 创建出一个与stu一模一样的对象stu1
```



## 4、反序列化创建



要求类实现`Serializable`接口，==创建过程不调用任何构造函数==。

创建代码：

```java
// 将一个已存在的对象stu序列化后写入文件流
ObjectOutputStream outputStream = new ObjectOutputStream(new FileOutputStream("student.bin"));
outputStream.writeObject(stu);
outputStream.close();

// 从文件流读出并反序列化后创建一个与stu一样的对象stu1
ObjectInputStream inputStream = new ObjectInputStream(new FileInputStream("student.bin"));
Student stu1 = (Student) inputStream.readObject();
stu1.shuchu();
```