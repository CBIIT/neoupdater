#!/usr/bin/env perl
#-*-mode: cperl-*-
use Getopt::Long;
use JSON::XS;
use YAML;
use v5.10;
use strict;

my $start_id = 0;
my $node = $ENV{NODE};
GetOptions(
  "start=i" => \$start_id,
  "node:s" => \$node
);

my $SCHEMAS=$ENV{SCHEMADIR} or die "no schemadir";

$node or die "specify node label on command line or in  env \$NODE";
# get catalog of neo4j-type types from schema
my $types = get_property_types($node);
my ($g,@h,@sys,@h_t);

my $i = $start_id;
while (<>) {
  my @F=split/\!/;
  my $h=decode_json $F[1];
  my $sys = decode_json $F[2];
  if (!@h) { #first time
    #infer properties
    @h = keys %$h;
    @sys = keys %$sys;
    @h_t = map { $$types{$_} ? join(':',$_,$$types{$_}) : $_ } @h;
    push @h_t, map { "_$_" } @sys;
  }
  unless ($g) {
    say join("\t","i:id","id","l:label",@h_t);
    $g=1 }
  $h->{$_} =~ s/[\t|\n|\r]/ /g for @h; #annotation notes cleanup
  $h->{$_} =~ s/"/\\"/g for @h; #annotation notes cleanup
  say join("\t",$i++,$F[0], $node, @{$h}{@h}, @{$sys}{@sys});
}
open my $f, ">_start.txt" or die "_start.txt: $!";
print $f $i;

sub get_property_types {
  my $node = shift;
  my $schemafile = join('/',$SCHEMAS,"$node.yaml");
  my $defsfile = join('/',$SCHEMAS,"_definitions.yaml");
  my %cvt = (
      integer => 'int',
      number => 'float',
      string => 'string',
      boolean => 'boolean'
      );
  unless (-e $schemafile) {
    die "can't find schema yaml file $schemafile"
  }
  my $sch = read_yaml_file($schemafile);
  if (-e $defsfile) { # merge in the global property defs
    my $defs = read_yaml_file($defsfile) if -e $defsfile;
    for my $p (grep !/properties/, keys %$defs) {
      unless (defined $sch->{properties}{$p}) {
	$sch->{properties}{$p} = $defs->{$p};
      }
    }
    for my $P (grep /properties/, keys %$defs) {
      for my $p (keys %{$defs->{$P}}) {
	unless (defined $sch->{properties}{$p}) {
	  $sch->{properties}{$p} = $defs->{$P}{$p};
	}
      }
    }
  }

  my %types;
  my @props = keys %{$sch->{properties}};
  my $props = $sch->{properties};
  for my $p (@props) {
    next if ( !ref $props->{$p});
    my $t = $props->{$p}{type} || ($props->{$p}{enum} ? 'string' : undef) || 'string';
    if (!ref $t) {
      $types{$p} = $cvt{$t};
    }
    elsif (ref $t eq 'ARRAY') {
      $types{$p} = $cvt{$t->[0]};
    }
    else {
      $types{$p} = "string";
    }
  }
  return \%types;
}

sub read_yaml_file {
  my $yamlfile = shift;
  open my $yf, $yamlfile or die "$yamlfile $!";
  my $ys="";
  # clear comments from ends of lines
  while (<$yf>) {
    chomp;
    s/#[^"]+$//;
    $ys.="$_\n";
  }
  return Load($ys);
}
