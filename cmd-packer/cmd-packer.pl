#!/usr/bin/perl
# cmd-packer [-c ]/[-x] src dest
#supports:
# tar 
# tar.gz
# tar.bz2
#next support:
# gz 
# bz2
# zip
# rar
use strict;
use warnings;
use Data::Dumper;

sub xtar($$)
{
  my $src = shift;
  my $dest = shift;
  my @cmd =("tar",);
  if( defined $_[2] ) {
	push(@cmd,"xfv".$_[2]);
  } else {
	push(@cmd,"xfv");
  }
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
  my @cmd = ("tar",);
  my $src = shift;
  my $dest = shift;
  unless(-e $src || -d $src) {
    print "No file/directory found\n";
    exit 0;
  }
  if( defined $_[2] ) {
    push(@cmd,"cfv".$_[2]);
  } else {
    push(@cmd,"cfv");
  }
  push(@cmd, $dest);
  push(@cmd, $src);
  system(@cmd) == 0
    or die "cmd  @cmd failed: $?";
}

if( @ARGV != 3 ){
  print "Wrong argument count\n";
  exit 0;
}
my $func = $ARGV[0];

if( length($func) != 2 || ( $func ne "-c" && $func ne "-x" ) ) {
  print "Wrong Option choose between -c and -x\n";
  exit 0;
}
my %archives = (
  "tar" => {
    "-x" => \&xtar,
    "-c" => \&ctar,
  },
);
my $src = $ARGV[1];
my $dest = $ARGV[2];
my @ext;
if( $func eq "-c" ) {
  if ($dest =~ m/^.*\..*/) {
    @ext = split(/\./,$dest,3);
  } else {
    print "No extention found\n";
    exit 0;
  }
}
elsif( $func eq "-x" ) {
  if ($src =~ m/^.*\..*/) {
    @ext = split(/\./,$src,3);
  } else {
    print "No extention found\n";
    exit 0;
  }
} else {
  print "Wrong file type\n";
  exit 0;
}
if( exists $archives{$ext[1]} ) {
  if( scalar(@ext) == 3 && $ext[1] eq "tar" ) {
    $_ = ($ext[2] eq "gz" || $ext[2] eq "bz2")?
    ($ext[2] eq "gz") ? "z" : "j" :undef;
    $archives{$ext[1]}{$func}($src,$dest,$_);
  } else {
    $archives{$ext[1]}{$func}($src,$dest);
  }
}
