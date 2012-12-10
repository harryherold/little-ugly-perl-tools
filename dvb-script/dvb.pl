#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple;
use JSON::PP;
use YAML::Tiny;
use Data::Dumper;
use Data::HexDump;

sub selectStation(@)
{
    my @stations = shift;
    my $i = 0;
    for ( ; $i < $#{$stations[0]} ; $i++) {
      print "[".$i."] : ".$stations[0][$i][0]."\n";
    }
    print "Select the right station with number from 0 to ".--$i."\n~>";
    my $choice = <STDIN>;
    return $stations[0][$choice][0];
}
sub getFullStationName($)
{
  my $hst = shift;
  my $response = get 'http://widgets.vvo-online.de/abfahrtsmonitor/Haltestelle.do?ort=dresden&hst="'.$hst.'"';
  my $json = JSON::PP->new;
  my @data = $json->decode($response);

  if($#{$data[0][1]}+1 > 1) {
    return selectStation($data[0][1])."\n";
  } elsif ($#{$data[0][1]}+1 == 1) {
    return $data[0][1][0][0];
  } else {
    print "Station not found !!";
    exit 0;
  }
}
sub saveStation($)
{
    my $pattern = shift;
    my $dh;
    my $yaml;
    opendir($dh,$ENV{HOME});
    my @array = grep {/dvb.conf/} readdir($dh);
    closedir($dh);
    if ( scalar(@array) == 0 ) {
      $yaml = YAML::Tiny->new;
      $yaml->[0] = [ $pattern ];
    } else {
      $yaml = YAML::Tiny->read( $ENV{HOME}.'/dvb.conf' );
      my $wert = 0;
      for ( ; $wert < ($#{$yaml->[0]} + 1); $wert++) {
        if( $yaml->[0][$wert] eq  $pattern ) {
          return;
        }
      }
      $yaml->[0][++$#{$yaml->[0]}] = $pattern;
    }
    $yaml->write( $ENV{HOME}.'/dvb.conf' );
}
sub readStationFile
{
  my $dh;
  opendir($dh,$ENV{HOME});
  my @array = grep {/dvb.conf/} readdir($dh);
  closedir($dh);
  if ( scalar(@array) == 0 ) {
    exit;
  } else {
    my $yaml = YAML::Tiny->read( $ENV{HOME}.'/dvb.conf' );
    my $wert = 0;
    for ( ; $wert < ($#{$yaml->[0]} + 1); $wert++) {
      print "[".$wert."] : ".$yaml->[0][$wert]."\n";
    }
    print "Select the right station with number from 0 to ".--$wert."\n~>";
    my $choice = <STDIN>;
    return $yaml->[0][$choice];
  }
}
sub printStationTimes($)
{
  my $station = shift;
  system("clear");
  print "DVB-WATCH on ".$station." cancel with strg+c\n";
  while(1){
    my $response = get 'http://widgets.vvo-online.de/abfahrtsmonitor/Abfahrten.do?ort=dresden&hst="'.$station.'"';
    my $json = JSON::PP->new;
    my $data = $json->decode($response);

    foreach my $node (@$data) {
      my $time = ( length(@$node[2]) == 0 ) ? "0" : @$node[2];
      print "\r Linie : ".@$node[0]."  nach ".@$node[1]." in ".$time." min\n";
    }
    sleep(59);
    system("clear");
    print "DVB-WATCH on ".$station." cancel with strg+c\n";
  }

}
my $stationn;
if (@ARGV > 0)
{
  $stationn = getFullStationName($ARGV[0]);
  saveStation($stationn);
}
else
{
  $stationn = readStationFile;
}
printStationTimes $stationn;
