#!/usr/bin/perl -w
use strict;

$| = 1;

use Audio::Analyzer;
use Device::SerialPort;

my $port = new Device::SerialPort("/dev/ttyACM0") || die "Can't open serial port"; 
$port->user_msg('ON'); 
$port->baudrate(115200); 
$port->parity("none"); 
$port->databits(8); 
$port->stopbits(1); 
#$port->handshake("xoff"); 
$port->write_settings;
$port->lookclear;

### Connect the FFT analyzer
my $analyzer = Audio::Analyzer->new(
	file => \*STDIN,
  channels => 1,
	sample_rate => 8000,
	dft_size => 128
);
my $counter = 0;
my $pixelbuffer;

my @charmap = (' ', '.', '_', '-', '~', '=', 'o', 'x', 'O', 'X');

my $previous_aggregate = 0;

my $buffer_history= [[],[]];
foreach my $i (0..1){
	foreach my $j (0..63){
		push $buffer_history->[$i], 0;
	}
}

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
			
			push @$pixelbuffer, $point;
			$index++;
		}

		# Format the coefficients
		my @coeffs = ();
		my $aggregate = 0;
		my $clipping = 0;
		foreach my $i (0..63){
			my $value = int((
				(((2 * $pixelbuffer->[$i]) + $buffer_history->[0]->[$i] + $buffer_history->[1]->[$i])/4)
			* 9) / 255);
			$aggregate += $value;
			$clipping += (($pixelbuffer->[$i] * 9) / 255);
			push @coeffs, $value;
		}

		# Clip the waveform if it's peaking
		next if $clipping > 500;

		# Rotate the buffer history
		foreach my $i (0..63){
			$buffer_history->[0]->[$i] = $buffer_history->[1]->[$i];
			$buffer_history->[1]->[$i] = $pixelbuffer->[$i];
		}

		my $packet = join('', @coeffs).sprintf('%03d',$aggregate);
		$port->write("$packet\n");
		print("\n".$packet);
	}
	$counter++;
}
