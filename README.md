#expirevid.pl  
  
Jerry Fath jerryfath at gmail dot com  
  
Recurse directories and expire episodes by age or count according to config files   

Usage [perl] expirevid.pl [-t] /toplevel/dir  
-t test run no files will be deleted  
  
Config files are named expirevid.cfg and have the format:  
maxage=# 
maxcount=# 
Config files can occur anywhere in the directory tree.  The specified values are then 
used for the current tree level and lower until a new config file is found  
A value of 0 for maxage or maxcount means don't expire by age or count respectively  
    
Video file extensions supported: .mkv, .mp4, .mpg, .mpeg, .avi  
  
WARNING: Mis-configuration can cause this script to delete things you want to keep  
Double check your configuration and use at your own risk  
