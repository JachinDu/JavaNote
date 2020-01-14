# Class对象与反射技术



参考：https://zhuanlan.zhihu.com/p/60805342



反射(Reflection)是 Java 程序开发语言的特征之一，它允许运行中的 Java 程序获取自身的信息，并且可以操作类或对象的内部属性。

**通过反射机制，可以在运行时访问 Java 对象的属性，方法，构造方法等。**

在运行时期动态创建对象；

获取对象的属性、方法



##1、 反射的应用场景

- 开发通用框架 - 反射最重要的用途就是开发各种通用框架。很多框架（比如 Spring）都是配置化的（比如通过 XML 文件配置 JavaBean、Filter 等），为了保证框架的通用性，它们可能需要根据配置文件加载不同的对象或类，调用不同的方法，这个时候就必须用到反射——运行时动态加载需要加载的对象。
- 动态代理 - 在切面编程（AOP）中，需要拦截特定的方法，通常，会选择动态代理方式。这时，就需要反射技术来实现了。
- 注解 - 注解本身仅仅是起到标记作用，它需要利用反射机制，根据注解标记去调用注解解释器，执行行为。如果没有反射机制，注解并不比注释更有用。
- 可扩展性功能 - 应用程序可以通过使用完全限定名称创建可扩展性对象实例来使用外部的用户定义类。

------



## 2、获取Class对象的三种方法

> 1. **使用Class类的static方法：`Class.forName("类的全限定名")`**
> 2. **直接获取某一个类的 class：`Boolean.class`**
> 3. **==对象==调用 Object 的 `getClass` 方法：`object.getClass()`****





举例

------

Admin类：

```java
public class Admin{
  
  //Field
	private int id;
  private String name;
  
  //Constructor
  public Admin(){
    sout("Admin.Admin()");
  }
  public Admin(String name){
    sout("Admin.Admin()"+name);
  }
    
  //Method
    ....getter,setter....
}
```



使用反射：获取对象，属性，方法

```java
public void test{
  //全限定类名
  String className = "包+类";
  //得到类字节码，不知道类类型，所以用泛型<?>接收
  Class<?> clazz = Class.forName(className);
  
  //创建对象1:只能使用默认构造函数
  Admin admin = (Admin) clazz.newInstance();
  
  //创建对象2:通过构造器创建（该方式可调用含参构造函数）
  Constructor<?> constructor = clazz.getDeclaredConstructor(String.class);//要传入参数类型
  Admin admin = (Admin) constructor.newInstance("Jack"); //传入实际参数
  
  //获取所有属性
  Field[] fs = clazz.getDeclaredFields();
  for(Field f : fs){
    f.setAccessible(true);//设置强制访问
    String name = f.getName();
    Object value = f.get(admin);
  }
}

  //获取方法 public int getId(String name){}
	Method m = clazz.getDeclaredMethod("getId",String.class); //有参数，则传入参数类型，没有则不写
	//调用方法，因为刚才获取的方法有返回值
	Object r_value = m.invoke(admin); //传的是admin

```

<mark>上述为固定步骤</mark>

