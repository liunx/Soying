package Tr69HTTP;
#===============================================================================
#
#         FILE: HTTP.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 2012年09月27日 17时16分03秒
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Carp; 

# ===========================================================================
# params:
# 	url, method
# ===========================================================================

my $http = {};
my $custom_contents = {};

sub new {
	my $class = shift;
	my $self = {@_};
	bless($self, $class);

	return $self;
}

sub url {
	my $self = shift;
	unless (ref $self) {
		croak "Should be call with an object!";
	}
	my $url = shift;

	# TODO we should valid the url
	$http->{url} = $url;
}

sub method {
	my $self = shift;
	unless (ref $self) {
		croak "Should be call with an object!";
	}
	my $method = shift;
	$http->{method} = $method;
}

sub agent {
	my $self = shift;
	unless (ref $self) {
		croak "Should be call with an object!";
	}
	my $agent = shift;
	$http->{agent} = $agent;
}

sub cookie {
	my $self = shift;
	unless (ref $self) {
		croak "Should be call with an object!";
	}
	my $cookie = shift;
	$http->{cookie} = $cookie;
}

sub content {
	my $self = shift;
	unless (ref $self) {
		croak "Should be call with an object!";
	}
	my $content = shift;
	$http->{content} = $content;
}

# return a hash reference
sub custom_content {
	my $self = shift;
	unless (ref $self) {
		croak "Should be call with an object!";
	}
	$custom_contents;
}

# generate a full feature http header
sub gen_http {
	my $self = shift;
	unless (ref $self) {
		croak "Should be call with an object!";
	}

	my $http_header = '';

	# first, parse the url 
	if (!defined $http->{url}) {
		croak "url not defined!";
	}
	my @tmp = split(/\//, $http->{url}, 4);
	my $target = $tmp[3];
	my $host = $tmp[2];

	if (!defined $http->{method}) {
		croak "method not defined!";
	}
	$http_header .= "$http->{method} $target HTTP/1.1\r\n";
	$http_header .= "Host: $host\r\n";
	if (!defined $http->{agent}) {
		$http_header .= "User-Agent: Soying CPE/1.0\r\n";
	}
	else {
		$http_header .= "User-Agent: $http->{agent}\r\n";
	}

	# next, add custom contents
	for (keys %$custom_contents) {
		$http_header .= "$_: $custom_contents->{$_}\r\n";
	}

	# at last, add content length & content if exist.
	if (!defined $http->{content}) {
		$http_header .= "Content-Length: 0\r\n";
		$http_header .= "\r\n\r\n";
	}
	else {
		my $len = length($http->{content});
		$http_header .= "Content-Length: $len\r\n";
		$http_header .= "\r\n";
		$http_header .= $http->{content};

	}

	return $http_header;
}

1;
