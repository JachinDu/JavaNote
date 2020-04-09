# Redis各数据结构的常用操作

## &sect; string

### 设置和获取键值对

```sql
> SET key value
OK
> GET key
"value"
```

正如你看到的，我们通常使用 `SET` 和 `GET` 来设置和获取字符串值。

值可以是任何种类的字符串（包括二进制数据），例如你可以在一个键下保存一张 `.jpeg` 图片，只需要注意不要超过 512 MB 的最大限度就好了。

当 key 存在时，`SET` 命令会覆盖掉你上一次设置的值：

```sql
> SET key newValue
OK
> GET key
"newValue"
```

另外你还可以使用 `EXISTS` 和 `DEL` 关键字来查询是否存在和删除键值对：

```sql
> EXISTS key
(integer) 1
> DEL key
(integer) 1
> GET key
(nil)
```

### 批量设置键值对

```sql
> SET key1 value1
OK
> SET key2 value2
OK
> MGET key1 key2 key3    # 返回一个列表
1) "value1"
2) "value2"
3) (nil)
> MSET key1 value1 key2 value2
> MGET key1 key2
1) "value1"
2) "value2"
```

### 过期和 SET 命令扩展

可以对 key 设置过期时间，到时间会被自动删除，这个功能常用来控制缓存的失效时间。*(过期可以是任意数据结构)*

```sql
> SET key value1
> GET key
"value1"
> EXPIRE key 5    # 5s 后过期
...                # 等待 5s
> GET key
(nil)
```

==等价于 `SET` + `EXPIRE` 的 `SETEX` 命令：==

```sql
> SETEX key value1
...                # 等待 5s 后获取
> GET key
(nil)

> SETNX key value1  # 如果 key 不存在则 SET 成功
(integer) 1
> SETNX key value1  # 如果 key 存在则 SET 失败
(integer) 0
> GET key
"value"             # 没有改变
```

### 计数

如果 value 是一个整数，还可以对它使用 `INCR` 命令进行 **原子性** 的自增操作，这意味着及时多个客户端对同一个 key 进行操作，也决不会导致竞争的情况：

```sql
> SET counter 100
> INCR count
(interger) 101
> INCRBY counter 50
(integer) 151
```

### 返回原值的 GETSET 命令

对字符串，还有一个 `GETSET` 比较让人觉得有意思，它的功能跟它名字一样：为 key 设置一个值并返回原值：

```sql
> SET key value
> GETSET key value1
"value"
```

这可以对于某一些需要隔一段时间就统计的 key 很方便的设置和查看，例如：系统每当由用户进入的时候你就是用 `INCR` 命令操作一个 key，当需要统计时候你就把这个 key 使用 `GETSET` 命令重新赋值为 0，这样就达到了统计的目的。



------

## &sect; list

### 基本操作

```sql
> rpush mylist A
(integer) 1
> rpush mylist B
(integer) 2
> lpush mylist first
(integer) 3
> lrange mylist 0 -1    # -1 表示倒数第一个元素, 这里表示从第一个元素到最后一个元素，即所有
1) "first"
2) "A"
3) "B"
```

------

### list 实现队列

队列是先进先出的数据结构，常用于消息排队和异步逻辑处理，它会确保元素的访问顺序：

```sql
> RPUSH books python java golang
(integer) 3
> LPOP books
"python"
> LPOP books
"java"
> LPOP books
"golang"
> LPOP books
(nil)
```

### list 实现栈

栈是先进后出的数据结构，跟队列正好相反：

```sql
> RPUSH books python java golang
> RPOP books
"golang"
> RPOP books
"java"
> RPOP books
"python"
> RPOP books
(nil)
```

------

## &sect; hash

hash 也有缺点，hash 结构的存储消耗要高于单个字符串，所以到底该使用 hash 还是字符串，需要根据实际情况再三权衡：

```sql
> HSET books java "think in java"    # 命令行的字符串如果包含空格则需要使用引号包裹
(integer) 1
> HSET books python "python cookbook"
(integer) 1
> HGETALL books    # key 和 value 间隔出现
1) "java"
2) "think in java"
3) "python"
4) "python cookbook"
> HGET books java
"think in java"
> HSET books java "head first java"  
(integer) 0        # 因为是更新操作，所以返回 0
> HMSET books java "effetive  java" python "learning python"    # 批量操作
OK
```

------



## &sect; set

```sql
> SADD books java
(integer) 1
> SADD books java    # 重复
(integer) 0
> SADD books python golang
(integer) 2
> SMEMBERS books    # 注意顺序，set 是无序的
1) "java"
2) "python"
3) "golang"
> SISMEMBER books java    # 查询某个 value 是否存在，相当于 contains
(integer) 1
> SCARD books    # 获取长度
(integer) 3
> SPOP books     # 弹出一个
"java"
```

------



## &sect; zset

```sql
> ZADD books 9.0 "think in java"
> ZADD books 8.9 "java concurrency"
> ZADD books 8.6 "java cookbook"

> ZRANGE books 0 -1     # 按 score 排序列出，参数区间为排名范围
1) "java cookbook"
2) "java concurrency"
3) "think in java"

> ZREVRANGE books 0 -1  # 按 score 逆序列出，参数区间为排名范围
1) "think in java"
2) "java concurrency"
3) "java cookbook"

> ZCARD books           # 相当于 count()
(integer) 3

> ZSCORE books "java concurrency"   # 获取指定 value 的 score
"8.9000000000000004"                # 内部 score 使用 double 类型进行存储，所以存在小数点精度问题

> ZRANK books "java concurrency"    # 排名
(integer) 1

> ZRANGEBYSCORE books 0 8.91        # 根据分值区间遍历 zset
1) "java cookbook"
2) "java concurrency"

> ZRANGEBYSCORE books -inf 8.91 withscores  # 根据分值区间 (-∞, 8.91] 遍历 zset，同时返回分值。inf 代表 infinite，无穷大的意思。
1) "java cookbook"
2) "8.5999999999999996"
3) "java concurrency"
4) "8.9000000000000004"

> ZREM books "java concurrency"             # 删除 value
(integer) 1
> ZRANGE books 0 -1
1) "java cookbook"
2) "think in java"
```

