# File so I can record notes on setting up Git repositories since I can't seem to "committ" it to memory

```terminal
One time global git bash setup config in bash terminal: 

uia09337@CQL4137W MINGW64 ~
$ git --version
git version 2.52.0.windows.1

uia09337@CQL4137W MINGW64 ~
$ git config --global user.name "Cameron Jamrok"

uia09337@CQL4137W MINGW64 ~
$ git config --global user.email "cameron.jamrok@conti-na.com"

uia09337@CQL4137W MINGW64 ~
$ git config --global core.editor "nano"

uia09337@CQL4137W MINGW64 ~
$ git config --list --show-origin
file:C:/Users/uia09337/AppData/Local/Programs/Git/etc/gitconfig diff.astextplain.textconv=astextplain
file:C:/Users/uia09337/AppData/Local/Programs/Git/etc/gitconfig filter.lfs.clean=git-lfs clean -- %f
file:C:/Users/uia09337/AppData/Local/Programs/Git/etc/gitconfig filter.lfs.smudge=git-lfs smudge -- %f
file:C:/Users/uia09337/AppData/Local/Programs/Git/etc/gitconfig filter.lfs.process=git-lfs filter-process
file:C:/Users/uia09337/AppData/Local/Programs/Git/etc/gitconfig filter.lfs.required=true
file:C:/Users/uia09337/AppData/Local/Programs/Git/etc/gitconfig http.sslbackend=schannel
file:C:/Users/uia09337/AppData/Local/Programs/Git/etc/gitconfig core.autocrlf=true
file:C:/Users/uia09337/AppData/Local/Programs/Git/etc/gitconfig core.fscache=true
file:C:/Users/uia09337/AppData/Local/Programs/Git/etc/gitconfig core.symlinks=false
file:C:/Users/uia09337/AppData/Local/Programs/Git/etc/gitconfig pull.rebase=false
file:C:/Users/uia09337/AppData/Local/Programs/Git/etc/gitconfig credential.helper=manager
file:C:/Users/uia09337/AppData/Local/Programs/Git/etc/gitconfig credential.https://dev.azure.com.usehttppath=true
file:C:/Users/uia09337/AppData/Local/Programs/Git/etc/gitconfig init.defaultbranch=master
file:C:/Users/uia09337/.gitconfig       core.editor=nano
file:C:/Users/uia09337/.gitconfig       user.email=cameron.jamrok@conti-na.com
file:C:/Users/uia09337/.gitconfig       user.name=Cameron Jamrok
file:C:/Users/uia09337/.gitconfig       gui.recentrepo=C:/Users/uia09337/AppData/Roaming/DBeaverData/workspace6/Luke_Barousse_Intermediate_SQL_Training_Course - Copy because GIT HUB is RUDE

uia09337@CQL4137W MINGW64 ~
$
```

## Init Git
```git
once your terminal is pointed to the correct repository, use "git init" in terminal. Then your hidden git folder will appear in explorer. 
```

![alt text](image-1.png)
![alt text](<../Images/Screenshot 2026-08-16 172429.png>)
## Git Branching
![alt text](<../Images/Screenshot 2026-08-16 172637.png>)

- also ran this code to make "main" the default primary branch, not "master". 
- This was a global config setting so I shouldn't have to run it ever again. 
- ```git config --global init.defaultBranch main```


