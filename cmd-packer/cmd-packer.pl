#!/usr/bin/perl
#support:
# tar, tar.gz, tar.bz2, gz, bz2 ,zip, rar,
use strict;
use warnings;
use Data::Dumper;

sub xtar($$)
{
  my $src = shift;
  my $dest = shift;
  my @cmd =("tar","xvf",);
  unless(-e $src) {
    print "No file found\n";
    exit 0;
  }
  push(@cmd, $src);
  unless( -d $dest ) {
    `mkdir $dest`;
  }
  if( $dest eq "." ) {
    system(@cmd) == 0
      or die "cmd  @cmd failed: $?";
  } else {
    push(@cmd, "-C".$dest);
    system(@cmd) == 0
      or die "cmd  @cmd failed: $?";
  }
}
sub ctar ($$)
{
  my @cmd = ("tar","cvf",$_[1],$_[0]);
  system(@cmd) == 0
    or die "cmd  @cmd failed: $?";
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
$archives{"tar"}{"extract"}("hallo.tar","bier");
