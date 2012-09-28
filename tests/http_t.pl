#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: http_t.pl
#
#        USAGE: ./http_t.pl  
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
#      CREATED: 2012年09月28日 09时52分25秒
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

push @INC, "..";
require Tr69HTTP;

my $http = Tr69HTTP->new();
$http->url('http://10.129.228.68:8080/openacs/acs');
$http->method('POST');
$http->agent('Soying CPE/1.0');
$http->content('Hello,world!');
my $custom_content = $http->custom_content();
$custom_content->{'Connection'} = 'keep-alive';
$custom_content->{'Content-Type'} = 'text/xml; charset=utf-8';
$custom_content->{'SOAPAction'} = '""';

my $str = $http->gen_http();

print "$str\n";
