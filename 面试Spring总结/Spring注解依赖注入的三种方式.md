# Spring注解依赖注入的三种方式

**当我们在使用依赖注入的时候，通常有三种方式：**

> 1.通过构造器来注入；
>
> 2.通过setter方法来注入；
>
> 3.通过filed变量来注入；

------



## 1、Constructor

```java
private DependencyA dependencyA;
private DependencyB dependencyB;
private DependencyC dependencyC;
 
@Autowired
public DI(DependencyA dependencyA, DependencyB dependencyB, DependencyC dependencyC) {
    this.dependencyA = dependencyA;
    this.dependencyB = dependencyB;
    this.dependencyC = dependencyC;
}	
```



## 2、Setter

```java
private DependencyA dependencyA;
private DependencyB dependencyB;
private DependencyC dependencyC;
 
@Autowired
public void setDependencyA(DependencyA dependencyA) {
    this.dependencyA = dependencyA;
}
 
@Autowired
public void setDependencyB(DependencyB dependencyB) {
    this.dependencyB = dependencyB;
}
 
@Autowired
public void setDependencyC(DependencyC dependencyC) {
    this.dependencyC = dependencyC;
}
```



## 3、Field

```java
@Autowired
private DependencyA dependencyA;
 
@Autowired
private DependencyB dependencyB;
 
@Autowired
private DependencyC dependencyC;
```



## 4、三种方式的区别

三种方式的区别小结：

1. <font color='red'>基于constructor的注入，会固定依赖注入的顺序</font>；该方式不允许我们创建bean对象之间的循环依赖关系，这种限制其实是一种利用构造器来注入的益处 - 当你甚至没有注意到使用setter注入的时候，Spring能解决循环依赖的问题；

2. <font color='red'>基于setter的注入，只有当对象是需要被注入的时候它才会帮助我们注入依赖，而不是在初始化的时候就注入</font>；另一方面如果你使用基于constructor注入，CGLIB不能创建一个代理，迫使你使用基于接口的代理或虚拟的无参数构造函数。

3. 相信很多同学都选择使用直接在成员变量上写上注解来注入，正如我们所见，这种方式看起来非常好，精短，可读性高，不需要多余的代码，也方便维护；



**缺点：**

1. 当我们利用constructor来注入的时候，比较明显的一个缺点就是：==假如我们需要注入的对象特别多的时候，我们的构造器就会显得非常的冗余==、不好看，非常影响美观和可读性，维护起来也较为困难；

2. 当我们选择setter方法来注入的时候，==***我们不能将对象设为final***==的；

3. 当我们在field变量上来实现注入的时候

     a. 这样不符合JavaBean的规范，而且很有可能引起空指针；

     b. 同时也不能将对象标为final的；

     c. 类与DI容器高度耦合，我们不能在外部使用它；

     d. ==类不通过反射不能被实例化（例如单元测试中）==，你需要用DI容器去实例化它，这更像集成测试；

     ...  etc.



## 5、总结

1. 强制性的依赖性或者当目标不可变时，使用构造函数注入（**应该说尽量都使用构造器来注入**）

2. 可选或多变的依赖使用setter注入（**建议可以使用构造器结合setter的方式来注入**）

3. 在大多数的情况下避免field域注入（**感觉大多数同学可能会有异议，毕竟这个方式写起来非常简便，但是它的弊端确实远大于这些优点**）

4. Spring 4.3+ 的同学可以试一试构造器的隐式注入，采用此方式注入后，使得我们的代码更优雅，更独立，减少了对Spring的依赖性。

```java
@Service
public class FooService {

    private final FooRepository repository;
		// @Autowired 可省略
    public FooService(FooRepository repository) {
        this.repository = repository
    }
}
```

