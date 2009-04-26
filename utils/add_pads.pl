#!/usr/bin/perl
use warnings;
use strict;

my %sigs = (
   clk => {dir => 'inc', n => 1, s => 'w'},
   nrst => {dir => 'inc', n => 1, s => 'w'},
   rx_data => {dir => 'inc', n => 8, s => 'n'},
   rx_data_k => {dir => 'inc', n => 1, s => 'n'},
   rx_elec_idle => {dir => 'inc', n => 1, s => 'e'},
   phy_status => {dir => 'inc', n => 1, s => 'e'},
   rx_valid => {dir => 'inc', n => 1, s => 'e'},
   rx_status => {dir => 'inc', n => 3, s => 'e'},
   tx_data => {dir => 'out', n => 8, s => 's'},
   tx_data_k => {dir => 'out', n => 1, s => 's'},
   tx_detect_rx => {dir => 'out', n => 1, s => 'w'},
   tx_elec_idle => {dir => 'out', n => 1, s => 'w'},
   tx_comp => {dir => 'out', n => 1, s => 'w'},
   rx_pol => {dir => 'out', n => 1, s => 'w'},
   power_down => {dir => 'out', n => 2, s => 'w'},
   vdd => {dir => 'vdd', n => 1, s => 'e'},
   gnd => {dir => 'gnd', n => 1, s => 'e'}
);

my %c = (n => 0, s => 0, e => 0, w => 0);

open my $f, '<', $ARGV[0];
open my $v, '>', "$ARGV[0]_n";
open my $e, '>', 'e.io';

while (<$f>)
{
   s/^module top_top/module top_top_t/;
   #print;
}

print 'module top_top (' . join(', ', keys %sigs) . " );\n";

   print 'wire n';
   my @a = ();
   foreach my $sig (keys %sigs)
   {
      if ($sigs{$sig}{dir} =~ /inc|out/ and $sigs{$sig}{n} == 1)
      {
         push @a, "n$sig";
      }
   }
   print join(', n', @a), ";\n";
   
   foreach my $sig (keys %sigs)
   {
      if ($sigs{$sig}{n} > 1)
      {
         print 'wire [' . ($sigs{$sig}{n} - 1) . ":0] n$sig;\n";
      }
   }
   
   my $n = 0;
   foreach my $s (keys %sigs)
   {
      foreach my $i (0 .. $sigs{$s}{n} - 1)
      {
         print 'PAD' . uc($sigs{$s}{dir}) . " U$n (";
         $n++;
         $c{$sigs{$s}}++;
         if ($sigs{$s}{dir} =~ /inc|out/)
         {
            print " .DO(n$s";
            if ($sigs{$s}{n} > 1)
            {
               print "[$i]";
            }
            print "), .YPAD($s";
            if ($sigs{$s}{n} > 1)
            {
               print "[$i]";
            }
            print ")";
         }
         print " );\n";
      }
   }
   

