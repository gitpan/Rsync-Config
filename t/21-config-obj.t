use strict;
use warnings;

use English qw(-no_match_vars);
# use Test::More qw(no_plan);
use Test::More tests => 5;

BEGIN {
  use_ok('Rsync::Config');
};

my $rsync;
my ($atom, $module);

$rsync = new Rsync::Config();

ok($rsync->atoms_no == 0, 'we have 0 atoms');
ok($rsync->modules_no == 0, 'we have 0 modules');

$module = new Rsync::Config::Module(name => 'cpan');
$module->add_atom(name => 'path', value => '/var/ftp/pub/mirrors/cpan.org/');
$module->add_atom(name => 'read only', value => 'yes');

$rsync->add_module($module);
$rsync->add_atom(name => 'log', value => '/var/log/rsyncd.log');

ok($rsync->modules_no == 1, 'we have 1 modules');
ok($rsync->atoms_no == 1, 'we have 1 atom');
