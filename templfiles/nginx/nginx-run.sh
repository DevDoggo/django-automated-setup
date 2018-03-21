#!/bin/bash
source venv/bin/activate
uwsgi --ini project_uwsgi.ini

