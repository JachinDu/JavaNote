# 常见java集合操作技巧

## &sect; Java读取输入模版

```java
import java.util.*;
public class Main{
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
    }
}
```



## &sect; 数组转List

> - `List list = Arrays.asList(strArray);`，将数组转换List后，不能对List增删，只能查改，否则抛异常
>
> - `ArrayList list = new ArrayList(Arrays.asList(strArray)) ; `支持增删改查的方式
>
> - ```java
>   ArrayList< String> arrayList = new ArrayList<String>(strArray.length);
>   Collections.addAll(arrayList, strArray);
>   ```
>
>   

