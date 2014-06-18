#!/usr/bin/perl -w
use strict;
use Data::Dumper;

sub random_pixel{
  my $luminosity = shift;
  return [
    $luminosity - int(rand($luminosity/2)), 
    $luminosity - int(rand($luminosity/2)), 
    $luminosity - int(rand($luminosity/2))
  ];
}

sub frame{
  my $pixels = shift;
  return join('|',
    map({
      join(',',@$_)
    } @$pixels)
  )."\n";
}

sub run_left {
  foreach my $pos (0..63){
    my @pixels = ([0,0,0]) x 64;
    $pixels[$pos] = random_pixel(150);
    print frame(\@pixels);
  }
}

sub run_right {
  foreach my $pos (0..63){
    my @pixels = ([0,0,0]) x 64;
    $pixels[63-$pos] = random_pixel(150);
    print frame(\@pixels);
  }
}

sub clear {
  my $base = shift;
  $base ||= 0;
  my @pixels = ([$base,$base,$base]) x 64;
  print frame(\@pixels);
}

sub flash{
  my $luminosity = shift;
  foreach my $step (0..12){
    clear(int($luminosity*$step/12));
  }
  clear();
}

while(1){
  run_left();
  flash(70);
  run_right();
  flash(70);
}
