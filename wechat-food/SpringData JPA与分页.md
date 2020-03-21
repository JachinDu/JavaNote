# SpringData JPA与分页

在Spring Boot中使用JPA，需要引入如下依赖：

```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
```



## 1、JpaRepository

拿项目中一个dao层举例：

```java
public interface ProductCategoryRepository extends JpaRepository<ProductCategory,Integer> {

    List<ProductCategory> findByCategoryTypeIn(List<Integer> categoryTypeList);
}
```

所有dao层都会继承***<font color='red' size=5>`JpaRepository<实体类,主键类型>`</font>***接口。

------

**`JpaRepository`接口的继承关系图：**



![image-20191231171238791](../PicSource/image-20191231171238791.png)

<font color='red' size=5>***其中重要的就是继承`CrudRepository`和`PagingAndSortingRepository`接口***</font>

------



### 1）CrudRepository接口

它定义了一些CRUD方法，所以==继承它的类可以直接获得这些对数据库操作的CRUD方法。==

```java
public interface CrudRepository<T, ID> extends Repository<T, ID> {
    <S extends T> S save(S var1);

    <S extends T> Iterable<S> saveAll(Iterable<S> var1);

    Optional<T> findById(ID var1);

    boolean existsById(ID var1);

    Iterable<T> findAll();

    Iterable<T> findAllById(Iterable<ID> var1);

    long count();

    void deleteById(ID var1);

    void delete(T var1);

    void deleteAll(Iterable<? extends T> var1);

    void deleteAll();
}
```



### 2）PagingAndSortingRepository接口

**<font color='red' size=5>这是用来实现分页接口</font>**

```java
public interface PagingAndSortingRepository<T, ID> extends CrudRepository<T, ID> {
    Iterable<T> findAll(Sort var1);

    Page<T> findAll(Pageable var1);
}
```

> ***<font color='red' size=5>`Page<T> findAll(Pageable var1);`</font>***

------



#### **分页操作：**

a）Controller层：

```java
@GetMapping("/list")
    public ModelAndView list(@RequestParam(value = "page" ,defaultValue="1") Integer page,
                             @RequestParam(value = "size",defaultValue = "10") Integer size,
                             Map<String,Object> map){
        Pageable pageable = PageRequest.of(page-1, size);
        Page<ProductInfo> productInfoPage=productService.findAll(request);
        map.put("productInfoPage",productInfoPage);
        map.put("currentPage",page);
        map.put("size",size);
        return new ModelAndView("product/list",map);
    }
```

> - <font color='red' size = 4>***其中：PageRequest类继承于AbstractPageRequest类，该类实现了Pageable接口，故可以有上面5、6行***</font>
>
> - <font color='red' size = 4>***而且还要把page参数（从几页开始）和size参数（一页几个）传给模版引擎中***</font>
>
>   ```html
>   <div class="col-md-12 column">
>       <ul class="pagination pull-right">
>   
>           <#if currentPage lte 1>
>               <li class="disabled"><a href="#">上一页</a></li>
>           <#else>
>               <li><a href="/sell/buyer/product/list?page=${currentPage-1}&size=${size}">上一页</a></li>
>           </#if>
>   
>           <#list 1..productInfoList.getTotalPages() as index>
>               <#if currentPage == index>
>                   <li class="disabled"><a href="#">${index}</a> </li>
>               <#else>
>                   <li><a href="/sell/buyer/product/list?page=${index}&size=${size}">${index}</a></li>
>               </#if>
>           </#list>
>   
>           <#if currentPage gte productInfoList.getTotalPages()>
>               <li class="disabled"><a href="#">下一页</a></li>
>           <#else>
>               <li><a href="/sell/buyer/product/list?page=${currentPage+1}&size=${size}">下一页</a></li>
>           </#if>
>   
>       </ul>
>   </div>
>   ```

------

b）Service层：

```java
@Override
public Page<ProductInfo> findAll(Pageable pageable) {
    return repository.findAll(pageable);
}
```



c）Dao层：

```java
public interface ProductInfoRepository extends JpaRepository<ProductInfo,String>{

}
```

------

## 2、JpaSpecificationExecutor

参考：https://cloud.tencent.com/developer/article/1429349

==完成多条件查询==，也支持分页与排序

<font color='red'>***虽然只继承JpaRepository接口也可以使用多条件查询，但是不建议，因为如果条件较多的话或者需要修改的话，都要在函数名上大作文章，不好维护，不够优雅。***</font>可能会变成：==**findByOrderNoAndXxxxAndXxxxAndXxxx....**==

------

不能单独使用：

定义DAO：

```java
public interface UserDao extends JpaRepository<Users, Integer>
					, JpaSpecificationExecutor<Users> {
}
```

使用其实现多条件查询：

在使用的地方定义即可：

```java
// 1. 生成查询条件
Specification<Users> spec = new Specification<Users>() {
        @Override
        public Predicate toPredicate(Root<Users> root,
                                     CriteriaQuery<?> query, CriteriaBuilder cb) {
            List<Predicate> list = new ArrayList<>();
          	// 这里妥妥的多条件，而且便于维护！！！
            list.add(cb.equal(root.get("username"), "王五"));
            list.add(cb.equal(root.get("userage"), 24));
            //此时条件之间是没有任何关系的。
            Predicate[] arr = new Predicate[list.size()];
            return cb.and(list.toArray(arr));
        }
    };
// 2. 将上述返回的查询条件作为参数传入即可
List<Users> list = this.usersDao.findAll(spec);
```

------

## 3、总结

<font color='red' size =4>***尽量使DAO层只是继承了几个接口，没有写其他东西，如继承JpaRepository提供基础的crud，继承JpaSpecificationExecutor实现特殊查询。这样符合领域设计规范。而且查询时尽量不要搞联查***</font>

------

## 4、非持久化某字段

后两种方法较多

```java
static String transient1; // not persistent because of static
final String transient2 = “Satish”; // not persistent because of final
transient String transient3; // not persistent because of transient
@Transient
String transient4; // not persistent because of @Transient
```

