#!/usr/bin/perl
# cmd-packer [-c ]/[-x]/[-t] dest src
#supports:
# tar
# tar.gz
# tar.bz2
# tar.xv
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

sub showTar($)
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

sub czip($$)
{
  my $src = shift;
  my $dest = shift;
  open(ZIP,"| zip -r $dest $src") || die "Failed: $!\n";
  close(ZIP);
}

sub xzip($$)
{
  my $src = shift;
  my $dest = shift;
  open(ZIP,"| unzip -o $src -d $dest") || die "Failed: $!\n";
  close(ZIP);
}

sub showZip($)
{
  my $zip = $_[1];
  unless(-e $zip) {
      print "No archive found\n";
      exit 0;
  }
  open(ZIP,"| unzip -l $zip") || die "Failed: $!\n";
  close(ZIP);
}

sub crar($$)
{
  my $src = shift;
  my $dest = shift;
  open(RAR,"| rar a $dest $src") || die "Failed: $!\n";
  close(RAR);
}

sub xrar($$)
{
  my $src = shift;
  my $dest = shift;
  unless( -d $dest ) {
    `mkdir $dest`;
  }
  open(RAR,"| unrar x -o+ $src $dest") || die "Failed: $!\n";
  close(RAR);
}

sub showRar($)
{
  my $rar = $_[1];
  unless(-e $rar) {
      print "No archive found\n";
      exit 0;
  }
  open(RAR,"| unrar l $rar") || die "Failed: $!\n";
  close(RAR);
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
    "-t" => \&showTar,
  },
  "zip" => {
    "-c" => \&czip,
    "-x" => \&xzip,
    "-t" => \&showZip,
  },
  "rar" => {
    "-c" => \&crar,
    "-x" => \&xrar,
    "-t" => \&showRar,
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
