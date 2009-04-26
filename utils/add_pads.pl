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

my @io = ();
foreach my $s (keys %sigs)
{
   if ($sigs{$s}{dir} =~ /inc|out/)
   {
      push @io, $s;
   }
}

my %c = (n => 0, s => 0, e => 0, w => 0);

my $top = 'top_top';

open my $f, '<', $ARGV[0];

if ($ARGV[1] =~ /v/)
{
   my $repeat = 0;
   while (<$f>)
   {
      $repeat = 1 if /\/\/ processed/;
      s/^module $top(?!_t)/module ${top}_t/;
      print;
   }
   
   exit if $repeat;
   
   print "// processed\n";
   
   print "module $top (" . join(', ', @io) . " );\n";
   
   foreach my $s (keys %sigs)
   {
      if ($sigs{$s}{dir} eq 'inc')
      {
         print 'input '
      }
      elsif ($sigs{$s}{dir} eq 'out')
      {
         print 'output ';
      }
      if ($sigs{$s}{n} > 1)
      {
         print '['. ($sigs{$s}{n} - 1) . ':0] ';
      }
      if ($sigs{$s}{dir} =~ /inc|out/)
      {
         print "$s;\n";
      }
   }
   
   print 'wire n';
   my @a = ();
   foreach my $s (keys %sigs)
   {
      if ($sigs{$s}{dir} =~ /inc|out/ and $sigs{$s}{n} == 1)
      {
         push @a, "n$s";
      }
   }
   print join(', n', @a), ";\n";
   
   foreach my $s (keys %sigs)
   {
      if ($sigs{$s}{n} > 1)
      {
         print 'wire [' . ($sigs{$s}{n} - 1) . ":0] n$s;\n";
      }
   }
   
   print "${top}_t IO ( ";
   print join(', ', map(".$_(n$_)", @io)) . " );\n";

   my $n = 0;
   foreach my $s (keys %sigs)
   {
      foreach my $i (0 .. $sigs{$s}{n} - 1)
      {
         print 'PAD' . uc($sigs{$s}{dir}) . " U$n (";
         $n++;
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
   print "endmodule\n\n";
}
elsif ($ARGV[1] =~ /io/)
{
   print <<TEXT;
Version: 2

Orient: R0
Pad: C0 NW PADFC
Orient: R270
Pad: C1 NE PADFC
Orient: R180
Pad: C2 SE PADFC
Orient: R90
Pad: C3 SW PADFC
TEXT
   
   my $n = 0;
   foreach my $s (keys %sigs)
   {
      foreach my $i (0 .. $sigs{$s}{n} - 1)
      {
         print "Pad: U$n " . uc($sigs{$s}{s}) . "\n";
         $n++;
         $c{$sigs{$s}{s}}++;
      }
   }
   
   foreach my $s (keys %c)
   {
      while ($c{$s} < 10)
      {
         $c{$s}++;
         print "Pad: U$n " . uc($s) . " PADNC\n";
         $n++;
      }
   }
}

