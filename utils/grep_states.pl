#!/usr/bin/perl
use strict;
use warnings;

open my $fh, '<', $ARGV[0];

my %states = ();

foreach (<$fh>)
{
	if (/next_state <= (.*?);/)
	{
		$states{$1} = undef;
	}
}

print join(', ', keys %states), "\n";
