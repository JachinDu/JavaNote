# Hystrix

***<font color='gree' size=5>实现“高可用”，防止服务雪崩</font>***

------



## 1、什么是Hystrix?

SOA/微服务架构中提供**<font color='purple' size=5>*服务(资源)隔离(每个服务有指定量的资源，不会因为对该服务的请求量大就无限分配资源）、熔断、降级机制的工具/框架*</font>**。**Netflix Hystrix是断路器的一种实现**，用于高微服务架构的可用性，是防止服务出现==雪崩==的利器。

------



## 2、为什么需要==断路器==？

在分布式架构中，**<font color='red'>一个应用依赖多个服务</font>**是非常常见的，如果其中一个依赖由于延迟过高发生阻塞，调用该依赖服务的线程就会阻塞，如果相关业务的==QPS较高，就可能产生大量阻塞，从而导致该应用/服务由于服务器资源被耗尽而拖垮==。另外，**<font color='red'>故障也会在应用之间传递，如果故障服务的上游依赖较多，可能会引起服务的==雪崩效应（因服务提供者的不可用导致服务调用者的不可用，并将不可用逐渐放大的过程，就叫服务雪崩效应）==</font>**。就跟数据瘫痪，会引起依赖该数据库的应用瘫痪是一样的道理。

------

- 关闭

- - 熔断器在默认情况下下是呈现关闭的状态，而熔断器本身带有计数功能，每当错误发生一次，计数器也就会进行“累加”的动作，到了一定的错误发生次数断路器就会被“开启”，<font color='red'>这个时候亦会在内部启用一个计时器，一旦时间到了就会切换成半开启的状态。</font>

- 开启

- - 在开启的状态下任何请求都会“直接”被拒绝并且抛出异常讯息。

- 半开启

- - <font color='red'>在此状态下断路器会允许部分的请求，如果这些请求都能成功通过，那么就意味着错误已经不存在，则会被切换回关闭状态并重置计数。倘若请求中有“任一”的错误发生，则会回复到“开启”状态，并且重新计时，给予系统一段休息时间。</font>

![-w1069](../PicSource/640-20200317092045846.jpeg)

------



## 3、Hystrix特点



> - 在通过网络依赖服务出现高延迟或者失败时，为系统提供保护和控制
> - ==**快速失败**==：当因为调用远程服务失败次数过多，熔断器开启时，上游服务对于下游服务的调用就会快速失败，这样可以避免上游服务被拖垮。
> - ==**无缝恢复**==：因为熔断器可以定期检查下游系统是否恢复，一旦恢复就可以重新回到关闭状态，所有请求便可以正常请求到下游服务。使得系统不需要认为干预。
> - <font color='red'>**提供==失败回退（Fallback）==和相对优雅的服务降级机制**</font>
> - **<font color='red'>*提供有效的服务容错监控、报警和运维控制手段（dashboard可视化监控）*</font>**

------



## 4、与springcloud整合注意

主要分为：

> 1. RestTemplate整合hystrix：==`@HystrixCommand(fallbackMethod = "fallback")`==，指定降级函数名。需要另定义一个fallback函数。
>
> 2. Feign整合hystrix：
>
>    ```java
>    @FeignClient(name = "product", fallback = ProductClient.ProductClientFallback.class)
>    public interface ProductClient {
>    
>        @PostMapping("/product/listForOrder")
>        List<ProductInfo> listForOrder(@RequestBody List<String> productIdList);
>    
>        @PostMapping("/product/decreaseStock")
>        void decreaseStock(@RequestBody List<CartDTO> cartDTOList);
>    
>        @Component // 勿忘
>        static class ProductClientFallback implements ProductClient{
>    
>            @Override
>            public List<ProductInfo> listForOrder(List<String> productIdList) {
>                return null;
>            }
>    
>            @Override
>            public void decreaseStock(List<CartDTO> cartDTOList) {
>    
>            }
>        }
>    
>    }
>    ```



主要功能：（场景：B服务中调用了A服务）

> 1. **==服务降级==**：B调用A服务失败后的处理逻辑：<font color='red'>**fallback**</font>
>
> 2. **==服务熔断==**：<font color='red'>通过监控B调用A服务的成功/失败比例，超过阈值后，执行熔断（打开断路器），此后请求B服务接回直接进入fallback(失败)，继续监控成功/失败比例，直到恢复，则关闭断路器，服务B恢复。继续监控。以下时配置熔断相关的三个重要参数：</font>
>
>    ![image-20200109150602588](../PicSource/image-20200109150602588.png)
>
> 3. 依赖隔离：对某个被监控的服务自动实现了进程隔离，使不同的服务互不影响。