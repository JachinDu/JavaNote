# Spring Boot自动化配置

<font color='red' size = 4>**@SpringBootApplication &rArr; @EnableAutoConfiguration &rArr; @Import &rArr; AutoConfigurationImportSelector类 &rArr; 筛选XXXAutoConfiguration &rArr; @ConfigurationProperties结合配置文件完成配置**</font>

------

## &sect; @EnableAutoConfiguration注解

```java
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@AutoConfigurationPackage
@Import({AutoConfigurationImportSelector.class})
public @interface EnableAutoConfiguration {
    String ENABLED_OVERRIDE_PROPERTY = "spring.boot.enableautoconfiguration";

    Class<?>[] exclude() default {};

    String[] excludeName() default {};
}

```

其中最重要的是第6行：

```java
@Import({AutoConfigurationImportSelector.class})
```

<font color='red'>导入了`AutoConfigurationImportSelector`自动配置的选择器的类</font>

其中的一些方法会筛选出要自动配置的类开启自动配置：<font color='yellow' size = 4>***XXXAutoConfiguration，这些都在引入的依赖jar中***</font>

以`ServletWebServerFactoryAutoConfiguration`为例：

```java
@Configuration // 配置类
@AutoConfigureOrder(Ordered.HIGHEST_PRECEDENCE)
//判断当前项目有没有这个类
//CharacterEncodingFilter；SpringMVC中进行乱码解决的过滤器；
@ConditionalOnClass(ServletRequest.class)
//Spring底层@Conditional注解（Spring注解版），根据不同的条件，如果
//满足指定的条件，整个配置类里面的配置就会生效； 判断当前应用是否是web应用，如果是，当前配置类生效
@ConditionalOnWebApplication(type = Type.SERVLET)
@EnableConfigurationProperties(ServerProperties.class)
@Import({ ServletWebServerFactoryAutoConfiguration.BeanPostProcessorsRegistrar.class,
        ServletWebServerFactoryConfiguration.EmbeddedTomcat.class,
        ServletWebServerFactoryConfiguration.EmbeddedJetty.class,
        ServletWebServerFactoryConfiguration.EmbeddedUndertow.class })
public class ServletWebServerFactoryAutoConfiguration {
```

需要注意的是 `@EnableConfigurationProperties(ServerProperties.class)`.他的意思是启动指定类的`ConfigurationProperties`功能；将配置文件中对应的值和 `ServerProperties` 绑定起来；并把`ServerProperties` 加入到 IOC 容器中。

再来看一下 `ServerProperties` .

```java
@ConfigurationProperties(prefix = "server", ignoreUnknownFields = true)
public class ServerProperties {
    /**
     * Server HTTP port.
     */
    private Integer port;
```

显而易见了，<font color='yellow' size = 4>***这里使用 ConfigurationProperties 绑定属性映射文件中的 server 开头的属性。***</font>

------

### 自动配置总结

1. SpringBoot 启动的时候加载主配置类，开启了自动配置功能 @EnableAutoConfiguration 。
2. <font color='red'>***@EnableAutoConfiguration 给容器导入META-INF/spring.factories 里定义的自动配置类。***</font>
3. ==筛选有效的自动配置类。==
4. <font color='red'>***每一个自动配置类结合对应的 xxxProperties.java 读取配置文件进行自动配置功能 。***</font>

------

## &sect; @Configuration和@Component注解区别

> - @Configuration标注在类上，相当于把该类作为spring的xml配置文件中的\<bean>，作用为：==配置spring容器(应用上下文)==，内部可以使用@Bean注解定义一些bean，<font color='red' size = 5>***无需扫描！！！***</font>
>
>   Bean类：
>
>   ```java
>   public class TestBean {
>   
>       public void sayHello(){
>           System.out.println("TestBean sayHello...");
>       }
>   
>       public String toString(){
>           return "username:"+this.username+",url:"+this.url+",password:"+this.password;
>       }
>   
>       public void start(){
>           System.out.println("TestBean 初始化。。。");
>       }
>   
>       public void cleanUp(){
>           System.out.println("TestBean 销毁。。。");
>       }
>   }
>   ```
>
>   配置类：
>
>   ```java
>   @Configuration
>   public class TestConfiguration {
>           public TestConfiguration(){
>               System.out.println("spring容器启动初始化。。。");
>           }
>   
>   //@Bean注解注册bean,同时可以指定初始化和销毁方法    //@Bean(name="testNean",initMethod="start",destroyMethod="cleanUp")
>       @Bean
>       @Scope("prototype")
>       public TestBean testBean() {
>         	// 这里调用Bean类的构造函数
>           return new TestBean();
>       }
>   }
>   ```
>
>   
>
> - @Component：标注在类上，<font color='red'>**需在@Configuration所在类加上@ComponentScan，即可自动将其添加为bean**</font>，不用在内部使用@Bean添加。
>
>   Bean类：
>
>   ```java
>   //添加注册bean的注解
>   @Component
>   public class TestBean {
>   
>       public void sayHello(){
>           System.out.println("TestBean sayHello...");
>       }
>   
>       public String toString(){
>           return "username:"+this.username+",url:"+this.url+",password:"+this.password;
>       }
>   }
>   ```
>
>   配置类：
>
>   ```java
>   @Configuration
>   //添加自动扫描注解，basePackages为TestBean包路径
>   @ComponentScan(basePackages = "com.test.spring.support.configuration")
>   public class TestConfiguration {
>     // 已经自动将@Component标注的添加为bean了
>       public TestConfiguration(){
>           System.out.println("spring容器启动初始化。。。");
>       }
>   }
>   ```

------



## &sect; @Bean和@Component

> - <font color='red'>***@Bean是作用于方法，方法定义在@Configuration标注的类中，将方法的返回值作为bean添加到容器中，并且可设置多种参数。***</font>
> - @Component作用于类，需要配合@ComponentScan扫描才能添加到容器

