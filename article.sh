#!/bin/zsh

# 커밋 메시지와 함께 이 쉘 스크립트 파일 실행

git add .
git commit -m "$1"
git push origin development

npm run publish article
npm run deploy

git add .
git commit -m "$1 sitemap"
git push origin development

npm run deploy
