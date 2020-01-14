# aop与卖家端身份验证





> 项目案例：微信点餐
>
> 需求：
>
> ​		登录验证：在访问任何后端管理页面时均需要验证后端商家用户的登录状态，即检查cookie中是否有相应的token。（视频12章内容）
>
> ​			![image-20190827173319525](/Users/jc/Library/Application Support/typora-user-images/image-20190827173319525.png)



## 实现方式：AOP

### 流程：

> 1. 设置切点，当pc端要访问一些接口时，要检查redis或cookie中有无用户信息，有则无事，无则继续下面步骤。**<font color='red'>先检查cookie中有无token，有则拿着token作为key去redis中找value。哪一步查不到都直接抛异常。</font>**
> 2. 若redis和cookie中都无，则抛出一个异常，该异常被全局异常处理捕获。
> 3. 捕获后，重定向到微信扫码登录界面。
> 4. 扫码登录流程类似于微信网页授权（最终拿个openid来返回我们设置的重定向地址）。
> 5. 重定向的接口会到数据库查找有无匹配openid，若无，登录失败。若有，设置redis缓存和cookie。
> 6. 成功后返回商品列表。



其中，设置redis和cookie细节如下：

### 1、设置redis

首先产生一个唯一的token作为key。

```
String token= UUID.randomUUID().toString();
```

然后以==（token,openid）==这样的key、value对保存到redis中。

### 2、设置cookies

设置token到cookie中。

```
CookieUtil.set(response, CookieConstant.TOKEN,token,expire);
```

这样就把`（CookeiConstant.TOKEN,token）`这样的key、value对保存的了用户的cookie中了。





```java
package com.jachin.sell.aspect;

/**
 * @description:
 * @Author: JachinDo
 * @Date: 2019/08/27 16:58
 */
@Aspect
@Component
@Slf4j
public class SellerAuthorizeAspect {

    @Autowired
    private StringRedisTemplate redisTemplate;


    @Pointcut("execution(public * com.jachin.sell.controller.Sell*.*(..))" +
    "&& !execution(public * com.jachin.sell.controller.SellerUserController.*(..))")
    public void vertify() {

    }

    @Before("vertify()")
    public void doVertify() {
        // 1. 获取request
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        HttpServletRequest request = attributes.getRequest();

        // 2. 查询cookie
        Cookie cookie = CookieUtil.get(request, CookieConstant.TOKEN);
        if (cookie == null) {
            log.warn("【登录校验】Cookie中查不到token");
            throw new SellerAuthorizeException();
        }

        // 3. 查询redis
        String tokenValue = redisTemplate.opsForValue().get(String.format(RedisConstant.TOKEN_PREFIX, cookie.getValue()));
        if (StringUtils.isEmpty(tokenValue)) {
            log.warn("【登录校验】Redis中查不到token");
            throw new SellerAuthorizeException();
        }

    }
}
```

> 注意：
>
> 1. 36行切入点@Pointcut：
>
>    使用execution表达式划分切入范围，即需要验证的范围，具体表达式语法网上有很多。此处因为后端管理各页面controller类均以Sell开头，除了用户登录登出controller，所以!execution用来排出不切入的点。
>
>    ==作用：当程序执行到对应切入范围，则执行@Pointcut所标注的方法，此处为vertify()==
>
> 2. 42行@Before("vertify()")，意为在vertify()执行前的操作。这里就是登录验证的逻辑代码，获取request-->获取cookie-->获取token
>
> 3. 若登录验证失败，即未登录，则抛统一异常，全局异常拦截处理见下文。



## 全局异常拦截处理

上文所用异常定义

```java
package com.jachin.sell.exception;

/**
 * @description:
 * @Author: JachinDo
 * @Date: 2019/08/27 17:15
 */

public class SellerAuthorizeException extends RuntimeException {
}
```



异常拦截处理：

```java
package com.jachin.sell.handler;

import com.jachin.sell.exception.SellerAuthorizeException;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.ModelAndView;

/**
 * @description:
 * @Author: JachinDo
 * @Date: 2019/08/27 17:18
 */
@ControllerAdvice
public class SellExceptionHandler {

    // 拦截登录异常(指明要拦截处理的异常)
    @ExceptionHandler(value = SellerAuthorizeException.class)
    public ModelAndView handlerAuthorizeException() {
        //跳转到登录界面(扫码界面)
        return new ModelAndView("redirect:https://open.weixin.qq.com/connect/qrconnect?appid=wx6ad144e54af67d87&redirect_uri=http%3A%2F%2Fsell.springboot.cn%2Fsell%2Fqr%2FoTgZpwTykQPhdjiI8rWYEgXjWhI8&response_type=code&scope=snsapi_login&state=http%3a%2f%2fjachin2013.natapp1.cc%2fsell%2fwechat%2fqrUserInfo");

    }

}
```



==此处处理异常的方式为返回微信扫码登录页==，关于微信开放平台扫码登录等问题见微信点餐课程doc中的相关文档。

![image-20190827174138015](/Users/jc/Library/Application Support/typora-user-images/image-20190827174138015.png)