# 负载均衡-ribbon



## 1、ribbon是运行在客户端端负载均衡器

![img](/Users/jc/Documents/JavaNote/分布式与微服务/mooc-springcloud/640-20200107152249120.jpeg)



------

## 2、nginx与ribbon

> - **Nginx：集中式负载均衡器**
>
>   将所有请求都集中起来，再进行负载均衡，如下图：
>
>   ![img](/Users/jc/Documents/JavaNote/分布式与微服务/mooc-springcloud/640-20200107152445636.jpeg)
>
> - **ribbon：在消费者端进行负载均衡：**
>
>   ![img](/Users/jc/Documents/JavaNote/分布式与微服务/mooc-springcloud/640-20200107152515068.jpeg)
>
> - **<font color='red'>注意：nginx中，request先进入到nginx然后再负载均衡。而ribbon中是现在客户端进行负载均衡后，才进行请求。</font>**



## 3、ribbon中的几种负载均衡算法

负载均衡，不管 `Nginx` 还是 `Ribbon` 都需要其算法的支持，如果我没记错的话 `Nginx` 使用的是 轮询和加权轮询算法。而在 `Ribbon` 中有更多的负载均衡调度算法，其==默认是使用的 `RoundRobinRule` 轮询策略。==

- **RoundRobinRule**：轮询策略。`Ribbon` 默认采用的策略。若经过一轮轮询没有找到可用的 `provider`，其最多轮询 10 轮。若最终还没有找到，则返回 null。
- **RandomRule**: 随机策略，从所有可用的 provider 中随机选择一个。
- **RetryRule**: 重试策略。先按照 RoundRobinRule 策略获取 provider，若获取失败，则在指定的时限内重试。默认的时限为 500 毫秒。