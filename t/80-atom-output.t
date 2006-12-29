use strict;
use warnings;

use English qw(-no_match_vars);
# use Test::More qw(no_plan);
use Test::More tests => 3;

BEGIN {
  use_ok('Rsync::Config::Atom');
};

my $atom;

$atom = new Rsync::Config::Atom(name => 'path', value => '/var/ftp/pub/mirrors/cpan.org/');

is($atom->to_string, "\tpath = /var/ftp/pub/mirrors/cpan.org/", 'default output');

$atom->indent(0);
is($atom->to_string, 'path = /var/ftp/pub/mirrors/cpan.org/', 'no indent');
