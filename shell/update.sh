#/bin/bash

cd /usr/hexo-blog/my-blog
git pull
docker exec hexo-blog hexo clean
docker exec hexo-blog hexo g
docker exec hexo-blog hexo d
