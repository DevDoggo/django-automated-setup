#!/bin/bash

#Virtual Environment Setup

echo -e "\n------- Django Template Project Setup -------\n"

#user input for django config
read -p ">>> Set django 'projectname': " projectname
read -p ">>> Set django 'appname': " appname
read -p ">>> Set django 'local ip', (ex. 127.0.0.1): " localip
read -p ">>> Set django 'public ip' or 'url', (leave blank for none): " allowedhost
read -p ">>> Set django 'port', (ex. 8000): " port
read -p ">>> Do you want to setup Nginx? [y/N]: " nginx 

echo -e "\n============================================="
echo -e "\nSettings will be made as following:"
echo -e "Projectname: $projectname \nAppname: $appname \nLocal IP: $localip \nExternal URL: $allowedhost\nPort: $port"

if [ "$nginx" == "y" ] || [ "$nginx" == "Y" ]; 
then 
	echo -e "Nginx: Yes\n"
else 
	echo -e "Nginx: No\n"
fi

echo -e "A python virtual environment (venv) will be created as well.\n"
echo -e "Note: No input settings are checked for correctness.\nAny settings you choose will be used regardless of legitimacy.\n" 
read -p "Proceed with these settings? [Y/n]: " correctconfig

#User Setting Consent Check
if [ "$correctconfig" == "n" ] || [ "$correctconfig" == "N" ]; 
then 	
	echo -e "\n>>>>>>>==================================<<<<<<<"
	echo -e "Django Project Config was manually interrupted!"
	echo -e ">>>>>>>==================================<<<<<<<\n"
	return	
fi

echo -e "\n============================================="
echo -e "--Setup: Creating virtual environment..."
echo -e "=============================================\n"

mkdir ../$projectname
virtualenv --python=python3 ../$projectname/venv

echo -e "--\nSetup: Starting virtual environment...\n"

source ../$projectname/venv/bin/activate

echo -e "============================================="
echo -e "--Setup: Installing requirements with pip3..."
echo -e "=============================================\n"

pip3 install -r requirements.txt

echo -e "\n--Setup: Dependencies are done.\n"

#Django Config 
echo -e ">>>>>>>============Django=============<<<<<<<"
echo -e "--Setup: Django Project Config up next:"
echo -e "============================================="

#django project and app creation
django-admin startproject $projectname
cd $projectname
python3 manage.py startapp $appname

cd .. #brings us back up to document root
echo -e "\n--Setup: Configuring local files...\n" 

appdir=$projectname/$appname
projappdir=$projectname/$projectname
settings=$projappdir/settings.py

#Places Static and Template folders into app
cp -r templfiles/static $appdir/static
cp -r templfiles/templates $appdir/templates

#Place views/urls files
cp templfiles/misc/main_urls.py $projappdir/urls.py
cp templfiles/misc/app_urls.py $appdir/urls.py
cp templfiles/misc/app_views.py $appdir/views.py
cp templfiles/misc/app_models.py $appdir/models.py
cp templfiles/misc/app_forms.py $appdir/forms.py
#Add Migration File
cp templfiles/misc/migrate.sh $projectname/migrate.sh
chmod +x $projectname/migrate.sh

#Modify views/urls/settings to route correctly
sed -i "s/appname/$appname/g" $projappdir/urls.py 
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \[\'$localip\'\]/g" $settings
sed -i "s/ALLOWED_HOSTS = \[/ALLOWED_HOSTS = \['$allowedhost',/g" $settings 
sed -i "s/'DIRS'\: \[\]/'DIRS'\: \[\'$appname\/templates\'\]/g" $settings
cat templfiles/misc/static-dir-code >> $settings
sed -i "s/appname_example/$appname/g" $settings
sed -i "/'django.contrib.staticfiles',/a #    DjangoApps\n    '$appname'," $settings

#Django migration
cd $projectname
echo -e "--Setup: Django Migration...\n"
python3 manage.py makemigrations
python3 manage.py migrate

#python collect static - redirects output to /dev/null
echo -e "\n--Setup: Collecting Django Static Files...\n"
python3 manage.py collectstatic > /dev/null


#Creating Run File
echo "#!/bin/bash" > run.sh
echo "source venv/bin/activate" >> run.sh
echo "python3 manage.py runserver $localip:$port" >> run.sh
chmod +x run.sh

cd ..
#NGINX config ---------------------------------------------
#User Setting Consent Check
if [ "$nginx" == "y" ] || [ "$nginx" == "Y" ];  
then 
	echo -e "\n============================================="
	echo -e "--------------- NGINX Setup -----------------"
	echo -e "=============================================\n"
	echo -e "--Setup: Installing uWGSI...\n"

	pip3 install uwsgi

	curdir=$(pwd)
	projectdir="$(dirname "$curdir")"
	sitedir=$projectdir/$projectname
	echo $sitedir
	echo -e "\n--Setup: Moving Nginx files..."

	uwsgiini="_uwsgi.ini"
	siteconf="_nginx.conf"
	uwsgiini=$projectname$uwsgiini
	siteconf=$projectname$siteconf
	cp templfiles/nginx/uwsgi.ini $sitedir/$uwsgiini
	cp templfiles/nginx/uwsgi_params $sitedir/uwsgi_params
	cp templfiles/nginx/site_nginx.conf $sitedir/$siteconf
	cp templfiles/nginx/nginx-run.sh $sitedir/nginx-run.sh
	chmod +x $sitedir/nginx-run.sh

	echo -e "\n--Setup: Routing Nginx files to the Django project..."

	echo "$sitedir"
	sed -i "s,/path/to/your/project,$sitedir,g" $sitedir/$siteconf
	sed -i "s,project,$projectname,g" $sitedir/$siteconf
	sed -i "s,/path/to/your/project,$sitedir,g" $sitedir/$uwsgiini
	sed -i "s,project,$projectname,g" $sitedir/$uwsgiini	
	sed -i "s,project,$projectname,g" $sitedir/nginx-run.sh
fi



#Moving the project out of the django-template directory
echo -e "\n--Setup: Moving Django Project out of the Django Template directory"

deactivate
mv $projectname/* ../$projectname
rmdir $projectname
cd ../$projectname

#Initialization Complete
echo -e "\n============================================="
echo -e "------- Django Project Setup Complete -------"
echo -e "=============================================\n"

if [ "$nginx" == "y" ] || [ "$nginx" == "Y" ];  
then 
	echo -e "\nTo finish the NGINX setup you need to manually move the .conf file to the Nginx available-sites and symlink it to sites-enabled."
	echo -e "The reason this script doesn't do it is because it requires superuser privileges, thus it is preferably that the user personally does this last part of the setup."

	echo -e "\nIn the django project directory, write the following commands in order with sudo:\n"
	sudo mv $siteconf /etc/nginx/sites-available/$siteconf
	sudo ln -s /etc/nginx/sites-available/$siteconf /etc/nginx/sites-enabled/
	sudo systemctl restart nginx
fi
