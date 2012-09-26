#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: soying.pl
#
#        USAGE: ./soying.pl  
#
#  DESCRIPTION: a tr069 emulator for both server & client.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Lei Liu <liunx163@163.com> 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 2012年09月24日 12时03分25秒
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use Data::Dumper;
use IO::Select;
use IO::Socket;
use Time::HiRes qw(usleep);
use Fcntl;
use POSIX qw(:errno_h);
use XML::Simple qw(:strict);
use LWP;
use LWP::UserAgent;

# define the constant scala
use constant SCHEDULE_TIME => (3 * 1000 * 1000); # 3s
use constant BUFLEN => (1024 * 1024);

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Subroutines
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
my $inform_period = SCHEDULE_TIME;
sub send_inform {
	my $inform = XMLin(
		'xml/inform.xml', 
		KeepRoot => 1, 
		KeyAttr => 1, 
		ForceArray => 1, 
		NormaliseSpace => 1
	);

	my $xml = XMLout($inform, KeyAttr => 1, KeepRoot => 1, NoSort => 1);
	#print $xml;

	my $ua = LWP::UserAgent->new;
	$ua->agent("TR69_CPE_04_00");

	# Create a request
	my $req = HTTP::Request->new(POST => 'http://10.129.228.68:8080/openacs/acs');
	$req->content_type('text/xml');
	$req->content($xml);

	# Pass request to the user agent and get a response back
	my $res = $ua->request($req);

	# Check the outcome of the response
	if ($res->is_success) {
		my $headers = $res->headers();
		print $headers->{'set-cookie'}, "\n";
		print $res->content;
	}
	else {
		print $res->status_line, "\n";
	}

}

sub shedule_main {
	my $timer = shift;
	send_inform();

}

sub messages_process {
	my $message = shift;

}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# The main entry
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
my $lsn = IO::Socket::INET->new(Listen => 1, LocalPort => 9090) 
	or die $!;
my $sel = IO::Select->new($lsn);

my $sleep_time = 100; # us
my $global_timer = 0;

while(1) {
	# -----------------------------------------------------------------------
	# process the incoming events
	# -----------------------------------------------------------------------
	my @ready = $sel->can_read(0);
	foreach my $fh (@ready) {
		if($fh == $lsn) {
			# Create a new socket
			my $new = $lsn->accept;
			# make it non-blocking
			fcntl($new, F_SETFL, O_NONBLOCK);
			$sel->add($new);
		}
		else {
			# Process socket
			# Maybe we have finished with the socket
			my $total_data = undef;
			# get all of data
			while (my $rv = sysread($fh, my $data, BUFLEN)) {
				$total_data .= $data;
			}

			# 0 means no data but remote pair broken.
			if (!defined($total_data)) {
				print "Remote pair broken...\n";
				$sel->remove($fh);
				$fh->close;
				next;
			}

			# messages processor unit
			# print $total_data;
			messages_process($total_data);

		}
	}

	# -----------------------------------------------------------------------
	# do the normal affair
	# -----------------------------------------------------------------------
	if ($global_timer > SCHEDULE_TIME) {
		$global_timer = 0;
		shedule_main($global_timer);
	}

	usleep($sleep_time);
	$global_timer += $sleep_time;
}
