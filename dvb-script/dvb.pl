#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple;
use JSON::PP;

if (@ARGV > 0)
{
  my $agent = LWP::UserAgent->new();
  system("clear");
  print "DVB-WATCH on ".$ARGV[0]." cancel with strg+c\n";
  while(1){
    my $response = get 'http://widgets.vvo-online.de/abfahrtsmonitor/Abfahrten.do?ort=dresden&hst="'.$ARGV[0].'"';
    my $json = JSON::PP->new;
    my $data = $json->decode($response);

    foreach my $node (@$data) {
      my $time = ( length(@$node[2]) == 0 ) ? "0" : @$node[2];
      print "\r Linie : ".@$node[0]."  nach ".@$node[1]." in ".$time." min\n";
    }
    sleep(59);
    system("clear");
    print "DVB-WATCH on ".$ARGV[0]." cancel with strg+c\n";
  }
}
