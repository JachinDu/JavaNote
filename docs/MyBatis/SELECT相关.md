# SELECT相关



# 1、返回List

1）接口：

```java
public List<Employee> getEmpsByName(String name);
```



2）映射文件：

<mark>和原来一样，mybatis若查出多个则会自动封装为List</mark>

```xml
<select id="getEmpsByName" resultType="jc">
        select * from tb_employee where last_name like #{lastName}
</select>				
```

like用来模糊查询



3) 测试：

```java
List<Employee> list = mapper.getEmpsByName("%e%");//模糊查询，查出名字中带e字母的
for (Employee employee:list
     ) {
    System.out.println(employee);
}
```



4）结果

![image-20190603180013306](../PicSource/image-20190603180013306.png)

