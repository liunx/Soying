package Tr69c;
#===============================================================================
#
#         FILE: Tr69c.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 2012年09月27日 13时40分39秒
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use Data::Dumper;
use XML::Simple qw(:strict);
use Carp; 

# custom object
use Tr69HTTP;

# store the global objects
my $_OBJS = {};
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Constructor new
# 	url => url
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub new {
	my $class = shift;
	my $self = {@_};
	bless($self, $class);

	my $url = $self->{url};
	if (not defined $url) {
		croak "url => url\n";
	}
	$_OBJS->{url} = $url;

	return $self;
}

# _post just generate a http header without content
# require url
# return a reference to http object
sub _post {
	my $url = shift;
	my $http = Tr69HTTP->new();
	$http->url($url);
	$http->method('POST');
	$http->agent('Soying CPE/1.0');
	my $custom_content = $http->custom_content();
	$custom_content->{'Connection'} = 'keep-alive';
	$custom_content->{'Content-Type'} = 'text/xml; charset=utf-8';
	$custom_content->{'SOAPAction'} = '""';

	$_OBJS->{http} = $http;

	return $http;
}

sub url {
	my $self = shift;
	my $url = shift;

	$_OBJS->{url} = $url;
	return $self;
}

# send inform messages
# inform => inform.xml
sub set_inform {
	my $self = shift;
	my $params = {@_};
	unless (ref $self) {
		croak "Should call set_inform() with an object!";
	}

	if (!defined $params->{inform}) {
		croak "Get inform xml $params->{inform} failed!";
	}

	my $file = XMLin(
		$params->{inform}, 
		KeepRoot => 1, 
		KeyAttr => 1, 
		ForceArray => 1, 
		NormaliseSpace => 1
	);

	my $xml = XMLout($file, KeyAttr => 1, KeepRoot => 1, NoSort => 1);
	
	# we still need add http head
	my $http = _post($_OBJS->{url});
	$http->content($xml);
	my $inform = $http->gen_http();
	$_OBJS->{inform} = $inform;

	return $self;
}

sub get_inform {
	return $_OBJS->{inform};
}


1;
