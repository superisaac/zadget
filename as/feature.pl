#!/usr/bin/env perl

use strict;
my @all = qw/plot media doodle/;

my %opt_dict = ();

for my $k(@all) {
    $opt_dict{$k} = 0;
}

for my $opt(@ARGV) {
    my $v = 1;
    if($opt =~ /^\-/){
        $v = 0;
        $opt = "$'";
    }

    if($opt eq 'all') {
        for my $k(@all) {
            $opt_dict{$k} = $v;
        }
    } else {
        $opt_dict{$opt} = $v;
    }
}

my $output = '';
for my $k(@all) {
    my $use = $opt_dict{$k}?'true':'false';
    $output .= "-define=CONFIG::use_$k,$use ";
}

print "$output\n";
