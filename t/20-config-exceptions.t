use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More qw(no_plan);

BEGIN {
  use_ok('Rsync::Config');
};

my $rsync;

 # create works ?
 eval {
   $rsync = new Rsync::Config();
 };

 if (! $EVAL_ERROR) {
   ok(1, 'create works');
 }

 # add_atom without parameters
 eval {
   $rsync->add_atom();
 };

 if (my $e = Exception::Class->caught('REX::Param::Undef')) {
   ok(1, 'exception raised when add_atom() called without parameters');
   ok($e->pname eq 'name', '$e->pname is name');
 }
 else {
   ok(0, 'exception not raised when add_atom() is called without parameters');
 }

 # add atom with name but no value
 eval {
   $rsync->add_atom(name => 'uid');
 };

 if (my $e = Exception::Class->caught('REX::Param::Missing')) {
   ok(1, 'exception raised when add_atom() is called only with name and no value');
   ok($e->pname eq 'value', '$e->pname is value');
 } 

 # add_atom() valid call works
 eval {
   $rsync->add_atom('uid', 'root');
 };
 
 if (! $EVAL_ERROR) {
   ok(1, 'valid add_atom() does not raise exceptions');
 }
 else {
   ok(0, 'valid add_atom() does raise exceptions');
 }

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
