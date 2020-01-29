# JWT(Json Web Token)技术

参考：https://cnodejs.org/topic/5b0c4a7b8a4f51e140d942fc



## 0、JWT与session流程对比

### &sect; session

1. 浏览器发起请求登陆
2. 服务端验证身份，**<font color='red'>生成身份验证信息，存储在服务端</font>**，并且告诉浏览器**写入 Cookie**
3. 浏览器发起请求获取用户资料，此时 Cookie 内容也跟随这发送到服务器
4. 服务器发现 Cookie 中有身份信息，验明正身
5. 服务器返回该用户的用户资料

------

### &sect; JWT

1. 浏览器发起请求登陆
2. 服务端验证身份，<font color='red'>**根据算法，将用户标识符打包生成 token, 并且返回给浏览器(服务器不做存储)**</font>
3. 浏览器发起请求获取用户资料，把刚刚拿到的 token 一起发送给服务器
4. **服务器发现数据中有 token，==验明正身==**
5. 服务器返回该用户的用户资料

------

### &sect; 区别

1. session 存储在服务端占用服务器资源，而 JWT 存储在客户端
2. session 存储在 Cookie 中，存在**伪造跨站请求伪造攻击**的风险
3. session 只存在一台服务器上，那么下次请求就必须请求这台服务器，不利于分布式应用
4. 存储在客户端的 JWT 比存储在服务端的 session <font color='red'>**更具有扩展性**</font>

------



## 1、JWT原理

![Token Based Authentication flow](../PicSource/Token-Based-Authentication-20200114191941819.png)

> 1. 用户向服务器发送用户名和密码用于登陆系统。
> 2. 身份验证服务响应并返回了签名的 JWT，上面**<font color='red'>包含了用户是谁的内容。</font>**
> 3. 用户以后每次向后端发请求都在Header中带上 JWT。
> 4. 服务端检查 JWT 并从中获取用户相关信息。



## 3、JWT格式

首先 JWT 长这个样

```
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpcCI6IjEyNy4wLjAuMSIsInV1aWQiOiJmZjEyMTJmNS1kOGQxLTQ0OTYtYmY0MS1kMmRkYTczZGUxOWEiLCJpYXQiOjE1Mjc1MjMwMTd9.1C01cpOf1N3M9YAYvQjfcLbDGHZ4iPVncCGIoG-lpO0jHOIA_ZHtSMDvK1nzArLpGK5syQSwExsZJz2FJsd2W2TUiHQYtzmQTU8OBXX6mfSZRlkts675W5_WhIiOEwz69GFSD0AKXZifCRgIpKLC0n273MRMr0wJnuBi9ScfJ7YjSiqCr7qyQ5iXeOdS3ObT3wdjjk-Wu9wbWM7R25TFb-7PEZY7r_e8jmczPCVcNbOYegedu73T4d30kRn2jKufTGntD5hR6T9AQsgAMwVR1edEFflWb772TmrHI7WZOAivsBCN9sr4YiyYMvE8lcz_mBsgsunugGiHA3DGxB2ORbjIC8NPm8FI25zGOh9JIM2r_jFFTIm9GiuKtC8Ck8N3-eWi9u1NgBxwLdgN5JyCORnIOlciQEsScg-3SdCTM5LH_j6CeqQNwJxT4-oENzqLSTDJbP-SOj9nnx8HnJ5wh3n64rAvtc89CeTk7PhWFjksHDifngN-cnaszl5lqoF1enz5i9FYYELSjM-G7jns2SyY1MQeLRjuEDriPZtFaGmTW-RLH3gJfQXtbdpEo0_nHBqXEohwoN_FLKo4BNrEwshpyA7vkBpCQC0QALKyC1_L1Q5qduR6dDcqRozAo2VqJXmAKN0rvhLuIEHZkicOZY0Ds4So4GCcleqvFcxm1HQ
```

眼睛看仔细一些，你会发现 JWT 里面有两个`.`

数据格式是这样的**<font color='red'> `header.payload.signature`</font>**

------

### &sect; Header

JWT 的 header 中承载了两部分信息

```json
{
  "alg": "RS256",
  "typ": "JWT"
}
```

- **alg**: <font color='red'> **声明加密的算法**</font>
- **typ**: 声明类型

对这个头部信息进行 <font color='red'> **base64**</font>，即可得到 header 部分

```js
const headerBuff = Buffer.from(
  JSON.stringify({
    alg: "RS256",
    typ: "JWT"
  })
);

const header = headerBuff.toString("base64");

console.log(header);
// eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9
```

------



### &sect; Payload

payload 是主体部分，意为载体，承载着有效的 JWT 数据包，它包含三个部分

> - 标准声明：
>
>   ```typescript
>   interface Stantar {
>     iss?: string; // JWT的签发者
>     sub?: string; // JWT所面向的用户
>     aud?: string; // 接收JWT的一方
>     exp?: number; // JWT的过期时间
>     nbf?: number; // 在xxx日期之间，该JWT都是可用的
>     iat?: number; // 该JWT签发的时间
>     jti?: number; //JWT的唯一身份标识
>   }
>   ```
>
>   标准中建议使用这些字段，但不强制。
>
> - 公共声明：
>
>   ```typescript
>   interface Public {
>     [key: string]: any;
>   }
>   ```
>
>   公共声明字段可以添加任意信息，但是因为<font color='red'>**可以被解密出来，所以不要存放敏感信息**。</font>
>
> - 私有声明：
>
>   ```typescript
>   interface Private {
>     [key: string]: any;
>   }
>   ```
>
>   私有声明是 JWT 提供者添加的字段，一样可以被解密，所以也不能存放敏感信息。
>
> **上面的 JWT 的 payload 结构是这样的：**
>
> ```json
> {
>   // 公共声明字段
>   "ip": "127.0.0.1",
>   "uuid": "ff1212f5-d8d1-4496-bf41-d2dda73de19a",
>   // 可选标准声明
>   "iat": 1527523017
> }
> ```
>
> 同样是通过 base64 加密生成第二部分的 payload
>
> ```js
> const payloadBuffer = Buffer.from(
>   JSON.stringify({
>     ip: "127.0.0.1",
>     uuid: "ff1212f5-d8d1-4496-bf41-d2dda73de19a",
>     iat: 1527523017
>   })
> );
> 
> const payload = payloadBuffer.toString("base64");
> 
> console.log(payload);
> // eyJpcCI6IjEyNy4wLjAuMSIsInV1aWQiOiJmZjEyMTJmNS1kOGQxLTQ0OTYtYmY0MS1kMmRkYTczZGUxOWEiLCJpYXQiOjE1Mjc1MjMwMTd9
> ```

------



### &sect; Signature

signature 是签证信息，该签证信息是通过`header`和`payload`，加上`secret`，通过算法加密生成。

公式 **<font color='red' size=5>`signature = 加密算法(header + "." + payload, 密钥);`</font>**

上面的 header 中，我们已经定义了加密算法使用 `RS256`，也已经实现了生成`header`和`payload`，下面我们来生成 signature:

```js
const crypto = require("crypto");
const sign = crypto.createSign("SHA256");
const secret = `私钥，太长我就不贴出来了`;

sign.write(header + "." + payload);
sign.end();

const signature = sign
  .sign(secret, "base64")
  // 在JWT库中，已经把这些字符过滤掉了
  .replace(/=/g, "")
  .replace(/\+/g, "-")
  .replace(/\//g, "_");

console.log(signature);
```

到此，已经实现了如何生成一个 JWT 的 token。

------



#### &sect; 它是如何做身份验证的？

- 首先，**<font color='red'>JWT 的 Token 相当于是明文，是可以解密的(base64)，任何存在 payload 的东西，都没有秘密可言，所以隐私数据不能签发 token。</font>**

- **而服务端，拿到 token 后解密，即可知道用户信息，例如本例中的`uuid`**

- 有了 `uuid`，那么你就知道这个用户是谁，**是否有权限进行下一步的操作。**

------



#### &sect; Token过期时间怎么确定？

payload 中有个标准字段 `exp`，明确表示了这个 token 的过期时间.

服务端可以拿这个时间与服务器时间作对比，过期则拒绝访问。

------



#### &sect; 如何防止Token被篡改

此时 `signature`字段就是关键了，能被解密出明文的，只有`header`和`payload`

假如黑客/中间人串改了`payload`，那么服务器可以通过`signature`去验证是否被篡改过。

**<font color='red'>*在服务端在执行一次 `signature = 加密算法(header + "." + payload, 密钥);`, 然后对比 signature 是否一致，如果一致则说明没有被篡改。*</font>**

所以为什么说服务器的密钥不能被泄漏。

如果泄漏，将存在以下风险:

- 客户端可以自行签发 token
- 黑客/中间人可以肆意篡改 token

------



#### &sect; 如何加强 JWT 的安全性？

1. 缩短 token 有效时间
2. 使用安全系数高的加密算法
3. token 不要放在 Cookie 中，有 CSRF 风险
4. 使用 HTTPS 加密协议
5. 对标准字段 iss、sub、aud、nbf、exp 进行校验
6. 使用成熟的开源库，不要手贱造轮子
7. 特殊场景下可以把用户的 UA、IP 放进 payload 进行校验(不推荐)

------



## 2、Token优点

> 1. 避免CSRF（跨站请求伪造）攻击
>
>    那么究竟什么是 **跨站请求伪造** 呢？说简单用你的身份去发送一些对你不友好的请求。举个简单的例子：
>
>    小壮登录了某网上银行，他来到了网上银行的帖子区，看到一个帖子下面有一个链接写着“科学理财，年盈利率过万”，小壮好奇的点开了这个链接，结果发现自己的账户少了10000元。这是这么回事呢？原来黑客在链接中藏了一个请求，这个请求直接利用小壮的身份给银行发送了一个转账请求,也就是通过你的 Cookie 向银行发出请求。
>
> 2. 适合移动端应用
>
>    使用 Session 进行身份认证的话，需要保存一份信息在服务器端，而且这种方式会==依赖到 Cookie（需要 Cookie 保存 SessionId），而Cookie又依赖于浏览器==，所以不适合移动端。
>
>    ==**但是，使用 token 进行身份认证就不会存在这种问题，因为只要 token 可以被客户端存储就能够使用(通过header)，而且 token 还可以跨语言使用。**==
>
> 3. 单点登录友好
>
>    使用 Session 进行身份认证的话，实现单点登录，需要我们把用户的 Session 信息保存在一台电脑上，并且还会遇到常见的 Cookie 跨域的问题。但是，使用 token 进行认证的话， token 被保存在客户端，不会存在这些问题。

