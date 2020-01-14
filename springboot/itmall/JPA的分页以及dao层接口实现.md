# JPA的分页以及dao层接口实现



## 1、【举例】

只需要继承 <mark>JpaRepository<实体类,主键类型> </mark>

```java
package com.tmall.tmallspringboot.dao;

import com.tmall.tmallspringboot.pojo.Category;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryDao extends JpaRepository<Category,Integer> {
    //大部分crud方法都在JpaRepository及其父类中了，所以几乎不用自己定义
}
```



## 2、【源码】

一步步点进来，从这两个接口可以看到几乎提供了所有常用的方法。



```java
//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.springframework.data.jpa.repository;

import java.util.List;
import org.springframework.data.domain.Example;
import org.springframework.data.domain.Sort;
import org.springframework.data.repository.NoRepositoryBean;
import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.repository.query.QueryByExampleExecutor;

@NoRepositoryBean
public interface JpaRepository<T, ID> extends PagingAndSortingRepository<T, ID>, QueryByExampleExecutor<T> {
    List<T> findAll();

    List<T> findAll(Sort var1);

    List<T> findAllById(Iterable<ID> var1);

    <S extends T> List<S> saveAll(Iterable<S> var1);

    void flush();

    <S extends T> S saveAndFlush(S var1);

    void deleteInBatch(Iterable<T> var1);

    void deleteAllInBatch();

    T getOne(ID var1);

    <S extends T> List<S> findAll(Example<S> var1);

    <S extends T> List<S> findAll(Example<S> var1, Sort var2);
}
```



```java
//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.springframework.data.repository;

import java.util.Optional;

@NoRepositoryBean
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



## 3、【自定义与分页】

通常情况下我们的数据需要分页显示，而且要是需要的方法没有提供，则需要自己定义。

首先，分页其实jpa也帮我们做了：

我们需要做的就是：

- 返回类型设置为Page4Navigator<实体类>==因为Page类对json不支持，所以套一层支持json的==

- 将自定义参数封装进Pageable对象，然后在调用jpa的对应方法时把Pageable对象==9行==传入即可

```java
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

public Page4Navigator<Category> list(int start, int size, int navigatePages) {
    Sort sort = new Sort(Sort.Direction.DESC, "id");
    Pageable pageable = PageRequest.of(start, size, sort);
    Page pageFromJPA = categoryDao.findAll(pageable);

    return new Page4Navigator<>(pageFromJPA, navigatePages);
}
```



自定义条件查询加分页则需要在上面的基础上，在dao层中添加一下：

```java
import com.tmall.tmallspringboot.pojo.Category;
import com.tmall.tmallspringboot.pojo.Property;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PropertyDao extends JpaRepository<Property,Integer> {

  // 自定义条件查询
    Page<Property> findByCategory(Category category, Pageable pageable);
}
```



前提是要设置好外键：

实体类Property中：

```java
@JoinColumn(name = "cid")  
private Category category;
```



自定义条件查询其实就是在函数名和参数上做文章即可：

如再举一例： 

```java
public interface ProductImageDAO extends JpaRepository<ProductImage, Integer> {
		// 双条件查询
    public List<ProductImage> findByProductAndTypeOrderByIdDesc(Product product, String type);
}
```