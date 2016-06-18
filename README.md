#expirevid.pl  
  
Jerry Fath jerryfath at gmail dot com  
  
Recurse directories and expire episodes by age or count according to config files   
Config files are named expirevid.cfg and have the format:  
maxage=# 
maxcount=# 
Config files can occur anywhere in the directory tree.  The specified values are then 
used for the current tree level and lower until a new config file is found 
    
  
WARNING: Mis-configuration can cause this script to delete things you want to keep  
Double check your configuration and use at your own risk  
