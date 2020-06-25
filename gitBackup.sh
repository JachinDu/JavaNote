#msg=$1
#if [ -n "$msg" ]; then
	git add .
	#git commit -m "${msg}"
	git commit --amend
    git push javanote master
	git push gitee master
	echo "Success!"
#else
#	echo "please add commit msg!"
#fi
