# 数据库与dao层

## 1、生成数据库

**src/main/sql/schema.sql：**

```sql
--数据库初始化脚本

--创建数据库
create database seckill;
use seckill;

--1、创建秒杀库存表
create table seckill(
    seckill_id bigint NOT NULL AUTO_INCREMENT COMMENT '商品库存id',
    name varchar (120) NOT NULL COMMENT '商品名称',
    number int NOT NULL COMMENT '库存数量',
    start_time timestamp NOT NULL COMMENT '秒杀开启时间',
    end_time timestamp NOT NULL COMMENT '秒杀结束时间',
    create_time timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (seckill_id),
    key idx_start_time(start_time),
    key idx_end_time(end_time),
    key idx_create_time(create_time)
) ENGINE=InnoDB AUTO_INCREMENT=1000 DEFAULT CHARSET=utf8 COMMENT='秒杀库存表';


--初始化数据
insert into
    seckill(name,number,start_time,end_time)
values
('1000元秒杀iphoneX',100,'2019-06-17 00:00:00','2019-06-18 00:00:00'),
('500元秒杀ipadPro',200,'2019-06-17 00:00:00','2019-06-18 00:00:00'),
('300元秒杀小米8',300,'2019-06-17 00:00:00','2019-06-18 00:00:00'),
('200元秒杀benz',400,'2019-06-17 00:00:00','2019-06-18 00:00:00');



--2、秒杀成功明细表
--用户登录认证相关信息
create table success_killed(
seckill_id bigint NOT NULL COMMENT '秒杀商品id',
user_phone bigint NOT NULL COMMENT '用户手机号',
state tinyint NOT NULL DEFAULT -1 COMMENT '状态表示：-1：无效 0：成功 1：已付款 2：已发货',
create_time timestamp NOT NULL COMMENT '创建时间',
PRIMARY KEY (seckill_id,user_phone), /*联合主键,(一个用户不能对同一产品重复秒杀*/
key idx_create_time(create_time)

)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='秒杀成功明细表';
```



## 2、实体类

### 1）业务实体

**Seckill**

```java
/*
* 秒杀商品对象
* */
public class Seckill implements Serializable {
    private long seckillId;
    private String name;
    private int number;
    private Date startTime;
    private Date endTime;
    private Date createTime;
  //getter/setter必须要有！！！！
```



**SuccessKilled**

```java
/*
* 成功秒杀明细对象
* */
public class SuccessKilled implements Serializable {
    private long seckillId;
    private long userPhone;
    private short state;
    private Date createTime;

    //携带秒杀商品对象
    private Seckill seckill;
    //getter/setter必须要有！！！！
```



### <mark>2）数据传输实体</mark>

**<font color="red" size=5>用于程序执行过程中记录数据传输信息的javabean</font>**



**Exposer**

```java
/*
* 暴露秒杀地址DTO
* */
public class Exposer implements Serializable {

    //是否开启秒杀
    private boolean exposed;
    //一种加密措施
    private String md5;
    private long seckillId;
    //系统当前时间(ms)
    private long now;
    //秒杀开启时间
    private long start;
    //秒杀结束时间
    private long end;

    public Exposer() {
    }


    //    三种构造方法

    //可以秒杀
    public Exposer(boolean exposed, String md5, long seckillId) {
        this.exposed = exposed;
        this.md5 = md5;
        this.seckillId = seckillId;
    }


    //秒杀结束（时间不对）
    public Exposer(boolean exposed, long seckillId, long now, long start, long end) {
        this.exposed = exposed;
        this.seckillId = seckillId;
        this.now = now;
        this.start = start;
        this.end = end;
    }

    //不存在该id的商品
    public Exposer(boolean exposed, long seckillId) {
        this.exposed = exposed;
        this.seckillId = seckillId;
    }
  
      //getter/setter必须要有！！！！
```





**SeckillExecution**

```java
/*
* 封装秒杀执行后的结果
* */
public class SeckillExecution implements Serializable {

    private long seckillId;
    //秒杀执行结果状态
    private int state;

    //状态表示
    private String stateInfo;

    //秒杀成功对象
    private SuccessKilled successKilled;
  
  //成功秒杀的构造函数
    public SeckillExecution(long seckillId, SeckillStateEnum stateEnum, SuccessKilled successKilled) {
        this.seckillId = seckillId;
        this.state = stateEnum.getState();
        this.stateInfo = stateEnum.getStateInfo();
        this.successKilled = successKilled;
    }

    //失败秒杀的构造函数
    public SeckillExecution(long seckillId, SeckillStateEnum stateEnum) {
        this.seckillId = seckillId;
        this.state = stateEnum.getState();
        this.stateInfo = stateEnum.getStateInfo();
    }
  
        //getter/setter必须要有！！！！
```









## 3、dao层

```java
package org.seckill.dao;

import org.apache.ibatis.annotations.Param;
import org.seckill.entity.Seckill;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;
import java.util.Map;

public interface SeckillDao {

    /*
     * 减库存：
     *       参数对应商品id，和减库存时间
     *       返回： 影响行数>1,表示更新的记录行数
     * */
    public int reduceNumber(@Param("seckillId") long seckillId, @Param("killTime") Date killTime);

    /*
     * 根据id查秒杀商品对象
     * */
    public Seckill queryById(long seckillId);

    /*
     * 根据偏移量查询秒杀列表（分页）
     * */
    public List<Seckill> queryAll(@Param("offset") int offset, @Param("limit") int limit);

    /*
    * 使用存储过程执行秒杀
    * */
    void killByProcedure(Map<String, Object> paramMap);
}
```





command+shift+T:

![image-20190617164015883](/Users/jc/Library/Application Support/typora-user-images/image-20190617164015883.png)









![image-20190617191756149](/Users/jc/Library/Application Support/typora-user-images/image-20190617191756149.png)







![image-20190617191818852](/Users/jc/Library/Application Support/typora-user-images/image-20190617191818852.png)







![image-20190617203638595](/Users/jc/Library/Application Support/typora-user-images/image-20190617203638595.png)







运行期异常才会出发spring的回滚





![image-20190618100931321](/Users/jc/Library/Application Support/typora-user-images/image-20190618100931321.png)





![image-20190618101603498](/Users/jc/Library/Application Support/typora-user-images/image-20190618101603498.png)



![image-20190618185505830](/Users/jc/Library/Application Support/typora-user-images/image-20190618185505830.png)







![image-20190618202033007](/Users/jc/Library/Application Support/typora-user-images/image-20190618202033007.png)





![image-20190618202443890](/Users/jc/Library/Application Support/typora-user-images/image-20190618202443890.png)







![image-20190619085525678](/Users/jc/Library/Application Support/typora-user-images/image-20190619085525678.png)







![image-20190619141856398](/Users/jc/Library/Application Support/typora-user-images/image-20190619141856398.png)





![image-20190620131012391](/Users/jc/Library/Application Support/typora-user-images/image-20190620131012391.png)







![image-20190620150947524](/Users/jc/Library/Application Support/typora-user-images/image-20190620150947524.png)