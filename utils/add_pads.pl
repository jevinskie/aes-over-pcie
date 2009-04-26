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
my $clk_per = 10;

if ($ARGV[0] eq 'v')
{
   open my $f, '<', $ARGV[1];
   
   my $repeat = 0;
   my $changed = 0;
   while (<$f>)
   {
      $repeat = 1 if /\/\/ processed/;
      if (m/^module ${top}_t/)
      {
         $changed = 1;
      }
      if (m/^module $top(?!_t)/ and not $changed)
      {
         s/module $top/module ${top}_t/;
         $changed = 1;
      }
      print;
   }
   
   close $f;
   
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
elsif ($ARGV[0] eq 'io')
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
elsif ($ARGV[0] eq 'pt')
{
   print "create_clock -period $clk_per -waveform { 0 " . ($clk_per/2) . " } [get_ports {clk}]\n";
   foreach my $s (keys %sigs)
   {
      if ($sigs{$s}{dir} eq 'inc')
      {
         if ($sigs{$s}{n} == 1)
         {
            print "set_driving_cell -lib_cell INVX8 [get_ports {$s}]\n"; 
         }
         else
         {
            foreach my $i (0 .. $sigs{$s}{n} - 1)
            {
               print "set_driving_cell -lib_cell INVX8 [get_ports {$s\[$i\]}]\n"; 
            }
         }
      }
      
      next if $s eq 'clk';
      
      if ($sigs{$s}{dir} eq 'inc')
      {
         if ($sigs{$s}{n} == 1)
         {
            print "set_input_delay -clock clk 1.0000 [get_ports {$s}]\n";
         }
         else
         {
            foreach my $i (0 .. $sigs{$s}{n} - 1)
            {
               print "set_input_delay -clock clk 1.0000 [get_ports {$s\[$i\]}]\n";
            }
         }
      }
      elsif ($sigs{$s}{dir} eq 'out')
      {
         if ($sigs{$s}{n} == 1)
         {
            print "set_output_delay -clock clk 1.0000 [get_ports {$s}]\n";
         }
         else
         {
            foreach my $i (0 .. $sigs{$s}{n} - 1)
            {
               print "set_output_delay -clock clk 1.0000 [get_ports {$s\[$i\]}]\n";
            }
         }
      }
   }
}

