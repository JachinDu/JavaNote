# Session技术

Session特点：会话数据保存在服务器端（内存）

HttpSession类：保存会话数据

## 1、原理





![Session Based Authentication flow](../PicSource/Session-Based-Authentication-flow-20200114191949075.png)



1）第一次访问创建session对象，给session对象分配一个唯一的ID，叫<mark>JSESSIONID</mark>

​                                   new HttpSession();

2）把JSESSIONID作为Cookie的值发送给浏览器保存

​            Cookie cookie = new Cookie("JSESSIONID", sessionID);

​            response.addCookie(cookie);

3）第二次访问的时候，浏览器带着JSESSIONID的cookie访问服务器

 4）服务器得到JSESSIONID，在服务器的内存中搜索是否存放对应编号的session对象。

​                                   if(找到){

​                                          return map.get(sessionID);

​                                   }

​                                   Map<String,HttpSession>]

 

 

​                                   <"s001", s1>

​                                   <"s001,"s2>

5）如果找到对应编号的session对象，直接返回该对象

6）如果找不到对应编号的session对象，创建新的session对象，继续走1的流程

​       

结论：通过JSESSION的cookie值在服务器找session对象！！！！！



## 2、核心api



request.getSession();

setAttrbute("name","会话数据");

getAttribute("会话数据")



如何避免浏览器的JSESSIONID的cookie随着浏览器关闭而丢失的问题：

```java
/**
		 * 手动发送一个硬盘保存的cookie给浏览器
		 */
		Cookie c = new Cookie("JSESSIONID",session.getId());
		c.setMaxAge(60*60);
		response.addCookie(c);

```



## 3、用户登录案例

登陆界面:login.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>登陆页面</title>
</head>
<body>
<!--密码有敏感数据-->
    <form action="/day12/ServletLogin" method="post">
        用户名：<input type="text" name="userName"/>
        <br/>
        密码：<input type="text" name="userPwd"/>
        <br/>
        <input type="submit" value="登陆"/>
    </form>
</body>
</html>
```



登陆失败界面:fail.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>信息提示页面</title>
</head>
<body>
    <font color="red" size="3">亲，你的用户名或密码输入有误，请重新输入！</font>
    <a href="/day12/login.html">返回登陆页面</a>
</body>
</html>
```



登陆处理逻辑:ServletLogin.java

```java
package login_servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.sql.rowset.serial.SerialStruct;
import java.io.IOException;

/*
* 处理登陆逻辑
* */
@WebServlet(name = "ServletLogin",urlPatterns = "/ServletLogin")
public class ServletLogin extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request,response);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");
        //1.接收表带提交的参数
        String userName = request.getParameter("userName");
        String userPwd = request.getParameter("userPwd");

        //2.判断逻辑
        if ("eric".equals(userName) && "123456".equals(userPwd)) {
            //登陆成功
            /*
            * 把用户数据保存在session中
            * */
            //1.创建session
            HttpSession session = request.getSession();
            //2.把数据保存到session域中
            session.setAttribute("loginName",userName);
            //3.跳转到用户主页
            response.sendRedirect(request.getContextPath()+"/ServletIndex");

        } else {
            //登陆失败
            //请求重定向
            response.sendRedirect(request.getContextPath()+"/fail.html");
        }

    }
}

```



用户主页显示及逻辑:ServletIndex.java

```java
package login_servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "ServletIndex",urlPatterns = "/ServletIndex")
public class ServletIndex extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request,response);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=utf-8");
        PrintWriter writer = response.getWriter();
        String html = "";

        //从session域中获取会话数据
        //1.得到session对象
        HttpSession session = request.getSession(false);
        if (session == null) {
            //没有登陆成功,跳转回登陆页面
            response.sendRedirect(request.getContextPath() + "/login.html");
            return;
        }
        //2.取出会话数据
        String loginName = (String)session.getAttribute("loginName");
        //判断是否存在指定属性（登陆信息）
        if (loginName == null) {
            //没有登陆成功,跳转回登陆页面
            response.sendRedirect(request.getContextPath() + "/login.html");
            return;
        }

        html = "<html><body>欢迎回来，"+loginName+" <a href='"+request.getContextPath()+"/ServletLogout'>安全退出</a></body></html>";
        writer.write(html);
    }
}

```



用户安全退出:ServletLogout.java

```java
package login_servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "ServletLogout",urlPatterns = "/ServletLogout")
public class ServletLogout extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request,response);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        /*
        * 安全退出：
        *        删除掉session对象中的loginName属性，而不是删掉整个session
        * */
        //1.得到session
        HttpSession session = request.getSession(false);
        if (session != null) {
            //2.删除属性
            session.removeAttribute("loginName");
        }
        //3.回到登陆页面
        response.sendRedirect(request.getContextPath()+"/login.html");
    }
}

```



## 4、session与cookie的区别



Cookie 和 Session都是用来跟踪浏览器用户身份的会话方式，但是两者的应用场景不太一样。

- **Cookie 一般用来保存用户信息** 比如①我们在 Cookie 中保存已经登录过得用户信息，==下次访问==网站的时候页面可以自动帮你登录的一些基本信息给==填了==；②一般的网站都会有保持登录也就是说下次你再访问网站的时候就不需要重新登录了，这是因为用户登录的时候我们可以存放了一个 Token 在 Cookie 中，下次登录的时候只需要根据 Token 值来查找用户即可(为了安全考虑，重新登录一般要将 Token 重写)；③登录一次网站后访问网站其他页面不需要重新登录。

- **Session 的主要作用就是通过服务端记录==用户的状态==。** 典型的场景是==购物车==，当你要添加商品到购物车的时候，系统不知道是哪个用户操作的，因为 ==HTTP 协议是无状态==的。服务端给特定的用户创建特定的 Session 之后就可以标识这个用户并且==跟踪==这个用户了。

**Cookie 数据保存在客户端(浏览器端)，Session 数据保存在服务器端。**

Cookie 存储在客户端中，而Session存储在服务器上，相对来说 Session 安全性更高。如果要在 Cookie 中存储一些敏感信息，不要直接写入 Cookie 中，最好能将 Cookie 信息加密然后使用到的时候再去服务器端解密。



1. 我们在 Cookie 中保存已经登录过得用户信息，下次访问网站的时候页面可以自动帮你登录的一些基本信息给填了。除此之外，Cookie 还能保存用户首选项，主题和其他设置信息。
2. 使用Cookie 保存 session 或者 token ，向后端发送请求的时候带上 Cookie，这样后端就能取到session或者token了。这样就能记录用户当前的状态了，因为 HTTP 协议是无状态的。
3. Cookie 还可以用来记录和分析用户行为。举个简单的例子你在网上购物的时候，因为HTTP协议是没有状态的，==如果服务器想要获取你在某个页面的停留状态或者看了哪些商品，一种常用的实现方式就是将这些信息存放在Cookie==