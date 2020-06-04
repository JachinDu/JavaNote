msg=$1
if [ -n "$msg" ]; then
	git add .
	git commit -m "${msg}"
	git push javanote master
	git push gitee master
	echo "Success!"
	git status
else
	echo "please add commit msg!"
fi
