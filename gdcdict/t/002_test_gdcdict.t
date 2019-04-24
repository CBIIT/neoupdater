#-*-mode: cperl-*-
use Test::More;
use File::Spec;
use lib '../lib';
use GDC::Dict;
my $t = (-d 't' ? 't' : '.');
our %ENV;

my $gdcdict = File::Spec->catdir($ENV{HOME},'Code/GDC/gdcdictionary/gdcdictionary/schemas');
unless (-d $gdcdict) {
  plan skip_all => "Can't find GDC dictionary schema directory";
}

ok my $dict = GDC::Dict->new( $gdcdict );

done_testing();
