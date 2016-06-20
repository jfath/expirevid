#!/usr/bin/perl

# Jerry Fath jerryfath at gmail dot com
#
# Recurse directories and expire episodes by age or count according to config files
# Config files are named expirevid.cfg and have the format:
# maxage=#
# maxcount=#
# Config files can occur anywhere in the directory tree.  The specified values are then
# used for the current tree level and lower until a new config file is found
#
# 
#Copyright (c) 2016 Jerry Fath
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this
#software and associated documentation files (the "Software"), to deal in the Software
#without restriction, including without limitation the rights to use, copy, modify,
#merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
#permit persons to whom the Software is furnished to do so, subject to the following
#conditions:
#
#The above copyright notice and this permission notice shall be included in all copies
#or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
#PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
#OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
#DEALINGS IN THE SOFTWARE.
#

use strict;
use warnings;
use Cwd;

use File::Find;
use File::Copy;
use File::Basename;
use File::stat;

my $TestRun=0;
my $MinArgs=1;
my $ArgC = @ARGV;
if (($ArgC > 0) && ($ARGV[0] eq "-t")) {
    $TestRun=1;
    ++$MinArgs;
}

#For safety when testing
#$TestRun=1;

if ( $ArgC < $MinArgs ) {
    print "Usage: expirevid.pl [-t] basedir\n";
    exit -1;
}

my $BaseDir = $ARGV[$MinArgs-1];
my $StartDir = cwd;

my $ExpireCount=0;
#Maximum age in days
my $DefMaxAge=0;
my $CurMaxAge;
my @MaxAge;
#Maximum files in dir
my $DefMaxCount=0;
my $CurMaxCount;
my @MaxCount;

#Video File Extensions
my @VidExtensions=(".mkv", ".mp4", ".mpg", ".mpeg", ".avi");

#Track depth in tree
my $CurDepth;
my $NewDepth;

#Used to hold directory items and dates for expiring by count
my @VidFileInfo;

print "expirevid: Expiring from $BaseDir on ";
print scalar localtime() . "\n";
if ($TestRun != 0) {print "expirevid: TestRun: No files will be removed\n";}

#Set up initial values
$CurDepth = ($BaseDir=~tr!/!/!);
$CurMaxAge=$DefMaxAge;
$CurMaxCount=$DefMaxCount;
readconfig("$BaseDir/expirevid.cfg");
$MaxAge[$CurDepth]=$CurMaxAge;
$MaxCount[$CurDepth]=$CurMaxCount;

# Issue the find command passing two arguments
# The first argument is the subroutine that will be called for each file in the path.
# The second argument is the directory to start your search in.
find(\&checkexpire, "$BaseDir");

#Change back to starting dir
#NEEDED?
chdir $StartDir;
#All done
print "expirevid: Found $ExpireCount video file(s) ready for expiration\n";
exit 0;

# Subroutine that determines whether we should expire each file
sub checkexpire {

#Used to break current filename into components
my $CurName; my $CurDir; my $CurExt; my $CurPath;
my $CurFileAge; my $CurFileCount;

    $CurPath=$File::Find::name;
    ($CurName, $CurDir, $CurExt) = fileparse($CurPath, qr/\.[^.]*/);

    #If we're in a different directory adjust MaxAge/MaxCount
    $NewDepth = ($CurDir=~tr!/!/!);
    if ($NewDepth != $CurDepth) {
        if ($NewDepth < $CurDepth) {
          #If we're moving back up the tree get the saved level
	  $CurMaxAge = $MaxAge[$NewDepth];
	  $CurMaxCount = $MaxCount[$NewDepth];
        }
        else {
            #If we're moving down into the tree, we read the config file just before we moved down so the
            #Max values would be correct for expire by count
        }
        $CurDepth = $NewDepth;
        #Save MaxAge for this level
        $MaxAge[$CurDepth]=$CurMaxAge;
        $MaxCount[$CurDepth]=$CurMaxCount;
    }

    #Check if current entry is a directory
    if ( -d $CurPath) {
        #Read config file from directory we're about to traverse into so
        #MaxCount will be correct.
        readconfig("$CurPath/expirevid.cfg");
        #print "expirevid: Directory: $CurPath MA:$CurMaxAge MC:$CurMaxCount\n";
        #If we're expiring by count find the files
        if ($CurMaxCount != 0) {
            getvideofiles("$CurPath");
       	    #If array count is greater than MaxCount, sort by date and delete oldest
            $CurFileCount = $#VidFileInfo+1;
            if ( $CurFileCount > $CurMaxCount ) {
              #Sort files by age
              @VidFileInfo = sort {$a->[1] <=> $b->[1]} @VidFileInfo;
              for (my $i=1;$i<=($CurFileCount-$CurMaxCount);$i++) {
                  print "expirevid: unlink $VidFileInfo[0-$i][0] count:$CurFileCount max:$CurMaxCount\n";
                  ++$ExpireCount;
	          if ($TestRun == 0) {
                      unlink $VidFileInfo[0-$i][0] or warn "Could not unlink $_: $!";
	          }
	      }
	    }
        }
    }
    elsif (grep {$_ eq $CurExt} @VidExtensions) {
        #print "expirevid: File: $CurPath\n";
        #Check file age and expire if file is older than threshold
        if ($CurMaxAge != 0) {
            $CurFileAge = ( -M $CurPath);
            if ($CurFileAge > $CurMaxAge) {
              print "expirevid: unlink $CurPath age:$CurFileAge max:$CurMaxAge\n";
              ++$ExpireCount;
	      if ($TestRun == 0) {
                  unlink $CurPath or warn "Could not unlink $_: $!";
	      }
            }
       }
    }
}

#Read a config file
#Ugly Note: We're setting $CurMaxAge and $CurMaxCount globals directly
sub readconfig {

my $CfgName = shift;
my @CfgLine;

    #print "expirevid: Reading config File: $CfgName\n";

    if (-e "$CfgName") {
        open(FILE, "<$CfgName") || warn "expirevid ERROR: Couln't open Config: $!";
	while (<FILE>) {
	  next if (/^#/);
	  chomp;
	  @CfgLine = split(/=/);
	  if ($CfgLine[0] eq "maxage") {$CurMaxAge=$CfgLine[1];}
	  if ($CfgLine[0] eq "maxcount") {$CurMaxCount=$CfgLine[1];}
	}
	close(FILE);
      }
}

# Subroutine called by find to load all video file info into an array
sub getvideofiles {

my $CurDir = shift;
my @VidFiles;

    #Read the directory and save file names that match our video extensions
    opendir(my $dh, $CurDir) || warn "can't opendir $CurDir: $!";
    @VidFiles = grep { 
                   /$VidExtensions[0]/
                   || /$VidExtensions[1]/
                   || /$VidExtensions[2]/
                   || /$VidExtensions[3]/
                   || /$VidExtensions[4]/
                 } readdir($dh);
    closedir $dh;

    # Clear the file info array
    @VidFileInfo = ();
    # Loop through the local array pushing file names and ages onto our global array
    foreach my $file (@VidFiles) {
        push @VidFileInfo, ["$CurDir/$file", ( -M "$CurDir/$file")];
    }

}

