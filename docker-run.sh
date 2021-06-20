#! /bin/bash

docker run -itd -p 80:4000 -v /usr/hexo-blog/:/usr/blog --name hexo-blog hexo-image
docker exec -it hexo-blog /bin/bash
