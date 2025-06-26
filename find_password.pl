#!/usr/bin/perl -w

use strict;
use Getopt::Long;
$| = 1;

my $pwregex = '.*';
my $userregex = '.*';
my $help;
GetOptions (
    'pwregex=s' => \$pwregex,
    'userregex=s' => \$userregex,
    'help' => \$help,
    );

if ($help)
{
    print STDERR "--pwregex   -- regular expression pattern to try to match to the password\n";
    print STDERR "--userregex -- regular expression pattern to try to match to the username\n";
    print STDERR "--help      -- this help.\n";
    exit;
}

my $command = 'op item list --categories Login --format=json | op item get - --reveal';

open PW, "$command |";
my $foundID = 0;
my $Title = '';
my $Username = '';
my $Password = '';
while (<PW>)
{
    chomp;
    my $line = $_;
    if ($line =~ /^ID\:\s/)
    {
	$foundID = 1;
    }
    elsif ($foundID and $line =~ /^Title\:\s*(.*?)$/)
    {
	$Title = $1;
    }
    elsif ($Title and $line =~ /^  username\:\s*(.*?)$/)
    {
	$Username = $1;
    }
    elsif ($Username and $line =~ /^  password\:\s*(.*?)$/)
    {
	$Password = $1;
    }
    if ( ($Password) and ($foundID) )
    {
	if ( ($Password =~ /$pwregex/) && ($Username =~ /$userregex/i) )
	{
	    print "$Title -- $Username -- $Password\n";
	}
	$foundID = 0;
	$Title = '';
	$Username = '';
	$Password = '';
    }
}
