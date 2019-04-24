#!/usr/bin/env perl
#-*-mode: cperl-*-

use v5.10;
use Digest::MD5 qw/md5_hex/;
# super-secret name munging that happens:
# if len(tablename) > 40:
#   oldname = tablename
#   logger.debug('Edge tablename {} too long, shortening'.format(oldname))
#   tablename = 'edge_{}_{}'.format(
#     str(hashlib.md5(tablename).hexdigest())[:8],
#     "{}{}{}".format(
#       ''.join([a[:2] for a in src_label.split('_')])[:10],
#       ''.join([a[:2] for a in label.split('_')])[:7],
#       ''.join([a[:2] for a in dst_label.split('_')])[:10],
#      )
#    )
use GDC::Dict;
use strict;

# arg can be schemas directory
$ENV{SCHEMADIR} //= shift() or die "no schemadir";

my $dict = GDC::Dict->new($ENV{SCHEMADIR});

for my $edge ($dict->edges) {
  say join("\t", edge_table_name($edge));
}

sub edge_table_name {
  my ($edge) = @_;
  my $t = join('',$edge->src->name, $edge->type, $edge->dst->name);
  $t =~ s/_//g;
  my $s = $t="edge_$t";
  if (length $t > 40) {
    my $md5 = md5_hex($t);
    $t = "edge_".substr($md5, 0, 8)."_".
      substr( join('',map { substr($_,0,2) } split /_/,$edge->src->name), 0, 10 ).
	substr( join('',map { substr($_,0,2) } split /_/,$edge->type), 0, 10 ).
	  substr( join('',map { substr($_,0,2) } split /_/,$edge->dst->name), 0, 10 );
  }
  return $t, $edge->type;
}

