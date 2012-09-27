#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: split.pl
#
#        USAGE: ./split.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 2012年09月27日 18时01分03秒
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

my $str = "http://www.google.com:9090/hello/dir/hello.txt";

my @list = split(/\//, $str, 4);

print $list[2], "\n";
print $list[3], "\n";
