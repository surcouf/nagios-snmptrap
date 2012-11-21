#!/usr/bin/perl
# nagios: -epn
#
# Written by Raphaël 'SurcouF' Bordet <surcouf@debianfr.net>
# Last Modified: 28/04/2010
#
# This script will write a command to the Nagios command
# file to cause Nagios to process a passive service check
# result from a SNMP TRAP issued by another Nagios.

use strict;

use Nagios::Cmd;
use Nagios::Plugin::Functions	qw/ %ERRORS /;


my @arguments		= @ARGV;

my $nagios_command	= Nagios::Cmd->new(
				"/var/lib/nagios3/rw/nagios.cmd"
			);

my %results 		= map { my ($variable,$value) = split(':',$_) } @arguments;

my $return_code 	= $ERRORS{ uc($results{'nSvcStateID'}) };

my $output		= $results{'nSvcOutput'};

if ( defined( $results{'nSvcPerfData'} ) ) {
	$output		.="|". $results{'nSvcPerfData'};
}

$nagios_command->service_check(
		$results{'nHostname'},
		$results{'nSvcDesc'},
		$return_code,
		$output,
	);

