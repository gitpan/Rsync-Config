use strict;
use warnings;

use English qw(-no_match_vars);
# use Test::More qw(no_plan);
use Test::More tests => 7;

BEGIN {
  use_ok('Rsync::Config');
};

my $rsync;

 # create works ?
 eval {
   $rsync = new Rsync::Config();
 };
 ok(! $EVAL_ERROR, 'create works');



 # add_atom without parameters
 eval {
   $rsync->add_atom();
 };
 ok(Exception::Class->caught('REX::Param::Undef'), 'exception raised when add_atom() is called without parameters');



 # add atom with name but no value
 eval {
   $rsync->add_atom('uid');
 };
 ok(Exception::Class->caught('REX::Param::Undef'), 'exception raised when add_atom(name => "uid") - no value');



 # add_atom() valid call works
 eval {
   $rsync->add_atom('uid', 'root');
 };
 ok(! $EVAL_ERROR, 'valid add_atom works');



 # add_blank() works
 eval {
   $rsync->add_blank();
 };
 ok(! $EVAL_ERROR, 'add_blank() works');



 # add_comment('test');
 eval {
   $rsync->add_comment('test');
 };
 ok(! $EVAL_ERROR, 'add_comment("test") works');
