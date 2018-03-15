#!/bin/bash

#Virtual Environment Setup

echo -e "\n------- Django Template Project Setup -------\n"

#user input for django config
read -p ">>> Set django 'projectname': " projectname
read -p ">>> Set django 'appname': " appname
read -p ">>> Set django 'local ip', (ex. 0.0.0.0): " localip
read -p ">>> Set django 'port', (ex. 8000): " port

echo -e "\n============================================="
echo -e "\nSettings will be made as following:"
echo -e "Projectname: $projectname \nAppname: $appname \nLocal IP: $localip \nPort: $port\n"
echo -e "A python virtual environment (venv) will be created as well.\n"
echo -e "Note: No input settings are checked for correctness.\nAny settings you choose will be used regardless of legitimacy.\n" 
read -p "Proceed with these settings? [Y/n]: " correctconfig

#User Setting Consent Check
if [ "$correctconfig" == "n" ]; then 
	echo "\nDjango Project Config was manually interrupted! \n"
	exit	
fi

echo -e "\n============================================="
echo -e "--Setup: Creating virtual environment..."
echo -e "=============================================\n"
mkdir ../$projectname
virtualenv ../$projectname/venv 

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
#Places Static and Template folders into app
cp -r templfiles/static $projectname/$appname/static
cp -r templfiles/templates $projectname/$appname/templates

#Place views/urls files
cp templfiles/misc-files/main_urls.py $projectname/$projectname/urls.py
cp templfiles/misc-files/app_urls.py $projectname/$appname/urls.py
cp templfiles/misc-files/app_views.py $projectname/$appname/views.py
cp templfiles/misc-files/app_models.py $projectname/$appname/models.py
cp templfiles/misc-files/app_forms.py $projectname/$appname/forms.py
#Add Migration File
cp templfiles/misc-files/migrate.sh $projectname/migrate.sh
chmod +x $projectname/migrate.sh

#Modify views/urls/settings to route correctly
sed -i "s/appname/$appname/g" $projectname/$projectname/urls.py 
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \[\'$localip\'\]/g" $projectname/$projectname/settings.py
sed -i "s/'DIRS'\: \[\]/'DIRS'\: \[\'$appname\/templates\'\]/g" $projectname/$projectname/settings.py
cat templfiles/misc-files/static-dir-code >> $projectname/$projectname/settings.py
sed -i "s/appname_example/$appname/g" $projectname/$projectname/settings.py
sed -i "/'django.contrib.staticfiles',/a #    DjangoApps\n    '$appname'," $projectname/$projectname/settings.py



#Django migration
cd $projectname
echo -e "--Setup: Django Migration...\n"
#python3 manage.py makemigrations
python3 manage.py migrate

#Creating Run File
echo "#!/bin/bash" > run.sh
echo "source venv/bin/activate" >> run.sh
echo "python3 manage.py runserver $localip:$port" >> run.sh
chmod +x run.sh


#Moving the project out of the django-template directory
cd ..
deactivate
echo -e "\n--Setup: Moving Django Project out of the Django Template directory"
mv $projectname/* ../$projectname
rmdir $projectname
cd ../$projectname

#Initialization Complete
echo -e "\n============================================="
echo -e "------- Django Project Setup Complete -------"
echo -e "=============================================\n"

