# MyBatis接口式编程

初探中的sql配置：

```xml
<mapper namespace="jiacheng.mybatis.EmployeeMapper">
    <select id="selectEmp" resultType="mybatis.bean.Employee">
    select * from tb_employee where id = #{id}
  </select>
</mapper>
```

执行传入：

```java
Employee employee = openSession.selectOne("jiacheng.mybatis.EmployeeMapper.selectEmp", 1);
```

问题：实际sql只对传入的整型id值起作用，若传入其他类型，<mark>则不响应（不报错）</mark>，这样不利于参数类型规范。

因此引入接口式编程



## 1、过程

### 1）编写接口

```java
package mybatis.dao;

import mybatis.bean.Employee;

public interface EmployeeMapper {
  //每条sql对应一个方法
    public Employee getEmpById(Integer id);
}
```





### 2）sql映射文件：EmployeeMapper.xml

**<font color="red">一个sql映射文件对应一个接口</font>**

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<!--namespace：名称空间，指定为接口全类名
    id：唯一标识，接口中对应方法名
    resultType：返回值类型（全限定类名）
    #{id}： 从传递过来的参数中取出id值-->
<mapper namespace="mybatis.dao.EmployeeMapper">
<!--    该select标签相当于对应接口中的函数的实现-->
    <select id="getEmpById" resultType="mybatis.bean.Employee">
    select * from tb_employee where id = #{id}
  </select>
</mapper>
```

- 将namespace指定为接口的全类名

- select标签的id值对应接口中的相应方法名

  **<font color="red">注意：一个select标签对应一条sql语句，对应接口中的一个方法。</font>**
  
  ​			

### 3)  测试

```java
@Test
public void test01() throws IOException {
    //1.获取SqlSessionFactory对象
    SqlSessionFactory sqlSessionFactory = getSqlSessionFactory();
    //2.获取SqlSession对象
    SqlSession openSession = sqlSessionFactory.openSession();
    //3.获取接口的实现类对象
    //mybatis会为接口自动创建一个代理对象，代理对象去执行数据库操作
    EmployeeMapper mapper = openSession.getMapper(EmployeeMapper.class);
    Employee employee = mapper.getEmpById(1);
    System.out.println(employee);
    openSession.close();

}

//将获取SqlSessionFactory对象的方法抽象了出来
public SqlSessionFactory getSqlSessionFactory() throws IOException {
        String resource = "mybatis-config.xml";
        InputStream inputStream = Resources.getResourceAsStream(resource);
        return new SqlSessionFactoryBuilder().build(inputStream);
    }
```

**<font size=5><mark>重点是代码中第3步</mark></font>**

**<font color="red">EmployeeMapper mapper = openSession.getMapper(EmployeeMapper.class);</font>**

**<font color="Blue">SqlSession：代表和数据库的一次对话，用完必须关闭</font>**

**<font color="Blue">						非线程安全，每次使用都应该去获取新对象，而不是写成成员变量</font>**

