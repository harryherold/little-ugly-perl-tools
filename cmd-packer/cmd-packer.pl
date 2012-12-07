#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

sub xtar($$)
{
  my $src = shift;
  my $dest = shift;
  unless(-e $src) {
    print "No file found\n";
  }
  unless( -e $dest && $dest eq "." ) {
    `mkdir $dest`;
  }
  if( $dest eq "." ) {
    `tar xvf $src`;
  } else {
  `tar xvf $src -C $dest`;
  }
}
sub ctar ($$)
{
  my $src = shift;
  my $dest = shift;
  `tar cvf $dest $src`;
}
sub xtargz($$)
{
  print "extract tar.gz\n";
}
sub ctargz($$)
{
  print "compress tar.gz\n";
}
my %archives = (
  "tar" => {
    "extract" => \&xtar,
    "compress" => \&ctar,
  },
  "tar.gz" => {
    "extract" => \&xtargz,
    "compress" => \&ctargz,
  },
);
$archives{"tar"}{"extract"}("hallo.tar",".");
