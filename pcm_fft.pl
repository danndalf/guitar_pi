#!/usr/bin/perl -w
use strict;

$| = 1;

use Audio::Analyzer;
use Data::Dumper;
use OPC; 

### Connect to the FadeCandy
my $num_leds = 64;
my $client = new OPC('localhost:7890');
$client->can_connect();

### Connect the FFT analyzer
my $analyzer = Audio::Analyzer->new(
	file => \*STDIN,
  channels => 1,
	sample_rate => 8000,
	dft_size => 128
);
my $counter = 0;
my $pixelbuffer;

my $colors = [

	#Yellow all the way across (the bass)
	[100,100,0], [100,100,0], [100,100,0], [100,100,0], [100,100,0], [100,100,0], [100,100,0], [100,100,0],
	#Yellow -> Orange
	[100,100,0], [100,100,0], [100,100,0], [100,100,0], [100,90,0], [100,80,0], [100,70,0], [100,60,0],
	#Orange -> Red
	[100,50,0], [100,50,0], [100,50,0], [100,50,0], [100,40,0], [100,30,0], [100,20,0], [100,10,0],
	#Red -> Purple
	[100,30,0], [100,10,0], [100,0,0], [100,0,0], [100,0,0], [100,0,20], [100,0,40], [100,0,60],
	#Purple -> Blue
	[100,0,100], [100,0,100], [100,0,100], [100,0,100], [80,0,100], [60,0,100], [40,0,100], [20,0,100],
	#Blue -> Green
	[0,0,100], [0,0,100], [0,10,100], [0,20,100], [0,30,100], [0,40,100], [0,50,100], [0,80,100],
	#Green -> Yellow
	[0,100,80], [10,100,60], [20,100,40], [30,100,20], [40,100,0], [50,100,0], [60,100,0], [70,100,0],
	#Yellow (treble end)
	[80,100,0], [90,100,0], [100,100,0], [100,100,0], [100,100,0], [100,100,0], [100,100,0], [100,100,0],

];


my $previous_aggregate = 0;
### Grab FFT data, plot it on the LEDs.
while(defined(my $chunk = $analyzer->next())){
	$pixelbuffer = [];

	if($counter % 20 == 1){
		my $index = 0;
		my $freqs = $analyzer->freqs();
		my $amplitudes = $chunk->fft();
		foreach my $point (@{$$amplitudes[0]}){
			$point = $point * 44250;

			$point = 255 if $point > 255;
			$point = $point;
			
			my $pixel = [$point, $point, $point];
			push @$pixelbuffer, $pixel;
			$index++;
		}

		# Scale the sonograph to just the subset we're interested in
		my $scaled = [];
		foreach my $i (0..$num_leds - 1){
			
			# Move pixels 0..12 to 0..64 (this looks blocky if we don't smooth it).
			my $target_id = int(($i / 5)+0.4);
			my $pixel = $pixelbuffer->[$target_id];

			push @$scaled, $pixel;
		}

		# Add the color mask and blend
		foreach my $i (0..$num_leds-1){
			$scaled->[$i]->[0] = $scaled->[$i]->[0] * (1.0*$colors->[$i]->[0] / 100.0);
			$scaled->[$i]->[1] = $scaled->[$i]->[1] * (1.0*$colors->[$i]->[1] / 100.0);
			$scaled->[$i]->[2] = $scaled->[$i]->[2] * (1.0*$colors->[$i]->[2] / 100.0);

			# Deviation: are we a close neighbor to the next bucket? If so, smooth it out.
#			my $deviation = int(($i % 5) / 3);
#			if ($deviation){
#				$scaled->[0] = (($scaled->[0] + $scaled->[$i+1]->[0])/2);
#				$scaled->[1] = (($scaled->[1] + $scaled->[$i+1]->[1])/2);
#				$scaled->[2] = (($scaled->[2] + $scaled->[$i+1]->[2])/2);
#			}
		}

		# If the waveform is peaking, clip it. Flashes = OW.
		my $aggregate = 0;
		foreach my $pixel (@$scaled){
			foreach my $subpixel (0..2){
				$aggregate += $pixel->[$subpixel];
			}
		}
		next if $aggregate > $num_leds * 3 * 75;

		$client->put_pixels(0,$scaled);
	}
	$counter++;
}
