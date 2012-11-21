#!/usr/bin/perl -w
#
# SUBMIT_TRAP_RESULT
# Written by Raphaël 'SurcouF' Bordet <surcouf@debianfr.net>
# Last Modified: 28/04/2010
#
# This plugin will write a command to the Nagios command
# file to cause Nagios to process a passive service check
# result.
#
# Arguments:
#  $1 = host_name (Short name of host that the service is
#       associated with)
#  $2 = svc_description (Description of the service)
#  $3 = nagios_plugin->opts->returncode (Will be converted to an integer that 
#       determines the state of the service check, 0=OK, 
#       1=WARNING, 2=CRITICAL, 3=UNKNOWN).
#  $4 = plugin_output (A text string that should be used
#       as the plugin output for the service check)
# 
 
use strict;

use Data::Dumper;

use Nagios::Plugin;	# Import Nagios exit codes as constants
use Nagios::Cmd;

			
#
# Create Nagios::Plugin object instance.
#
my $nagios_plugin = Nagios::Plugin->new(
		shortname	=> 'submit_snmptrap_results',
 		usage		=> "Usage: %s [ -v|--verbose ] [-f|--configfile <configfile>] [-H|--hostname <host>]",
		version		=> '0.01',
		blurb		=> 'This command sent external commands to Nagios from SNMP traps translated by SNMPtt.',
		plugin		=> 'submit_snmptrap_results',
		extra		=> "\n Copyright (c) 2010 Raphael 'SurcouF' Bordet <surcouf\@debianfr.net>",
	);

#
# Nagios configuration file
# 
$nagios_plugin->add_arg(
		spec		=> 'configfile|f=s',
		help		=> qq(-f, --configfile=STRING\n    Configuration file of Nagios.),
		default		=> '/etc/nagios/nagios.cfg',
	);
#
# Nagios version
# 
$nagios_plugin->add_arg(
		spec		=> 'nagiosversion|V=i',
		help		=> qq(-V, --nagiosversion=INTEGER\n    Version of Nagios.),
		default		=> 3,
	);

#
# Hostname option definition
# 
$nagios_plugin->add_arg(
		spec		=> 'hostname|H=s',
		help		=> qq(-H, --hostname=STRING\n    Hostname where SNMP trap service is hosted.),
		required	=> 1,
	);

#
# Service description option definition
# 
$nagios_plugin->add_arg(
		spec		=> 'servicedesc|s=s',
		help		=> qq(-s, --servicedesc=STRING\n    Service description.),
		required	=> 1,
	);

#
# Service output option definition
# 
$nagios_plugin->add_arg(
		spec		=> 'output|o=s',
		help		=> qq(-o, --output=STRING\n    Service output.),
		required	=> 1,
	);

#
# Service return code option definition
# 
$nagios_plugin->add_arg(
		spec		=> 'returncode|c=s',
		help		=> qq(-c, --returncode=STRING\n    Service returncode.),
		required	=> 1,
	);

$nagios_plugin->getopts;

#my $nagios_config = Nagios::Config->new( 
#			Filename	=> $nagios_plugin->opts->configfile, 
#			Version 	=> $nagios_plugin->opts->nagiosversion,
#		 );
# create the command line to add to the command file
my $nagios_command = Nagios::Cmd->new( 
		'/var/lib/nagios3/rw/nagios.cmd',
#		$nagios_config->get('command_file'),
	);

# get the current date/time in seconds since UNIX epoch
# use CORE:: if you have Time::HiRes overriding time()
my $current_time = CORE::time();

# check host_name
my $hostname = uc( $nagios_plugin->opts->hostname );

my $returncode = UNKNOWN;
# nagios_plugin->opts->returncode conversion
if ( $nagios_plugin->opts->returncode =~ /NORMAL|INFORM|INFORMATIONAL|OK/ ) {
	$returncode = OK;
} elsif ( $nagios_plugin->opts->returncode =~ /WARN|WARNING/ ) {
	$returncode = WARNING;
} elsif ( $nagios_plugin->opts->returncode =~ /MAJOR|CRIT|CRITICAL/ ) {
	$returncode = CRITICAL;
}


print STDERR "[$current_time] PROCESS_SERVICE_CHECK_RESULT;"
				. $hostname .";"
				. $nagios_plugin->opts->servicedesc .";"
				. "$returncode;"
				. $nagios_plugin->opts->output ."\n";

# append the command to the end of the command file
$nagios_command->nagios_cmd( "[$current_time] PROCESS_SERVICE_CHECK_RESULT;"
				. $hostname .";"
				. $nagios_plugin->opts->servicedesc .";"
				. "$returncode;"
				. $nagios_plugin->opts->output
			);

