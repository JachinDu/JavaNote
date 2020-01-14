# mybatis整合ehcache

<mark>mybatis将Cache接口留给第三方缓存库来实现</mark>



1、导包：

![image-20190607232032883](/Users/jc/Library/Application Support/typora-user-images/image-20190607232032883.png)



2、ehcache.xml

```xml
<ehcache xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="../config/ehcache.xsd">
    <diskStore path="/Users/jc/Desktop" />
    <defaultCache
            maxElementsInMemory="1"
            maxElementsOnDisk="10000000"
            eternal="false"
            overflowToDisk="true"
            timeToIdleSeconds="120"
            timeToLiveSeconds="120"
            diskExpiryThreadIntervalSeconds="120"
            memoryStoreEvictionPolicy="LRU">
    </defaultCache>
</ehcache>
```





3、要使用ehcache的映射文件

如在EmployeeMapper.xml加入:

```xml
<!--    <cache eviction="FIFO" flushInterval="60000" readOnly="false" size="1024"></cache>-->
<cache type="org.mybatis.caches.ehcache.EhcacheCache"></cache>
```

将原有的二级缓存配置改为ehcache配置



4、其他映射文件若也想配置ehcache则引用已配置了ehcache的映射文件的命名空间即可，如

DepartmentMapper.xml：

```xml
<cache-ref namespace="mybatis.dao.EmployeeMapper"/>
```