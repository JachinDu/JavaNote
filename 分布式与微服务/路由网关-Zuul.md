# 路由网关-Zuul

## 1、为什么需要网关

**<font color='gree' size = 5>*一个处理非业务类服务的绝佳场所*</font>**

------

![image-20200106195830754](../PicSource/image-20200106195830754.png)

**<font color='red'>统一接收前端请求，并配置到后端各服务的转发规则</font>**



## 2、Zuul特点

> - 就是一系列过滤器Filter：<font color='red'>***前置(Pre)、后置(Post)、路由(Route)、错误(Error)四种类型的过滤器API***</font>
> - **<font color='red'>路由器 + 过滤器 = Zuul</font>**
> - **<font color='red'>注册多实例到eureka实现高可用</font>**



过滤器：每种类型的过滤器都有很多种实现

> - **<font color='gree' size=4.5>Pre：限流、鉴权、参数校验调整</font>**
> - Post：统计、日志

------



## 3、简单使用

### 1) 创建工程



![image-20200106210434078](../PicSource/image-20200106210434078.png)

------



### 2）启动类加==`@EnableZuulProxy`==注解



### 3）即可简单使用

先看一下有哪些应用注册到了eureka：

![image-20200106210736852](../PicSource/image-20200106210736852.png)



通过网关(9000端口) 访问product应用中的/product/list接口：

`http://localhost:9000/product/product/list`即可成功调用

> - **<font color='red'>其中，第一个product是应用名，可通过yml配置自定义，详见下一节。</font>**
>
> - 可以通过访问:==`http://localhost:9000/actuator/routes`==可以查看所有可访问应用：
>
>   ![image-20200106211131537](../PicSource/image-20200106211131537.png)



------



### 3）bootstrap.yml初步个性化配置

```yml
spring:
  rabbitmq:
    host: 39.106.177.45
    port: 5672
    username: guest
    password: guest
  application:
    name: api-jachin_gateway
  cloud:
    config:
      discovery:
        enabled: true
        service-id: JACHIN_CONFIG
      profile: dev
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka
      
zuul:
	# 配置1:
  routes:
    myProduct: #可以自定义，只是个规则名而已
      path: /myProduct/** # 这个就是个性化访问路径名，代替应用名
      serviceId: product # 被代替的应用名，
  #配置2:
  ignored-patterns:
    - /product/product/listForOrder
    - /myProduct/product/listForOrder
#    - /**/product/listForOrder 通配符

```

> - 配置1：可以通过问`http://localhost:9000/myProduct/product/list`接口就可以实现对product应用的/product/list接口的调用。
> - <font color='red'>配置2：配置要对客户端屏蔽的应用接口，因为配置1，所以现在对网关有两种请求方式都可以访问到应用的listForOrder接口，故要将两个访问路径都屏蔽，所以可以通过通配符写法，更加简洁。客户端访问被屏蔽的路径，会**==返回404==**。</font>



------



## 4、配置过滤器

创建一个过滤器类，继承`ZuulFilter`类，并实现其所有方法，如下：

```java
package com.jachincloud.apigateway.filter;

/**
 * @description:
 * @Author: JachinDo
 * @Date: 2020/01/06 21:30
 */
@Component
public class TokenFilter extends ZuulFilter {
    // 指定过滤器类型
    @Override
    public String filterType() {
        return PRE_TYPE; // 前置过滤器
    }

    // 过滤器优先级，越小越优先
    @Override
    public int filterOrder() {
        // 相当于优先于PRE_DECORATION_FILTER_ORDER类型的前置过滤器
        return PRE_DECORATION_FILTER_ORDER - 1;
    }

    // 是否开启过滤
    @Override
    public boolean shouldFilter() {
        return true;
    }

    // 过滤器逻辑
    @Override
    public Object run() throws ZuulException {
        RequestContext currentContext = RequestContext.getCurrentContext();
        HttpServletRequest request = currentContext.getRequest();

        // 这里从url中获取，也可以从cookie、header中获取，从cookie中获取要先配置禁止敏感头过滤
        // 因为默认是会过滤掉前端传来的cookie
        String token = request.getParameter("token");
        if (StringUtils.isEmpty(token)) {
            currentContext.setSendZuulResponse(false); // 表示请求不通过
            currentContext.setResponseStatusCode(HttpStatus.UNAUTHORIZED.value()); // 设置响应状态码
        }
        return null;
    }
}
```

> **<font color='red'>这里是配置的前置过滤器，所以通过`RequestContext`获得请求，若是后置过滤器，可以通过`RequestContext`获得响应，进行相关加工。</font>**





## 5、限流

限流概念参考：https://mp.weixin.qq.com/s/08qtprGeWqb1wFz-5AcvoQ

**控制请求速率，放在进入zuul的第一步进行**

**令牌桶限流：**

![image-20200107161221488](../PicSource/image-20200107161221488.png)

------

实现：

> ==直接用google的组件 RateLimiter==

```java
package com.jachincloud.apigateway.filter;

/**
 * @description: 限流
 * @Author: JachinDo
 * @Date: 2020/01/07 16:14
 */
@Component
public class RateLimitFilter extends ZuulFilter {

    // 直接用google的组件 RateLimiter
    private static final RateLimiter RATE_LIMITER = RateLimiter.create(100); // 每秒钟放几个令牌

    @Override
    public String filterType() {
        return PRE_TYPE;  // 限流，肯定要最高优先类型
    }

    @Override
    public int filterOrder() {
        return SERVLET_DETECTION_FILTER_ORDER - 1; // 要比最高优先级还要小
    }

    @Override
    public boolean shouldFilter() {
        return true;
    }

    @Override
    public Object run() throws ZuulException {
        if (!RATE_LIMITER.tryAcquire()) { // 尝试获取令牌
            throw new RateLimitException(); // 抛出自定义异常，或作其他返回给前端
        }
        return null;
    }
}
```



### &sect; 漏桶限流与令牌桶限流的区别

**漏桶只能以==固定的速率==去处理请求，而令牌桶可以以桶子==最大的令牌数去处理请求==**