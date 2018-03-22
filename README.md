This is a package with a bash-script as well as other default-styled files for a newly created Django Project. 
This was developed to speed up django-project creation. In many cases you need to do the exact same setup to begin with,
and this is meant to turn thirty-to-sixty minutes of setting up the config yourself into a less-than-a-minute automated setup.

Pro-Tip: If you know nothing of Django, learn to set up a project manually first. This software does not help a new person learn how to use django, 
it simply saves time for the people who already have some knowledge.

## How it Works
You're asked to give Projectname, Appname, Local Debug-IP, Exteral IP and Port. That's all!
After that, the Django-setup will be fully automated! You'll be ready to run the application straight off the bat with the run.sh file created in the project setup!

Now with NGINX configuration as well!

## How to Run

git clone https://github.com/DevDoggo/django-automated-setup<br />
cd django-advanced-template<br />
chmod +x setup.sh<br />

./setup.sh <br />
or <br />
. ./setup.sh<br />
(Option two will put your terminal current directory to the created project's)

Note: The input you give in the setup.sh script must be perfectly correct and useable, 
because there is no form of correctness-checking performed at all.
It is assumed that you don't want to sabotage and break your own project. :)

# Dependencies
Python Virtualenv<br />
A linux-based terminal with Bash scripting
