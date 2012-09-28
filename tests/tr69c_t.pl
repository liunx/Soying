#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: tr69c_t.pl
#
#        USAGE: ./tr69c_t.pl  
#
#  DESCRIPTION: test for Tr69c.pm
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 2012年09月27日 14时27分10秒
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

push @INC, "..";
require Tr69c;

my $obj = Tr69c->new(
	url => 'http://10.129.228.68:8080/openacs/acs'
);

$obj->set_inform(inform => '../xml/inform.xml');
my $str = $obj->get_inform();

print $str;
