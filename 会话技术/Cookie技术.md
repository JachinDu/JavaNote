# Cookie技术

<mark>会话数据保存在浏览器客户端</mark>

<mark>只能保存非中文</mark>

## 1、cookie技术核心

Cookie类：用于存储会话数据

 1）构造Cookie对象

​       `Cookie(java.lang.String name, java.lang.String value)`

2）设置cookie

​       `void setPath(java.lang.String uri) `  ：设置cookie的有效访问路径

​       `void setMaxAge(int expiry) `： 设置cookie的有效时间

​       `void setValue(java.lang.String newValue)` ：设置cookie的值

3）发送cookie到浏览器端保存

​      ` void response.addCookie(Cookie cookie)`  : 发送cookie

4）服务器接收cookie

​      `Cookie[] request.getCookies()`  : 接收cookie



## 2、cookie原理



> 1）服务器创建cookie对象，把会话数据存储到cookie对象中。
>
> 2）服务器发送cookie信息到浏览器
>
> 3）浏览器得到服务器发送的cookie，然后保存在浏览器端。
>
> 4）<mark>浏览器在下次访问服务器时，会带着cookie信息</mark>
>
> 5）服务器接收到浏览器带来的cookie信息

​                            

```java
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //1.创建cookie对象
        Cookie cookie = new Cookie("name", "eric");

        //2.把cookie数据发送到浏览器
        //通过响应头发送：set-cookie名称
        response.addCookie(cookie);

        //3.接收浏览器发送到cookie信息
//        String name = request.getHeader("cookie");
//        System.out.println(name);
        Cookie[] cookies = request.getCookies();
        //判断null
        if (cookies != null) {
            for (Cookie c : cookies) {
                String name = c.getName();
                String value = c.getValue();
                System.out.println(name + "=" + value);
            }
        } else {
            System.out.println("没有接收到cookie数据");
        }
    }
```



## 3、cookie有效路径

1）void setPath(java.lang.String uri) 
 ：<mark>设置cookie的有效访问路径。有效路径指的是cookie的有效路径保存在哪里，那么浏览器在有效路径下访问服务器时就会带着cookie信息，否则不带cookie信息。</mark>



工程(web应用)day11下的ServletCookieDemo1.java：

```java
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //1.创建cookie对象
        Cookie cookie1 = new Cookie("name", "eric");
        Cookie cookie2 = new Cookie("email", "jiachegn@fjds.com");


        /*
         * 1）设置cookie有效路径。
         *    默认在当前web应用下：/day11
         * */
        cookie2.setPath("/day12");

        //2.把cookie数据发送到浏览器
        //通过响应头发送：set-cookie名称
        response.addCookie(cookie1);
        response.addCookie(cookie2);


        //3.接收浏览器发送到cookie信息
        Cookie[] cookies = request.getCookies();
        //判断null
        if (cookies != null) {
            for (Cookie c : cookies) {
                String name = c.getName();
                String value = c.getValue();
                System.out.println(name + "=" + value);
            }
        } else {
            System.out.println("没有接收到cookie数据");
        }
    }
```

两个缓存中，继续访问<http://localhost:8080/day11/ServletCookieDemo1>，只有name缓存会带到request中传给服务器，因为当前url中路径为day11，只有访问day12的应用时，才会将email缓存带入request中。



## 4、cookie有效时间

2）void setMaxAge(int expiry) ： 设置cookie的有效时间。

​        正整数：表示cookie数据保存浏览器的缓存目录（硬盘中），数值表示保存的时间，==有效时间内浏览器重启不影响。==

​        负整数：表示cookie数据保存浏览器的内存中。==浏览器关闭cookie就丢失了！！==

​        零：表示删除同名的cookie数据

```java
cookie1.setMaxAge(5);//20s：从最后不调用cookie开始计算

//删除同名cookie（使立刻过期）
Cookie cookie = new Cookie("name","xxxx");
cookie.setMaxAge(0);
response.addCookie(cookie);
```



案例一：用户上次访问时间

​		day11/ServletHistory.java

案例二：用户上次浏览过的商品



## 5、（*）案例：用户浏览商品

见IdeaProject/day11product



