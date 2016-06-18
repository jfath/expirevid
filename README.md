#expirevid.pl  
  
   
Recurse all directories.  Expire episodes by age or count according to config files   
Config files are named expirevid.cfg and have the format:  
maxage=# 
maxcount=# 
Config files can occur anywhere in the directory tree.  The specified values are then 
used for the current tree level and lower until a new config file is found 
 