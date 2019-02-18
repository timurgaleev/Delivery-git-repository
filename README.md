# CD git repository project

This project delivery  git repository in your server
## What you'll need
- Teamcity
- IIS
- git
- choco

## Preparing
  choco install git -y
  cd C:\inetpub\wwwroot\SITE
  git config --system --unset credential.helper                                       
  git clone https://gituser_USERNAME@github.com/PROJECT/ID-PROJECT.git frontend        #cloning git in folder
  cd frontend
  git config credential.helper store
  git fetch
  git checkout BRANCH
  git pull
For the back need try do use: FrontendOfGit.Web.Config
