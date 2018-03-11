#!/bin/bash

echo -e "============================================"
echo -e "--Setup: Creating virtual environment...".
echo -e "============================================\n"
virtualenv venv

echo -e "--Setup: Starting virtual environment...\n"
source venv/bin/activate

echo -e "============================================"
echo -e "--Setup: Installing requirements with pip3..."
echo -e "============================================\n"
pip3 install -r requirements.txt
echo -e "--Setup: Dependencies are done.\n"


echo -e ">>>>>>>===========Django=============<<<<<<<"
echo -e "--Setup: Django Project Config up next:"
echo -e "============================================\n"

# Ask the user for their name
echo -e ">>> Set django 'projectname':"
read projectname
echo -e ">>> Set django 'appname':"
read appname

django-admin startproject $projectname
cd $projectname
python3 manage.py startapp $appname

