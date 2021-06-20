#! /bin/bash

cd /usr/hexo-blog/my-hexo-blog
git pull
docker exec hexo-blog hexo clean
docker exec hexo-blog hexo g
