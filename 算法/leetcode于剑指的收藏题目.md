# leetcode于剑指的收藏题目

map的遍历：https://www.jianshu.com/p/3d1fb84b2b63



### 1、剑指offer

### &sect; 链表类

> - 孩子们的游戏(圆圈中最后剩下的数)（链表模拟）
> - 反转链表（链表）
> - 链表中倒数第k个结点
> - 【🎖🎖🎖🎖】二叉搜索树与双向链表（递归或栈+遍历）（中序遍历的递归和非递归法）
> - 【🎖🎖】复杂链表的复制(注意指针满天飞，判断null)
> - 删除链表中重复的结点（注意指针处理）
> - 【🎖】链表中环的入口结点：（快慢指针，相遇于环内一点，再让一个从链表头，一个从该相遇点开始，最终相遇即为入口）
> - 从尾到头打印链表

------



### &sect; 树类

> - 平衡二叉树（树）
>
> - 树的子结构（树）
>
> - 重建二叉树
>
> - 【🎖🎖🎖】二叉搜索树与双向链表
>
> - 【🎖】二叉树中和为某一值的路径(注意ArrayList做参数不要直接传引用)
>
> - 【🎖🎖🎖】二叉搜索树的后序遍历序列(判断某序列是否为一个二叉搜索树的后续遍历)：
>
>   ​	数组分界递归，每次末尾就是根，在前面找到左右子树分界点，并验证左右子树是否严格小于/大于根，然后递归验证左右子树序列。

------



### &sect; 数组类

> - 数组中的逆序对（归并排序）
>
> - 调整数组顺序使奇数位于偶数前面
>
> - 数字在排序数组中出现的次数（二分查找）：见到排序就可以想到二分
>
> - 【🎖🎖🎖】把数组排成最小的数(自定义Comparator)
>
> - 【🎖🎖】连续子数组的最大和(前面的和+当前值不可小于当前值，若小于，则起点重新从当前值开始)
>
> - 数组中只出现一次的数字：HashMap/ 异或
>
> - 【🎖🎖】机器人的运动范围：dfs/bfs 
>
> -  数组中重复的数字：
>
>   - 使用额外空间：
>
>     ```java
>     boolean[] visited = new boolean[length];
>     for(int i = 0; i < length; i++){
>       if(!visited[numbers[i]]){
>         visited[numbers[i]] = true;
>       }else{
>         duplication[0] = numbers[i];
>         return true;
>       }
>     }
>     return false;
>     ```
>
>   - 不使用额外空间，每次交换归位元素，归位冲突即发现重复元素：
>
>     ```java
>     int i = 0;
>     while(i < length){
>       if(numbers[i] != i){
>         int temp = numbers[numbers[i]];
>         if(temp == numbers[i]){
>           duplication[0] = temp;
>           return true;
>         }else{
>           numbers[numbers[i]] = numbers[i];
>           numbers[i] = temp;
>         }
>       }else{
>         i++;
>       }
>     }
>     return false;
>     ```
>
>     
>
> - 【🎖🎖🎖】构建乘积数组：构建二维（只用上三角，会有嵌套循环）&rArr;优化为上下三角
>
>   ![img](../PicSource/841505_1472459965615_8640A8F86FB2AB3117629E2456D8C652.jpeg)
>
>   

------



### &sect; 栈

> - 栈的压入、弹出序列（栈）
> - 包含min函数的栈（栈）

------



### &sect; 二进制与位运算

> - 二进制中1的个数
>
> - 求1+2+3+...+n
>
>   ```java
>   // 短路求值原理(&&前面为假后面就不计算了)
>   public class Solution {
>       public int Sum_Solution(int n) {
>           int ans = n;
>           boolean t=((ans!=0) && ((ans += Sum_Solution(n - 1))!=0));
>           return ans;
>       }
>   }
>   ```
>
>   

------



### &sect; 动态规划

> - 矩形覆盖

------



### &sect; 字符串类

> - 第一个只出现一次的字符
>
> - 【🎖🎖】字符串的排列(固定一位，递归交换)
>
> - 【🎖🎖】字符流中第一个不重复的字符：主要是LinkedHashMap/HashMap的遍历：
>
>   ```java
>   Iterator<Map.Entry<Character,Integer>> itr = map.entrySet().iterator();
>           while(itr.hasNext()){
>               Map.Entry entry = itr.next();
>               if(entry.getValue().equals(1)){
>                   return (char)entry.getKey();
>               }
>           }
>   ```
>
> - 【🎖】表示数值的字符串：疯狂判定
>
> - 【🎖🎖🎖🎖】正则表达式匹配：分清情况



### &sect; 穷举

> - 丑数
> - 【🎖🎖🎖】和为S的连续正数序列：等差数列+双指针