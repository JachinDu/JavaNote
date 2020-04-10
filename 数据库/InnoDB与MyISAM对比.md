# InnoDB与MyISAM对比

1. <font color='red'>**InnoDB 支持事务，MyISAM 不支持事务**</font>。这是 MySQL 将默认存储引擎从 MyISAM 变成 InnoDB 的重要原因之一；

2. InnoDB 支持外键，而 MyISAM 不支持。对一个包含外键的 InnoDB 表转为 MYISAM 会失败；  

3. <font color='red'>**InnoDB 是聚集索引，MyISAM 是非聚集索引**</font>。

4. ==**InnoDB 不保存表的具体行数**，执行 select count(*) from table 时需要全表扫描。而MyISAM 用一个变量保存了整个表的行数，执行上述语句时只需要读出该变量即可，速度很快；==    

5. <font color='red'>**InnoDB 最小的锁粒度是行锁，MyISAM 最小的锁粒度是表锁。**</font>

------

## COUNT函数

http://www.hollischuang.com/archives/4057

> - count(*)：包括null
>
>   是SQL92定义的标准统计行数的语法，<font color='red'>**所以MySQL对他进行了很多优化，MyISAM中会直接把表的总行数单独记录下来供`COUNT(*)`查询，而InnoDB则会在扫表的时候选择最小的索引来降低成本(如找辅助索引)。**</font>当然，这些优化的前提都是没有进行where和group的条件查询。
>
> - count(常数)：包括null
>
>   **如count(1)，同count(*)在实现上没什么区别**
>
> - count(字段)：
>
>   <font color='red'>**需要进行字段的非NULL判断，只返回非null的个数，所以效率会低一些。**</font>

