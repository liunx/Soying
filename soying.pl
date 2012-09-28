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

# use the custom objects
use Tr69c;

# define the constant scala
use constant SCHEDULE_TIME => (3 * 1000 * 1000); # 3s
use constant BUFLEN => (1024 * 1024);

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Subroutines
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
my $delta_timer = 0;
sub shedule_main {
	my $timer = shift;

	my $obj = Tr69c->new(
		url => 'http://10.129.228.68:8080/openacs/acs'
	);

	$obj->set_inform(inform => 'xml/inform.xml');
	my $output = $obj->get_inform();
	print $output;
}

sub messages_process {
	my $message = shift;
	print "$message\n";

}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# The main entry
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# the server sock
my $lsn = IO::Socket::INET->new(Listen => 1, LocalPort => 9090) 
	or die $!;
my $sel = IO::Select->new($lsn);

# the client sock
my $cli = IO::Socket::INET->new(
	PeerAddr	=> '10.129.228.66', 
	PeerPort	=> 8080,
	Proto		=> 'tcp'		
) or die $!;
fcntl($cli, F_SETFL, O_NONBLOCK);
$sel->add($cli);

# ---------------------------------------------------------------------------
# objects init
# ---------------------------------------------------------------------------

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
	shedule_main($global_timer);

	usleep($sleep_time);
	$global_timer += 1;
}
