msg=$1
if [ -n "$msg" ]; then
	git add .
	git commit -m "${msg}"
	git push gitee master
	git push javanote master
	echo "Success!"
	git status
else
	echo "please add commit msg!"
fi
