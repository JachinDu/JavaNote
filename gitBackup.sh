msg=$1
if [ -n "$msg" ]; then
	git add .
	git commit -m "${msg}"
	git push gitee master
	git push javanote master
	git status
	echo "backup to gitee & github sucessfully!"
else
	echo "please add commit message!"
fi
