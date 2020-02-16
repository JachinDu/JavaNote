# Short类型比较的坑

前提约定：

***<font color='red' size=4.5>精度小于int的数值==运算的时候(定义时不会)==都会被自动转换为int后进行计算</font>***

------



```java
short x = 3;
Short s1 = 2;

if (s1.equals(x - 1)) {
  System.out.println("!!!!!");
}
// 输出：null
```

> - 其实，上述定义x，s1时，**<font color='red'>后面的3和2都是int型的</font>**，只是编译器在编译时帮我们自动转换为了对应的short类型。
>
> - 而在运算中编译器不会做上述转换，**<font color='red'>即: x - 1 变为了int 类型</font>**，而Short类型重写的equals方法如下：
>
>   - ***<font color='gree'>!!!目标不是Short类型，直接会返回false</font>***
>
>   ```java
>   public boolean equals(Object obj) {
>       // !!!目标不是Short类型，直接会返回false
>       if (obj instanceof Short) {
>           return value == ((Short)obj).shortValue();
>       }
>       return false;
>   }
>   ```
>
>   因此不会有任何输出。
>
> - 将if中的语句改为`s1.equals((short)(x-1))`即可
>
> - **<font color='red'>因此，在map的使用时，应避免Short为key，若必须要用Short，则要注意这些，否则会出问题</font>**
>
>   如HashMap中remove时对传入的key和map中的元素的对比：
>
>   ```java
>   if (p.hash == hash &&
>       ((k = p.key) == key || (key != null && key.equals(k))))// 其中key为外部传入的经过运算后的Short，为Integer，而k为Short
>   ```
>
>   ***<font color='red'>此时，第2行的 == 判断直接false了，因为Short和Integer类型不能用==比较，而后面equals也为false，所以remove失效了。</font>***

