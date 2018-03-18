#!/bin/bash

dir=$(pwd)
projdir="$(dirname "$dir")"
projname="mysite"



echo $projdir

sed -i "s,/path/to/your/project,$projdir/$projname,g" templfiles/nginx/site_nginx.conf
sed -i "s,project,$projname,g" templfiles/nginx/site_nginx.conf

sed -i "s,/path/to/your/project,$projdir/$projname,g" templfiles/nginx/uwsgi.ini
sed -i "s,project,$projname,g" templfiles/nginx/uwsgi.ini

