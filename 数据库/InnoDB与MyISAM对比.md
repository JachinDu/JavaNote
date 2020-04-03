# InnoDB与MyISAM对比

1. <font color='red'>**InnoDB 支持事务，MyISAM 不支持事务**</font>。这是 MySQL 将默认存储引擎从 MyISAM 变成 InnoDB 的重要原因之一；

2. InnoDB 支持外键，而 MyISAM 不支持。对一个包含外键的 InnoDB 表转为 MYISAM 会失败；  

3. <font color='red'>**InnoDB 是聚集索引，MyISAM 是非聚集索引**</font>。聚簇索引的文件存放在主键索引的叶子节点上，因此 InnoDB 必须要有主键，通过主键索引效率很高。但是辅助索引需要两次查询，先查询到主键，然后再通过主键查询到数据。因此，主键不应该过大，因为主键太大，其他索引也都会很大。而 MyISAM 是非聚集索引，==数据文件是分离的，索引保存的是数据文件的指针==。主键索引和辅助索引是独立的。 

4. ==**InnoDB 不保存表的具体行数**，执行 select count(*) from table 时需要全表扫描。而MyISAM 用一个变量保存了整个表的行数，执行上述语句时只需要读出该变量即可，速度很快；==    

5. <font color='red'>**InnoDB 最小的锁粒度是行锁，MyISAM 最小的锁粒度是表锁。**</font>一个更新语句会锁住整张表，导致其他查询和更新都会被阻塞，因此并发访问受限。这也是 MySQL 将默认存储引擎从 MyISAM 变成 InnoDB 的重要原因之一；

------

## COUNT函数

http://www.hollischuang.com/archives/4057

> - count(*)：包括null
>
>   是SQL92定义的标准统计行数的语法，<font color='red'>**所以MySQL对他进行了很多优化，MyISAM中会直接把表的总行数单独记录下来供`COUNT(*)`查询，而InnoDB则会在扫表的时候选择最小的索引来降低成本(如找辅助索引)。**</font>当然，这些优化的前提都是没有进行where和group的条件查询。
>
> - count(常数)：包括null
>
>   如count(1)，同count(*)在实现上没什么区别
>
> - count(字段)：
>
>   <font color='red'>**需要进行字段的非NULL判断，只返回非null的个数，所以效率会低一些。**</font>

