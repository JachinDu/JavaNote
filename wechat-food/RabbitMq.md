# RabbitMq

## 1、特点

- **可靠性：** RabbitMQ使用一些机制来保证消息的可靠性，如持久化、传输确认及发布确认等。
- **灵活的路由：** 在消息进入队列之前，通过交换器来路由消息。对于典型的路由功能，RabbitMQ 己经提供了一些内置的交换器来实现。针对更复杂的路由功能，可以将多个交换器绑定在一起，也可以通过插件机制来实现自己的交换器。这个后面会在我们将 RabbitMQ 核心概念的时候详细介绍到。
- **扩展性：** 多个RabbitMQ节点可以组成一个集群，也可以根据实际业务情况动态地扩展集群中节点。
- **高可用性：** 队列可以在集群中的机器上设置镜像，使得在部分节点出现问题的情况下队列仍然可用。
- **支持多种协议：** RabbitMQ 除了原生支持 AMQP 协议，还支持 STOMP、MQTT 等多种消息中间件协议。
- **多语言客户端：** RabbitMQ几乎支持所有常用语言，比如 Java、Python、Ruby、PHP、C#、JavaScript等。
- **易用的管理界面：** RabbitMQ提供了一个易用的用户界面，使得用户可以监控和管理消息、集群中的节点等。在安装 RabbitMQ 的时候会介绍到，安装好 RabbitMQ 就自带管理界面。
- **插件机制：** RabbitMQ 提供了许多插件，以实现从多方面进行扩展，当然也可以编写自己的插件。感觉这个有点类似 Dubbo 的 SPI机制。



## <font color='red'>2、整体模型架构</font>

![图1-RabbitMQ 的整体模型架构](/Users/jc/Documents/JavaNote/wechat-food/96388546.jpg)



## 3、核心概念介绍

### 1）消息(Message)

消息一般由 2 部分组成：

> - **消息头**（**标签 Label**）：由一系列的可选属性组成，这些属性包括 **<font color='red'>routing-key（路由键）</font>**、**priority（相对于其他消息的优先权）**、**delivery-mode（指出该消息可能需要持久性存储）**等。生产者把消息交由 RabbitMQ 后，RabbitMQ 会根据消息头把消息发送给感兴趣的 Consumer(消费者)。
> -  **消息体（payLoad）**：不透明的



### 2）生产者(Producer)和消费者(Consumer)

- **Producer(生产者)** :生产消息的一方（邮件投递者）
- **Consumer(消费者)** :消费消息的一方（邮件收件人）



### <font color='red'>3）交换器(Exchange)</font>

在 RabbitMQ 中，消息并不是直接被投递到 **Queue(消息队列)** 中的，中间还必须经过 **Exchange(交换器)** 这一层，<font color='red'>**Exchange(交换器)** 会把我们的消息路由到对应的 **Queue(消息队列)** 中。</font>

**Exchange(交换器)** 用来接收生产者发送的消息并将这些消息路由给服务器中的队列中，如果路由不到，或许会返回给 **Producer(生产者)** ，或许会被直接丢弃掉 。这里可以将RabbitMQ中的交换器看作一个简单的实体。

**RabbitMQ 的 Exchange(交换器) 有4种类型，不同的类型对应着不同的路由策略**：**direct(默认)**，**fanout**, **topic**, 和 **headers**，不同类型的Exchange转发消息的策略有所区别。

------



> - **路由键(RoutingKey)：**生产者将消息发给交换器的时候，一般会指定一个 **RoutingKey(路由键)**，用来指定这个消息的路由规则，而这个 **RoutingKey 需要与交换器类型和绑定键(BindingKey)联合使用才能最终生效**。
>
> - **绑定建(BindingKey)** ：RabbitMQ 中通过 **Binding(绑定)** 将 **Exchange(交换器)** 与 **Queue(消息队列)** 关联起来，在绑定的时候一般会指定一个 **BindingKey(绑定建)** ,这样 RabbitMQ 就知道如何正确将消息路由到队列了。
>
>   ![Binding(/Users/jc/Documents/JavaNote/wechat-food/70553134-20200104160800266.jpg) 示意图](http://my-blog-to-use.oss-cn-beijing.aliyuncs.com/18-12-16/70553134.jpg)

生产者将消息发送给交换器时，需要一个**RoutingKey**,当 **BindingKey** 和 **RoutingKey** 相匹配时，消息会被路由到对应的队列中。在绑定多个队列到同一个交换器的时候，这些绑定允许使用相同的 BindingKey。BindingKey 并不是在所有的情况下都生效，它依赖于交换器类型，比如fanout类型的交换器就会无视，而是将消息路由到所有绑定到该交换器的队列中。

**<font color='red' size=5>RoutingKey  +  交换器类型  +  绑定键(BindingKey)  =  最终生效</font>**。



------

#### 交换器类型

> 1. **fanout**：fanout 类型的Exchange路由规则非常简单，它会把所有发送到该Exchange的消息**<font color='red'>路由到所有与它绑定的Queue中</font>**;，不需要做任何判断操作，所以 fanout 类型是所有的交换机类型里面速度最快的。fanout 类型常用来<font color='red'>广播消息</font>。
>
> 2. **direct**：direct 类型的Exchange路由规则也很简单，它会把消息路由到那些 Bindingkey 与 RoutingKey <font color='red'>完全匹配的 Queue 中</font>。严格。
>
>    ![direct 类型交换器](/Users/jc/Documents/JavaNote/wechat-food/37008021.jpg)
>
>    以上图为例，如果发送消息的时候设置路由键为“warning”,那么消息会路由到 Queue1 和 Queue2。如果在发送消息的时候设置路由键为"Info”或者"debug”，消息只会路由到Queue2。如果以其他的路由键发送消息，则消息不会路由到这两个队列中。
>
>    direct 类型常用在处理有优先级的任务，根据任务的优先级把消息发送到对应的队列，这样可以指派更多的资源去处理高优先级的队列。
>
> 3. **topic**：前面讲到direct类型的交换器路由规则是完全匹配 BindingKey 和 RoutingKey ，但是这种严格的匹配方式在很多情况下不能满足实际业务的需求。topic类型的交换器在匹配规则上进行了扩展，它与 direct 类型的交换器相似，也是将消息路由到 BindingKey 和 RoutingKey 相匹配的队列中，但这里的匹配规则有些不同，它约定：
>
>    - RoutingKey 为一个点号“．”分隔的字符串（被点号“．”分隔开的每一段独立的字符串称为一个单词），如<font color='red'> “com.rabbitmq.client”、“java.util.concurrent”、“com.hidden.client”;</font>
>
>    - **<font color='red'>BindingKey 和 RoutingKey 一样也是点号“．”分隔的字符串；</font>**
>
>    - BindingKey 中可以存在两种特殊字符串“\*”和“#”，用于做<font color='red'>模糊匹配</font>，其中“*”用于匹配一个单词，“#”用于匹配多个单词(可以是零个)。
>
>      ------
>
>      
>
>    ![topic 类型交换器](/Users/jc/Documents/JavaNote/wechat-food/73843.jpg)
>
>    以上图为例：
>
>    - 路由键为 “com.rabbitmq.client” 的消息会同时路由到 Queuel 和 Queue2;
>    - 路由键为 “com.hidden.client” 的消息只会路由到 Queue2 中；
>    - 路由键为 “com.hidden.demo” 的消息只会路由到 Queue2 中；
>    - 路由键为 “java.rabbitmq.demo” 的消息只会路由到Queuel中；
>    - 路由键为 “java.util.concurrent” 的消息将会被丢弃或者返回给生产者（需要设置 mandatory 参数），因为它没有匹配任何路由键。

------



### 4）队列(Queue)

**Queue(消息队列)** 用来保存消息直到发送给消费者。**<font color='red'>它是消息的容器，也是消息的终点</font>**。一个消息可投入一个或多个队列。消息一直在队列里面，等待消费者连接到这个队列将其取走。

==**RabbitMQ** 中消息只能存储在 **队列** 中，这一点和 **Kafka** 这种消息中间件相反。Kafka 将消息存储在 **topic（主题）** 这个逻辑层面，而相对应的队列逻辑只是topic实际存储文件中的位移标识。 RabbitMQ 的生产者生产消息并最终投递到队列中，消费者可以从队列中获取消息并消费。==

<font color='red'>**多个消费者可以订阅同一个队列**，这时队列中的消息会被平均分摊（Round-Robin，即轮询）给多个消费者进行处理，而不是每个消费者都收到所有的消息并处理，这样避免的消息被重复消费。</font>

**RabbitMQ** 不支持队列层面的广播消费,如果有广播消费的需求，需要在其上进行二次开发,这样会很麻烦，不建议这样做。



### 5）消息中间件服务节点(Broker)

对于 RabbitMQ 来说，<font color='red'>一个 RabbitMQ Broker 可以简单地看作一个 RabbitMQ 服务节点，或者RabbitMQ服务实例</font>。大多数情况下也可以将一个 RabbitMQ Broker 看作一台 RabbitMQ 服务器。

下图展示了生产者将消息存入 RabbitMQ Broker,以及消费者从Broker中消费数据的整个流程。

![消息队列的运转过程](/Users/jc/Documents/JavaNote/wechat-food/67952922.jpg)



## 4、使用举例

引入依赖：

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-bus-amqp</artifactId>
    <!--            <version>2.1.1.RELEASE</version>-->
</dependency>
```



消息接收方法：

```java
/**
 * 数码供应商服务 接收消息
 * @param message
 */
@RabbitListener(bindings = @QueueBinding(
        exchange = @Exchange("myOrder"),
        key = "computer",
        value = @Queue("computerOrder")
))
public void processComputer(String message) {
    log.info("Computer MqReceiver: {}", message);
}

/**
 * 水果供应商服务 接收消息
 * @param message
 */
@RabbitListener(bindings = @QueueBinding(
        exchange = @Exchange("myOrder"),
        key = "fruit",
        value = @Queue("fruitOrder")
))
public void processFruit(String message) {
    log.info("Fruit MqReceiver: {}", message);
}
```



消息发送方法：

```java
public void sendOrder() {
    amqpTemplate.convertAndSend("myOrder", "computer", "now " + new Date());
}
```

