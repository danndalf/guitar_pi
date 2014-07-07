#!/usr/bin/perl -w
use strict;

my $offsets = [0,22,44];

my $pattern = [10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200,210,220,230,240,240,230,220,210,200,190,180,170,160,150,140,130,120,110,100,90,80,70,60,50,40,30,20,10];
#print "Pattern length: ".scalar(@$pattern)."\n";

my $colormap;
foreach (0..63){ push @$colormap, [0,0,0]; }

foreach my $i (0..scalar(@$pattern)-1){
	foreach my $j (0..2){
		my $p = $i + $offsets->[$j];
		$p = $p - scalar(@$colormap) if $p > scalar(@$colormap)-1;
		$colormap->[$p]->[$j] = int(($pattern->[$i] * 100) / 240);
	}
}

print(join(', ', map{"\n  [ ".join(', ', @$_).' ]'} @$colormap)."\n");

#print "Colormap length: ".scalar(@$colormap)."\n";
