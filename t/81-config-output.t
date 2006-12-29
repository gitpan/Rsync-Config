use strict;
use warnings;

use English qw(-no_match_vars);
# use Test::More qw(no_plan);
use Test::More tests => 10;

BEGIN {
  use_ok('Rsync::Config');
  use_ok('Rsync::Config::Module');
};

my ($rsync, $mod1, $mod2, $atom1);

$rsync = new Rsync::Config();
$rsync->add_atom('uid', 'root');

is($rsync->indent, -1, 'default indent is -1');
is($rsync->to_string, "uid = root\n", 'output #1');

$rsync->add_atom('log','/var/log/rsyncd.log');

is($rsync->to_string, "uid = root\nlog = /var/log/rsyncd.log\n", 'output #2');


$mod1 = new Rsync::Config::Module(name => 'cpan');
$mod1->add_atom('path', '/var/ftp/pub/mirrors/cpan.org/');

$rsync->add_module($mod1);

is($rsync->to_string, 'uid = root
log = /var/log/rsyncd.log
[cpan]
	path = /var/ftp/pub/mirrors/cpan.org/
', 'output #3');



# Output test #4
$mod1->add_blank();
is($rsync->to_string, 'uid = root
log = /var/log/rsyncd.log
[cpan]
	path = /var/ftp/pub/mirrors/cpan.org/

', 'output #4');



# Output test #5
$mod1->add_comment('test comment');
is($rsync->to_string, 'uid = root
log = /var/log/rsyncd.log
[cpan]
	path = /var/ftp/pub/mirrors/cpan.org/

	# test comment
', 'output #5');



# Output test #6
$atom1 = new Rsync::Config::Atom(
               name => '__comment__',
               value => 'cpan 2 (for registered users)',
               indent => 0,
         );
$mod1->add_blank()->add_blank();
$mod1->add_atom_obj($atom1);
is($rsync->to_string, 'uid = root
log = /var/log/rsyncd.log
[cpan]
	path = /var/ftp/pub/mirrors/cpan.org/

	# test comment


# cpan 2 (for registered users)
', 'output #6');

# Output test #7
$mod2 = new Rsync::Config::Module(name => 'cpan2');
$mod2->add_atom('path','/var/ftp/pub/mirrors/cpan.org/');
$mod2->add_comment('we allow 30 connections here');
$mod2->add_atom('max connections', '30');
$rsync->add_module($mod2);
is($rsync->to_string, 'uid = root
log = /var/log/rsyncd.log
[cpan]
	path = /var/ftp/pub/mirrors/cpan.org/

	# test comment


# cpan 2 (for registered users)
[cpan2]
	path = /var/ftp/pub/mirrors/cpan.org/
	# we allow 30 connections here
	max connections = 30
', 'output #7');

