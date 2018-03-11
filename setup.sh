#!/bin/bash

echo -e "============================================="
echo -e "--Setup: Creating virtual environment..."
echo -e "=============================================\n"
virtualenv venv 

echo -e "--Setup: Starting virtual environment...\n"
source venv/bin/activate

echo -e "============================================="
echo -e "--Setup: Installing requirements with pip3..."
echo -e "=============================================\n"
pip3 install -r requirements.txt
echo -e "--Setup: Dependencies are done.\n"


#django config 
echo -e ">>>>>>>============Django=============<<<<<<<"
echo -e "--Setup: Django Project Config up next:"
echo -e "=============================================\n"

#user input for django config
echo -e ">>> Set django 'projectname':"
read projectname
echo -e ">>> Set django 'appname':"
read appname
echo -e ">>> Set django 'local ip': (ex, 0.0.0.0)"
read localip

#django project and app creation
django-admin startproject $projectname
cd $projectname
python3 manage.py startapp $appname


cd ..
#Places Static and Template folders into app
cp -r static $projectname/$appname/static
cp -r templates $projectname/$appname/templates

#Place views/urls files
cp misc-files/main_urls.py $projectname/$projectname/urls.py
cp misc-files/app_urls.py $projectname/$appname/urls.py
cp misc-files/app_views.py $projectname/$appname/views.py


#Modify views/urls/settings to route correctly
sed -i "s/appname/$appname/g" $projectname/$projectname/urls.py 
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \[\'$localip\'\]/g" $projectname/$projectname/settings.py
sed -i "s/'DIRS'\: \[\]/'DIRS'\: \[\'$appname\/templates\'\]/g" $projectname/$projectname/settings.py
