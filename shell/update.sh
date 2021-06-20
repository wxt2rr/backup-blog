#/bin/bash

cd /usr/hexo-blog/my-blog
git pull
docker exec -w /usr/blog/my-blog/ hexo-blog hexo clean
docker exec -w /usr/blog/my-blog/ hexo-blog hexo g
