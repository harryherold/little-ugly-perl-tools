#!/usr/bin/perl
# cmd-packer [-c ]/[-x]/[-t] dest src
#supports:
# tar
# tar.gz
# tar.bz2
# tar.xv
#next support:
# zip
# rar
use strict;
use warnings;
use Data::Dumper;
use Switch;
use File::stat;

sub xtar($$)
{
  my $src = shift;
  my $dest = shift;
  my $cmd = "tar xfv";

  if( defined $_[2] ) {
    $cmd .= $_[2];
  }
  $cmd .= " $src";
  unless( -d $dest ) {
    `mkdir $dest`;
  }
  exec $cmd.' -C '.$dest;
}

sub ctar ($$)
{
  my $cmd = "tar cfv";
  my $src = shift;
  my $dest = shift;

  if( defined $_[2] ) {
    $cmd .= $_[2];
  }
  $cmd .= " $dest $src";
  `$cmd`;
  my $tar = stat($dest);
  print "total size : ",$tar->size," bytes\n";
}

sub getTarOption(@)
{
    my @ext = shift;
    switch( $ext[2] ) {
        case "xz" { return "J"}
        case "gz" { return "z"}
        case "bz2" { return "j"}
        else {return ""}
    }
}

sub showContent($)
{
    my $tar = $_[1];
    my $cmd = "tar tvf";

    if( defined $_[2] ) {
      $cmd .= $_[2];
    }

    unless(-e $tar) {
      print "No archive found\n";
      exit 0;
    }
    exec $cmd.' '.$tar;
}
if( @ARGV < 2 ){
  print "Wrong argument count\n";
  print "---------------------\n";
  print "try this :\n";
  print "cmd-packer <action> <destination> <source>\n";
  print "action:\n";
  print "-c => compress\n";
  print "-x => extract\n";
  print "-t => show content of archives\n";
  print "supported archives: tar, tar.gz, tar.xv, tar.bz2\n";
  exit 0;
}
my $func = $ARGV[0];

my %archives = (
  "tar" => {
    "-x" => \&xtar,
    "-c" => \&ctar,
    "-t" => \&showContent,
  },
);

my $dest = $ARGV[1];

for( @ARGV[2..$#ARGV] ) {
  unless( -e ) {
    print "File $_ not found\n";
    exit 0;
  }
}

my $src = join(' ', @ARGV[2..$#ARGV]);

my @ext = ();

if( $func eq "-c" || $func eq "-t") {
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
  print "Wrong Option\n";
  exit 0;
}

if( exists $archives{$ext[1]} ) {
  if( scalar(@ext) == 3 && $ext[1] eq "tar" ) {
    $archives{$ext[1]}{$func}($src,$dest,getTarOption(@ext));
  } else {
    $archives{$ext[1]}{$func}($src,$dest);
  }
}
