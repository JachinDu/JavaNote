# BeanFactory与FactoryBean

## 1、BeanFactory

> `BeanFactory`是一个接口，***它是Spring中工厂的顶层规范***，是SpringIoc容器的核心接口，它定义了`getBean()`、`containsBean()`等管理Bean的通用方法。Spring的容器都是它的具体实现如：

- <font color='#02C874'>**DefaultListableBeanFactory**</font>
- <font color='#02C874'>**XmlBeanFactory**</font>
- <font color='#02C874'>**ApplicationContext**</font>

这些实现类又从不同的维度分别有不同的扩展。

------

## 2、FactoryBean

首先它是一个Bean，但又不仅仅是一个Bean。它是一个能生产或修饰对象生成的工厂Bean，类似于设计模式中的工厂模式和装饰器模式。<font color='#02C874'>***它能在需要的时候生产一个对象，且不仅仅限于它自身，它能返回任何Bean的实例。***</font>



```java
public interface FactoryBean<T> {

	//从工厂中获取bean
	@Nullable
	T getObject() throws Exception;

	//获取Bean工厂创建的对象的类型
	@Nullable
	Class<?> getObjectType();

	//Bean工厂创建的对象是否是单例模式
	default boolean isSingleton() {
		return true;
	}
}
复制代码
```

<font color='#02C874'>***从它定义的接口可以看出，`FactoryBean`表现的是一个工厂的职责。   即一个Bean A如果实现了FactoryBean接口，那么A就变成了一个工厂，根据A的名称获取(getBean(A.name))到的实际上是A调用`getObject()`返回的对象，而不是A本身，如果要获取工厂A自身的实例，那么需要在名称前面加上'`&`'符号。***</font>
```java
@Component
public class MyFactoryBean implements FactoryBean<List<String>>, InitializingBean, DisposableBean {

    private static final Logger logger = LoggerFactory.getLogger(MyFactoryBean.class);

    private String params = "";

    private List<String> list;

    //InitializingBean实现方法
    public void afterPropertiesSet() throws Exception {
        //属性注入完后，调用该方法，该方法可以实现“业务”逻辑。创建出List<String>集合
        String[] split = params.split(",");
        list = Arrays.asList(split);
    }

    public List<String> getObject() throws Exception {
        return list;
    }

    public Class<?> getObjectType() {
        return List.class;
    }

    public boolean isSingleton() {
        return true;
    }

    //[dɪˈspəʊzəbl]（对象销毁的时候会调用 蒂斯跑则报）DisposableBean  接口的实现方法
    public void destroy() throws Exception {
        logger.debug("对象销毁...");
    }

    public String getParams() {
        return params;
    }

    public void setParams(String params) {
        this.params = params;
    }

    public List<String> getList() {
        return list;
    }

    public void setList(List<String> list) {
        this.list = list;
    }
}
```

- getObject('name')返回工厂中的实例
- getObject('&name')返回工厂本身的实例

通常情况下，bean 无须自己实现工厂模式，Spring 容器担任了工厂的 角色；<font color='red' size=4>**但少数情况下，容器中的 bean 本身就是工厂，作用是产生其他 bean 实例。由工厂 bean 产生的其他 bean 实例，不再由 Spring 容器产生。**</font>

------

### 场景


<font color='red' size=4>**FactoryBean在Spring中最为典型的一个应用就是用来创建AOP的代理对象。**</font>

我们知道AOP实际上是Spring在运行时创建了一个代理对象，也就是说这个对象，是我们在运行时创建的，而不是一开始就定义好的，这很符合工厂方法模式。更形象地说，AOP代理对象通过Java的反射机制，在运行时创建了一个代理对象，在代理对象的目标方法中根据业务要求织入了相应的方法。这个对象在Spring中就是——**==`ProxyFactoryBean`。==**

<font color='red' size=4>***所以，FactoryBean为我们实例化Bean提供了一个更为灵活的方式，我们可以通过FactoryBean创建出更为复杂的Bean实例。***</font>

------

## 区别

- <font color='#02C874'>**他们两个都是个工厂，但`FactoryBean`本质上还是一个Bean，也归`BeanFactory`管理**</font>
- <font color='#02C874'>**`BeanFactory`是Spring容器的顶层接口，`FactoryBean`更类似于用户自定义的工厂接口。**</font>

