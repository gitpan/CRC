package CRC;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter AutoLoader DynaLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
	
);
$VERSION = '0.02';

# Preloaded methods go here.

sub _tabinit {
  my ($width,$poly_in,$ref) = @_;
  my @crctab = ();
  my $poly = $poly_in;

  if ($ref) {
    my $p = $poly;
    $poly=0;
    for(my $i=1; $i < ($width+1); $i++) {
      $poly |= 1 << ($width-$i) if ($p & 1);
      $p=$p>>1;
    }
  }

  for (my $i=0; $i<256; $i++) {
    my $r = $i<<($width-8);
    $r = $i if $ref;
    for (my $j=0; $j<8; $j++) {
      if ($ref) {
	$r = ($r>>1)^($r&1&&$poly)
      } else {
	if ($r&(1<<($width-1))) {
	  $r = ($r<<1)^$poly
	} else {
	  $r = ($r<<1)
	}
      }
    }
    push @crctab, $r&2**$width-1;
  }
  @crctab;
}

sub crc {
  my ($buffer, $width, $init, $xorout, $poly, $refin, $refout) = @_;
  my @tab = _tabinit($width,$poly,$refin);
  my $crc = $init;
  my $pos = -length $buffer;
  while ($pos) {
    if ($refout) {
      $crc = ($crc>>8)^$tab[($crc^ord(substr($buffer, $pos++, 1)))&0xff]
    } else {
      $crc = (($crc<<8)&0xffff)^$tab[(($crc>>($width-8))^ord(substr $buffer,$pos++,1))&0xff]
    }
  }
  $crc ^ $xorout;
}


# CRC-CCITT standard
# poly: 1021, width: 16, init: ffff, refin: no, refout: no, xorout: no

sub crcccitt {
  crc($_[0],16,0xffff,0,0x1021,0,0);
}


# CRC16
# poly: 8005, width: 16, init: 0000, revin: yes, revout: yes, xorout: no

sub crc16 {
  crc($_[0],16,0,0,0x8005,1,1);
}


# CRC32
# poly: 04C11DB7, width: 32, init: FFFFFFFF, revin: yes, revout: yes,
# xorout: FFFFFFFF
# equivalent to: cksum -o3

sub crc32 {
  crc($_[0],32,0xffffffff,0xffffffff,0x04C11DB7,1,1);
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

CRC - Generic CRC functions

=head1 SYNOPSIS

  use CRC;
  $crc = crc32("123456789");
  $crc = crc16("123456789");
  $crc = crcccitt("123456789");

  $crc = crc($input,$width,$init,$xorout,$poly,$refin,$refout);

=head1 DESCRIPTION

The B<CRC> module calculates CRC sums of all sorts.
It contains wrapper functions with the correct parameters for CRC-CCITT,
CRC-16 and CRC-32.

=head1 AUTHOR

Oliver Maul, oli@42.nu

=head1 COPYRIGHT

CRC algorithm code taken from "A PAINLESS GUIDE TO CRC ERROR DETECTION
 ALGORITHMS".

The author of this package disclaims all copyrights and 
releases it into the public domain.

=cut
