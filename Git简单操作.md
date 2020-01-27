# Git简单操作

## 1、本地仓库建立

`git init`

## 2、与远程仓库连接ssh

> - `ssh-keygen -t rsa -C "你的邮箱"`，然后一直按回车
>
> - `cd ~/.ssh`文件夹中的公钥文件id_rsa.pub文件内容复制出来，放到github或gitee的对应位置上**(切记去掉最后的邮箱，保留斜杠)**
>
>   ![image-20200127173852621](PicSource/image-20200127173852621.png)
>
> - ssh -T git@gitee.com或 ssh -T git@github.com验证公钥配置是否成功

------





## 3、添加远程仓库地址

> git remote add [name] https://xxx：添加一个远程地址
>
> git remote -v：查看所有添加的远程地址
>
> ​	![image-20200127172447722](PicSource/image-20200127172447722.png)
>
> git status：查看当前本地仓库状态
>
> .gitignore文件：配置忽略项



## 4、问题

> - 若push时没反应，可能是缓冲问题，需要执行以下配置：
>
>   `git config http.postBuffer 524288000`
>
> - 查看config文件：`vim .git/config`
>
>   ![image-20200127174856166](PicSource/image-20200127174856166.png)
>
> - 可见，各种配置都在这里