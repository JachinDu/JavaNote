# ResultMap



## 1、用于自定义封装规则

与ResultType冲突，只能使用一个

例：

EmployeeMapperPlus.xml：

```xml
<mapper namespace="mybatis.dao.EmployeeMapperPlus">

<!--    自定义某个javabean的封装规则
            type：自定义规则的java类型
            id: 唯一，方便引用-->
    <resultMap id="MyEmp" type="mybatis.bean.Employee">
<!--        指定主键列的封装规则，用id，其他用result
                column: 指定表中哪一列
                property: 指定对应的javabean属性-->
        <id column="id" property="id"/>
<!--        定义普通列封装规则-->
        <result column="last_name" property="lastName"/>
<!--        其他不指定的列会自动封装，推荐写上-->
        <result column="email" property="email"/>
        <result column="gender" property="gender"/>
    </resultMap>

<!--    resultMap: 自定义结果集映射规则-->
<!--    public Employee getEmpById(Integer id);-->
    <select id="getEmpById" resultMap="MyEmp">
        select * from tb_employee where id=#{id}
    </select>
</mapper>
```





## 2、联合查询

### 方式1

场景：共有两张表

tb_employee:

![image-20190604182546231](/Users/jc/Library/Application Support/typora-user-images/image-20190604182546231.png)

将外键与tb_dept的主键(id)绑定：

```sql
alter table tb_employee add constraint fk_emp_dept
foreign key (d_id) references tb_dept(id)
```



tb_dept:

![image-20190604182604048](/Users/jc/Library/Application Support/typora-user-images/image-20190604182604048.png)



查询步骤：

接口：

多了一个Department接口

```java
public class Department {
    private Integer id;
    private String deptName;
```

```java
public class Employee {
    private Integer id;
    private String lastName;
    private String email;
    private String gender;
    private Department dept;
```



映射文件：

```xml
<!--    场景一：
            查询Employee同时查出对应部门
        联合查询：级联属性封装结果集:如dept.id -->
    <resultMap id="myDifEmp" type="mybatis.bean.Employee">
        <id column="id" property="id"/>
        <result column="last_name" property="lastName"/>
        <result column="gender" property="gender"/>
        <result column="did" property="dept.id"/>
        <result column="dept_name" property="dept.deptName"/>
    </resultMap>
    <!--        public Employee getEmpAndDept(Integer id);-->

    <select id="getEmpAndDept" resultMap="myDifEmp">
        select e.id id,e.last_name last_name,e.gender gender,e.d_id d_id,d.id did,d.dept_name dept_name from tb_employee e,tb_dept d
where e.d_id = d.id and e.d_id=#{id};
    </select>
```



### 方式2

assosiation标签

```xml
<resultMap id="myDifEmp2" type="mybatis.bean.Employee">
        <id column="id" property="id"/>
        <result column="last_name" property="lastName"/>
        <result column="gender" property="gender"/>
<!--        association可以指定联合的javabean对象
                property： 指定哪个属性是联合对象
                javaType:  指定属性对象的类型-->
        <association property="dept" javaType="mybatis.bean.Department">
            <id column="did" property="id"/>
            <result column="dept_name" property="deptName"/>
        </association>
    </resultMap>
```



## 3、关联集合封装

<mark>使用collection标签</mark>

场景：查出某一部门下的所有员工

在部门bean中加了一个员工的List

```java
public class Department {
    private Integer id;
    private String deptName;
    private List<Employee> employees;
```



DepartmentMapper:

```java
//可以查出部门中的所有员工
public Department getDeptByIdPlus(Integer id);
```



映射文件：

```xml
<resultMap id="MyDept" type="mybatis.bean.Department">
        <id column="did" property="id"/>
        <result column="dept_name" property="deptName"/>
<!--        员工信息，需要定义集合collection
                property: 对应的集合属性
                ofType: 指定集合中元素的类型-->
        <collection property="employees" ofType="mybatis.bean.Employee">
<!--            定义集合中元素的封装规则-->
            <id column="eid" property="id"/>
            <result column="last_name" property="lastName"/>
            <result column="email" property="email"/>
            <result column="gender" property="gender"/>
        </collection>
    </resultMap>
<!--        public Department getDeptByIdPlus(Integer id);-->
    <select id="getDeptByIdPlus" resultMap="MyDept">
      select d.id did,d.dept_name dept_name,
                e.id eid,e.last_name last_name,e.email email,e.gender gender
      from tb_dept d
      left join tb_employee e on d.id = e.d_id
      where d.id=#{id};
    </select>
```



使用collection标签将查出的员工信息封装入<mark>private List<Employee> employees</mark>中。



## 4、分步查询

基于3中的场景

EmployeeMapperPlus：

```java
//按部门id查出所有员工
public List<Employee> getEmpsByDeptId(Integer deptId);
```

对应的映射：

```xml
<!--        public List<Employee> getEmpsByDeptId(Integer deptId);-->
    <select id="getEmpsByDeptId" resultType="mybatis.bean.Employee">
        select * from tb_employee where d_id=#{id}
    </select>
```



DepartmentMapper:

```java
//分步查询
public Department getDeptByIdStep(Integer id);
```

对应的映射：

![image-20190604194846961](/Users/jc/Library/Application Support/typora-user-images/image-20190604194846961.png)





## 5、鉴别器（重要）



EmployeeMapperPlus.xml

```xml
<!--    <disciminator>鉴别器
            用来判断查出的某列的值，据此采取不同的封装或行为
            如：查出是女生，就把部门信息也查询出来
                查出是男生，就把last_name这一列赋值给email-->
    <resultMap id="MyEmpDisc" type="mybatis.bean.Employee">
        <id column="id" property="id"/>
        <result column="last_name" property="lastName"/>
        <result column="gender" property="gender"/>
        <result column="email" property="email"/>
<!--        column: 指定要判定的列名
            javaType: 列值对应的java类型-->
        <discriminator javaType="string" column="gender">
<!--            女生-->
            <case value="0" resultType="mybatis.bean.Employee">
                <association property="dept"
                            select="mybatis.dao.DepartmentMapper.getDeptById"
                            column="d_id">
                </association>
            </case>
<!--            男生-->
            <case value="1" resultType="mybatis.bean.Employee">
                <id column="id" property="id"/>
                <result column="last_name" property="lastName"/>
                <result column="gender" property="gender"/>
                <result column="last_name" property="email"/>
            </case>
        </discriminator>
    </resultMap>
```



测试时如果是女生，则结果为：

![image-20190604201507689](/Users/jc/Library/Application Support/typora-user-images/image-20190604201507689.png)