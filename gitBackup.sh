
if [ -n "$1" ]; then
	git add .
	git commit -m "$1"
	git push gitee master
	git push javanote master
	git status
	echo "backup to gitee & github sucessfully!"
else
	echo "please add commit message!"
fi
exit 0
