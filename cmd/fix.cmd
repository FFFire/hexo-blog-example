@echo off
cd ..
call hexo.cmd
echo git上传开始
git add -A
git commit -a -m "fix"
git push origin blog
echo git上传完毕