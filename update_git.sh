cd ~/runbooks_linux
sleep 10
git add .
sleep 10
git commit -m "update runbooks"
sleep 10
git push
sleep 10
mkdocs gh-deploy
