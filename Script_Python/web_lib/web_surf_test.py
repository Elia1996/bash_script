#!/usr/bin/python3
from web_surf import *
dri=web_surf(True)
dri.open_site("https://accounts.google.com/signin/v2/identifier?service=mail&passive=true&rm=false&continue=https%3A%2F%2Fmail.google.com%2Fmail%2F&ss=1&scc=1&ltmpl=default&ltmplcache=2&emr=1&osid=1&flowName=GlifWebSignIn&flowEntry=ServiceLogin")
dri.login("identifierId","password", "ribaldoneelia@gmail.com","scarranotipo19")
