#!/bin/bash

#Virtual Environment Setup

echo -e "\n------- Django Template Project Setup -------\n"

#user input for django config
read -p ">>> Set django 'projectname': " projectname
if [ "$projectname" == "" ]; then 
	echo -e "\nNo projectname has been given. Exiting setup.\n"; return; fi

read -p ">>> Set django 'appname': " appname
if [ "$appname" == "" ]; then
	echo -e "\nNo appname has been given. Exiting setup.\n"; return; fi

read -p ">>> Set django 'local ip', (default. 127.0.0.1): " localip
read -p ">>> Set django external 'ip' or 'url', (leave blank for none): " allowedhost
read -p ">>> Set django 'port', (default. 8000): " port
read -p ">>> Do you want to setup Nginx? [y/N]: " nginx 

if [ "$localip" == "" ]; then localip="127.0.0.1"; fi
if [ "$allowedhost" == "" ]; then allowedhost="None"; fi
if [ "$port" == "" ]; then port="8000"; fi

echo -e "\n============================================="
echo -e "\nSettings will be made as following:"
echo -e "----------------------------------------------"
echo -en "
Projectname:     $projectname 
Appname:         $appname 
Local IP:        $localip 
External URL:    $allowedhost
Port:            $port
Nginx:           "

if [ "$nginx" == "y" ] || [ "$nginx" == "Y" ]; 
then 
	echo -e "Yes\n"
else 
	echo -e "No\n"
fi

echo -e "----------------------------------------------\n"
echo -e "A python virtual environment (venv) will be created as well.\n"
echo -e "Note: No input settings are checked for correctness."
echo -e "Any settings you choose will be used regardless of legitimacy.\n" 

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
sed -i "s/'DIRS'\: \[\]/'DIRS'\: \[\'$appname\/templates\'\]/g" $settings
cat templfiles/misc/static-dir-code >> $settings
sed -i "s/appname_example/$appname/g" $settings
sed -i "/'django.contrib.staticfiles',/a #    DjangoApps\n    '$appname'," $settings
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \[\'$localip\'\]/g" $settings
if [ "$allowedhost" != "None" ]; then
	sed -i "s/ALLOWED_HOSTS = \[/ALLOWED_HOSTS = \['$allowedhost',/g" $settings 
fi


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
	echo -e "\nTo finish the NGINX setup you need to:\nManually move the .conf file to the Nginx available-sites and symlink it to sites-enabled."
	echo -e "The reason this script doesn't automatically without asking is because it requires superuser privileges, \nthus it is offered that the user does this last part of the setup manually."
	
	echo -e "\nIn the new django project directory, write the following commands in order with sudo:\n
	mv $siteconf /etc/nginx/sites-available/$siteconf
	ln -s /etc/nginx/sites-available/$siteconf /etc/nginx/sites-enabled/
	systemctl restart nginx\n
If you have another path to your nginx directory, use that instead.\n"

	read -p ">>> If you want this program to do it for you, answer 'yes' without quotes, any other input declines: " nginxmove
	if [ "$nginxmove" == "yes" ]; then
		echo -e "\nMoving $siteconf to /etc/nginx/sites-available/ and symlinking..."
		sudo mv $siteconf /etc/nginx/sites-available/$siteconf
		sudo ln -s /etc/nginx/sites-available/$siteconf /etc/nginx/sites-enabled/
		echo -e "Restarting NGINX..."
		sudo systemctl restart nginx
	fi
	echo -e "\nYou may now run the project with nginx using the 'nginx-run.sh' bash script in the django project directory.\n"
else
	echo -e "\nYou may now run the project with the run.sh bash script in the django project directory.\n"
fi



