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
  unless(-e $dest) {
    `mkdir $dest`;
  }
}
sub ctar ()
{
  print "Packen tar\n";
}

my %archives = (
  "tar" => {
    "extract" => \&xtar,
    "compress" => \&ctar,
  },
);

$archives{"tar"}{"extract"}("/home/harry/slices.pl","HAHA");


# Whats the context directory
