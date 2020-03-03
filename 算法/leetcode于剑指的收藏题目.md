# leetcode与剑指的收藏题目

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
> - 【🎖🎖🎖】 [K 个一组翻转链表](https://leetcode-cn.com/problems/reverse-nodes-in-k-group/)

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
>   
> - 二叉搜索树的第k个结点
>
> - 对称的二叉树：左子树==右子树
>
> - 【🎖🎖🎖】二叉树的下一个结点：若有右子树，则递归找到右子树最左叶子节点即可。若无则向父节点递归，直到找到当前节点是父节点的左子树，则返回父节点。
>
> - 按之字形顺序打印二叉树：正反序迭代器：iterator/descendingIterator
>
> - 【🎖🎖🎖】序列化二叉树：关键是利用前序遍历序列重构二叉树：
>
>   ```java
>   TreeNode Deserialize(String str) {
>           String[] strs = str.split("!");
>           Queue<String> queue = new LinkedList<>();
>           for(int i = 0; i < strs.length; i++){
>               queue.add(strs[i]);
>           }
>           return reConstruct(queue);
>     }
>       public TreeNode reConstruct(Queue<String> queue){
>           String val = queue.poll();
>           if(val.equals("#")){
>               return null;
>           }
>           TreeNode node = new TreeNode(Integer.parseInt(val));
>           node.left = reConstruct(queue);
>           node.right = reConstruct(queue);
>           return node;
>       }
>   ```
>
>   

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
> - 【🎖🎖🎖】矩阵中的路径：dfs+记忆矩阵（注意走过的路若不对要恢复记忆矩阵(回溯的感觉))
>
> - 【🎖🎖🎖】滑动窗口的最大值：可用堆
>
> - 【🎖🎖🎖】 [下一个排列](https://leetcode-cn.com/problems/next-permutation/)
>
> -  [子集](https://leetcode-cn.com/problems/subsets/)
>
> -   [数组中的第K个最大元素](https://leetcode-cn.com/problems/kth-largest-element-in-an-array/)：快速选择（利用快排的partition，因为归位的元素便已知是第几大）/或用最小堆
>
> - [较小的三数之和]([较小的三数之和](https://leetcode-cn.com/problems/kth-largest-element-in-an-array/))：遍历+双指针
>
> -  [接雨水](https://leetcode-cn.com/problems/trapping-rain-water/)：每个点能储水的高度等于其与左右两边最大值中的较小者之差。
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



### &sect; 栈/堆

> - 栈的压入、弹出序列（栈）
> - 包含min函数的栈（栈）
> - 【🎖🎖🎖】数据流中的中位数：双堆法：先往大堆放，再将满足条件的转移到小堆
> - 【🎖🎖🎖】 [简化路径](https://leetcode-cn.com/problems/simplify-path/)

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
> - 【🎖🎖】 [不同路径](https://leetcode-cn.com/problems/unique-paths/)：机器人走路
> - 【🎖🎖】 [最小路径和](https://leetcode-cn.com/problems/minimum-path-sum/)：和上一题如出一辙
> -  【🎖🎖🎖🎖】[编辑距离](https://leetcode-cn.com/problems/edit-distance/)
> - 【🎖🎖】[ 买卖股票的最佳时机](https://leetcode-cn.com/problems/best-time-to-buy-and-sell-stock/)
> -  [买卖股票的最佳时机 II](https://leetcode-cn.com/problems/best-time-to-buy-and-sell-stock-ii/)
> -  【🎖🎖】 [完全平方数](https://leetcode-cn.com/problems/perfect-squares/)：找出前面最小dp[i]
> -  【🎖🎖】 [最长上升子序列](https://leetcode-cn.com/problems/longest-increasing-subsequence/)：找出前面最大dp[i]
> -  【🎖🎖🎖】 [二维区域和检索 - 矩阵不可变](https://leetcode-cn.com/problems/range-sum-query-2d-immutable/)
> -  【🎖🎖🎖】 [最大正方形](https://leetcode-cn.com/problems/maximal-square/)：`dp[i][j] = 1 + min(dp[i-1][j-1], dp[i-1][j], dp[i][j-1]);`

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
>
> - 【🎖】 [复原IP地址](https://leetcode-cn.com/problems/restore-ip-addresses/)



### &sect; 穷举

> - 丑数
> - 【🎖🎖🎖】和为S的连续正数序列：等差数列+双指针

------

### &sect; 回溯法

> - 【🎖🎖🎖🎖】 [N皇后](https://leetcode-cn.com/problems/n-queens/)

------

### &sect; dfs/bfs

> - 【🎖🎖🎖】 [岛屿数量](https://leetcode-cn.com/problems/number-of-islands/)：递归去“连岛成片”，每次连到头都是发现了一座孤独的大岛。

------

### &sect; 数据结构设计

> - 【🎖🎖🎖】 [常数时间插入、删除和获取随机元素](https://leetcode-cn.com/problems/insert-delete-getrandom-o1/)：hashmap+list，hashmap存list中的下标，删除时若要删除的元素下标不是list末尾，则将末尾元素赋给目标位置即可，然后删除末尾。