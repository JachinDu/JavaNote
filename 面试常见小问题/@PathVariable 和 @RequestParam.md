# @PathVariable 和 @RequestParam

https://www.cnblogs.com/goloving/p/9241393.html

**RequestParam**  汉语意思就是： **请求参数**。顾名思义 就是获取参数的

**PathVariable** 汉语意思是：**路径变量**。顾名思义，就是要获取一个url 地址中的一部分值，那一部分呢？

　　RequestMapping 上说明了@RequestMapping(value="/emp/**{id}**"），我就是想获取你URL地址 /emp/ 的后面的那个 {id}的

**@PathVariable是用来获得请求url中的动态参数的**



## @pathVariable和RequestParam的区别：

顾名思义，前者是从路径中获取变量，也就是把路径当做变量，后者是从请求里面获取参数，从请求来看：

​	 ==`/Springmvc/user/page.do?pageSize=3&pageNow=2`==

　　`pageSize`和`pageNow`应该是属于参数而不是路径，所以应该添加`@RequestParam`的注解。

　　如果做成如下URL，则可以使用`@PathVariable`

　　==`someUrl/{paramId}`==，这里的`paramId`是路径中的变量，应使用`@pathVariable`