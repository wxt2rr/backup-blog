# base image
FROM node:latest
# author
MAINTAINER xiaotao <1471520488@qq.com>
# npm
RUN npm install -g npm@7.16.0
# set home dir
WORKDIR /usr/blog
# install hexo
RUN npm install hexo-cli -g
# install hexo server
RUN npm install hexo-server
RUN npm install hexo-deployer-git
