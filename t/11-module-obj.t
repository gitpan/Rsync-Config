use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More qw(no_plan);

BEGIN {
  use_ok('Rsync::Config::Module');
};

my $module;
my ($tvar, @tarr);

$module = new Rsync::Config::Module(name => 'cpan');
ok($module->atoms_no == 0, 'we have 0 atoms');

$module->add_blank();
ok($module->atoms_no == 1, 'we have 1 atom');

$tvar = $module->atoms;
@tarr = $module->atoms;
ok(ref($tvar) eq 'ARRAY', 'we have a array reference');
ok(ref($tarr[0]) eq 'Rsync::Config::Atom', 'we have a reference to the Rsync::Config::Atom object');

$module->add_comment('comment #1');
ok($module->atoms_no == 2, 'we have 2 atoms');

eval {
  $module->add_comment();
};
if (my $e = Exception::Class->caught('REX::Param::Undef')) {
  ok(1, 'exception raised when add_comment() called');
}

ok($module->atoms_no == 2, 'we still have 2 atoms');

 eval {
   $module->add_atom('path', '/var/ftp/pub/mirrors/cpan.org/');
   $module->add_atom('read only', 'yes');
   $module->add_atom('uid', 'root');
 };

 if ($EVAL_ERROR) {
   ok(0, 'Ups ! Exception catched. Not ok.' . $EVAL_ERROR->message);
 }

ok($module->atoms_no == 5, 'we have 5 atoms');
