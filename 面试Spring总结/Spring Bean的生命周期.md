# Spring Bean的生命周期

参考：https://www.cnblogs.com/zrtqsk/p/3735273.html

https://yemengying.com/2016/07/14/spring-bean-life-cycle/



![image-20191226134704044](../PicSource/image-20191226134704044.png)

从开始执行Bean的构造器开始才算是bean的生命周期开始：

> - Bean 容器找到配置文件中 Spring Bean 的定义。
> - Bean 容器利用<font color='red'> Java Reflection API 创建一个Bean的实例。</font>
> - 如果涉及到一些属性值 利用<font color='red'> `set()`方法设置一些属性值。</font>
> - 如果 Bean 实现了 `BeanNameAware` 接口，调用 `setBeanName()`方法，传入Bean的名字。
> - 如果 Bean 实现了 `BeanClassLoaderAware` 接口，调用 `setBeanClassLoader()`方法，传入 `ClassLoader`对象的实例。
> - 与上面的类似，如果实现了其他 `*.Aware`接口，就调用相应的方法。
> - 如果有和加载这个 Bean 的 Spring 容器相关的 `BeanPostProcessor` 对象，执行`postProcessBeforeInitialization()` 方法
> - 如果Bean实现了`InitializingBean`接口，执行`afterPropertiesSet()`方法。
> - 如果 Bean 在配置文件中的定义包含 init-method 属性，执行指定的方法。
> - 如果有和加载这个 Bean的 Spring 容器相关的 `BeanPostProcessor` 对象，执行`postProcessAfterInitialization()` 方法，<font color='red'>这里可以进行代理(事务、AOP)，返回代理对象。</font>
> - 当要销毁 Bean 的时候，如果 Bean 实现了 `DisposableBean` 接口，执行 `destroy()` 方法。
> - 当要销毁 Bean 的时候，如果 Bean 在配置文件中的定义包含 destroy-method 属性，执行指定的方法。

![image-20191226135002898](../PicSource/image-20191226135002898.png)



<font color='red'>**实例化A时需要依赖B，则进入实例化B的流程**</font>

![img](../PicSource/bean注入依赖过程.png)



<font color='red'>**setter注入可解决循环依赖，构造器注入不可以**</font>

![img](../PicSource/循环依赖.png)



------



## Bean的作用域

![img](../PicSource/1188352-20200114192052236.jpg)

