#!/usr/bin/perl

use strict;
use warnings;

use List::MoreUtils qw{ natatime };

use AnyEvent;
use AnyEvent::Util 'fork_call';
use DDP;
my $cv = AE::cv;

$AnyEvent::Util::MAX_FORKS = 1000;

my @hosts;
while (<>) {
 chomp;
 push(@hosts, $_);
}


sub fork_ping {
    my $interval        = 0.2;
    my $number_of_pings = 1;
    my $timeout         = 1;

    my %ret_val;

    foreach my $host (@hosts) {
        $cv->begin;
        fork_call {
            my $stdout = `ping -c 1 -i 2 -W 2 $host 2>&1`;
            return $stdout;
        } sub {
            $ret_val{$host} = shift;
            $cv->end;
        };
    }

    return \%ret_val;
}


my $ping_data = fork_ping();
$cv->recv;
p $ping_data;
