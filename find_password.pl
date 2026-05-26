#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use JSON::PP;
use IO::Handle;

STDOUT->autoflush(1);
STDERR->autoflush(1);

my ($pwregex, $userregex, $vault, $help);

GetOptions(
    'pwregex=s'   => \$pwregex,
    'userregex=s' => \$userregex,
    'vault=s'     => \$vault,
    'help'        => \$help,
);

if (!$pwregex && !$userregex) {
    print STDERR "Error: at least one of --pwregex or --userregex must be provided.\n";
    $help = 1;
}

if ($help) {
    print STDERR "--pwregex   -- regular expression to match against the password (case-sensitive)\n";
    print STDERR "--userregex -- regular expression to match against the username (case-insensitive)\n";
    print STDERR "--vault     -- limit search to a specific 1Password vault\n";
    print STDERR "--help      -- this help\n";
    print STDERR "\nWARNING: A permissive regex like '.' or '.*' will match every entry and\n";
    print STDERR "effectively dump your entire vault. Use a specific pattern.\n";
    exit 1;
}

system('op account list > /dev/null 2>&1') == 0
    or die "Error: 'op' is not available or not authenticated. Run 'op signin' first.\n";

$pwregex   //= '.*';
$userregex //= '.*';

# Phase 1: get the list of item IDs
my @list_args = ('op', 'item', 'list', '--categories', 'Login', '--format=json');
push @list_args, ('--vault', $vault) if $vault;

print STDERR "Phase 1: Listing vault items...";

open(my $list_fh, '-|', @list_args) or die "Failed to run op item list: $!\n";
my $list_json = do { local $/; <$list_fh> };
close($list_fh) or die "op item list failed\n";

my $item_list = eval { decode_json($list_json) };
die "Failed to parse op item list output: $@\n" if $@;

my $total = scalar @$item_list;
printf STDERR " found %d items.\n", $total;

# Phase 2: fetch each item individually and check against the regexes
my $count = 0;
my @matches;

for my $entry (@$item_list) {
    $count++;
    printf STDERR "\rPhase 2: Fetching and checking passwords (%d/%d) -- %d match%s found",
        $count, $total, scalar @matches, scalar @matches == 1 ? '' : 'es';

    open(my $get_fh, '-|', 'op', 'item', 'get', $entry->{id}, '--reveal', '--format=json')
        or die "Failed to run op item get: $!\n";
    my $item_json = do { local $/; <$get_fh> };
    close($get_fh);

    my $item = eval { decode_json($item_json) };
    next if $@;

    my $title    = $item->{title} // '';
    my ($username, $password) = ('', '');

    for my $field (@{$item->{fields} // []}) {
        my $purpose = $field->{purpose} // '';
        $username = $field->{value} // '' if $purpose eq 'USERNAME';
        $password = $field->{value} // '' if $purpose eq 'PASSWORD';
    }

    next unless $password;

    push @matches, "$title -- $username"
        if $password =~ /$pwregex/ && $username =~ /$userregex/i;
}

print STDERR "\n";
print "$_\n" for @matches;
