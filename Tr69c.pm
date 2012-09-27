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
use LWP;
use LWP::UserAgent;

# store the global objects
my $_OBJS = {};
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Constructor new
# 	params: xml => xxx.xml url => url
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub new {
	my $class = shift;
	my $self = {@_};
	bless($self, $class);
	my $file = $self->{xml};
	if (not defined $file) {
		croak "xml => file.xml\n";
	}

	my $url = $self->{url};
	if (not defined $file) {
		croak "url => url\n";
	}

	my $inform = XMLin(
		$file, 
		KeepRoot => 1, 
		KeyAttr => 1, 
		ForceArray => 1, 
		NormaliseSpace => 1
	);

	my $xml = XMLout($inform, KeyAttr => 1, KeepRoot => 1, NoSort => 1);
	$_OBJS->{inform} = $xml;
	$_OBJS->{url} = $url;

	# create http agent
	my $ua = LWP::UserAgent->new;
	$ua->agent("TR69_CPE_04_00");
	$_OBJS->{agent} = $ua;

	# Create a request
	my $req = HTTP::Request->new(POST => $url);
	$req->content_type('text/xml');
	$_OBJS->{request} = $req;

	return $self;
}

# send inform messages
sub inform {
	my $self = shift;
	unless (ref $self) {
		croak "Should call inform() with an object!";
	}

	my $xml = $_OBJS->{inform};
	my $ua = $_OBJS->{agent};
	my $req = $_OBJS->{request};
	$req->content($xml);
	print $req->as_string();

	#print Dumper($req), "\n";
	# Pass request to the user agent and get a response back
	my $res = $ua->request($req);
	#print $res->as_string();
	# Check the outcome of the response
	if ($res->is_success) {
		my $headers = $res->headers();
		print $headers->{'set-cookie'}, "\n";
		print $res->content;
	}
	else {
		print $res->status_line, "\n";
	}

	return $self;
}


1;
