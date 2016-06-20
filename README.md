#expirevid.pl  
  
Jerry Fath jerryfath at gmail dot com  
  
Recurse directories and expire episodes by age or count according to config files   

Usage [perl] expirevid.pl [-t] /toplevel/dir  
-t test run (no files will be deleted)  
  
Config files are named expirevid.cfg and have the format:  
maxage=#  
maxcount=#  
  
maxage is the maximum age in days before expiration.  0 means don't expire by age  
maxcount is the maximum number of video files in a directory  before oldest is expired.  0 means unlimited.  
  
Config files can occur anywhere in the directory tree.  The specified values are then 
used for the current tree level and lower until a new config file is found  
   
Video file extensions supported: .mkv, .mp4, .mpg, .mpeg, .avi  
  
WARNING: Mis-configuration can cause this script to delete things you want to keep  
Use the -t test run flag to make sure things are configured correctly!  
Double check your configuration and use at your own risk  
