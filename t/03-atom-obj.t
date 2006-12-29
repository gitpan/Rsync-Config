use strict;
use warnings;

use English qw(-no_match_vars);
# use Test::More qw(no_plan);
use Test::More tests => 10;

BEGIN {
  use_ok('Rsync::Config::Atom');
};

my $atom;

$atom = new Rsync::Config::Atom( name => 'uid', value => '100');

is($atom->name, 'uid', '$atom->name() works');
is($atom->value, '100', '$atom->value() works');

is($atom->name('gid'), 'gid', '$atom->name("gid") returns gid');
is($atom->value('200'), '200', '$atom->value("200") returns 200');

is($atom->is_blank, 0, '$atom is not blank');
is($atom->is_comment, 0, '$atom is not comment');

$atom = new Rsync::Config::Atom( name => '__blank__' );
is($atom->is_blank, 1, '$atom is blank');

$atom = new Rsync::Config::Atom( name => '__comment__', value => 'This is a comment');
is($atom->is_comment, 1, '$atom is comment');
is($atom->is_blank,   0, '$atom is not blank');
