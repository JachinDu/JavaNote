# 高并发秒杀API总结

其他人的总结：

https://juejin.im/post/5aabd1956fb9a028d82b8738

[http://codingxiaxw.cn/2016/11/27/53-maven-ssm-seckill-dao/](http://codingxiaxw.cn/2016/11/27/53-maven-ssm-seckill-dao/)

## 1、工具技巧

command+shift+T：生成对应类的测试

![image-20190617164015883](/Users/jc/Library/Application Support/typora-user-images/image-20190617164015883.png)







## 2、mybatis

【问题】使用mybatis读取mysql中的timestamp字段时，读到的时间比数据库中的时间有偏差

【解决】![image-20190617191818852](/Users/jc/Library/Application Support/typora-user-images/image-20190617191818852.png)



## 3、日志

slf4j，注意logger选择时

![image-20190617203638595](/Users/jc/Library/Application Support/typora-user-images/image-20190617203638595.png)





## 4、spring

![image-20190618100931321](/Users/jc/Library/Application Support/typora-user-images/image-20190618100931321.png)



![image-20190618101603498](/Users/jc/Library/Application Support/typora-user-images/image-20190618101603498.png)



基于注解配置声明式事务

![image-20190618185505830](/Users/jc/Library/Application Support/typora-user-images/image-20190618185505830.png)





## 5、前端

![image-20190618202033007](/Users/jc/Library/Application Support/typora-user-images/image-20190618202033007.png)





![image-20190618202443890](/Users/jc/Library/Application Support/typora-user-images/image-20190618202443890.png)





## 6、关于实体类get/set方法

![image-20190619141856398](/Users/jc/Library/Application Support/typora-user-images/image-20190619141856398.png)





## 7、高并发优化

![image-20190620131012391](/Users/jc/Library/Application Support/typora-user-images/image-20190620131012391.png)

![image-20190620131147667](/Users/jc/Library/Application Support/typora-user-images/image-20190620131147667.png)

### 7.1关于redis使用



## 8、mysql

联合主键+ignore实现避免重复插入

ignore作用是主键冲突重复插入时返回影响行数0，而不是直接报错，方便开发逻辑处理

```sql
insert ignore into success_killed(seckill_id,user_phone,state)
values (#{seckillId},#{userPhone},0)
```



## 9、md5

用于加密秒杀地址



## 10、枚举