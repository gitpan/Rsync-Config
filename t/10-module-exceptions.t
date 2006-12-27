use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More qw(no_plan);

BEGIN {
  use_ok('Rsync::Config::Module');
};

my $module;

 # test if exception is raised when no parameters are given
 eval {
   $module = new Rsync::Config::Module();
 };

 if (my $e = Exception::Class->caught('REX::Param::Missing')) {
   ok(1, 'exception raised when no parameters are given');
   is($e->pname,'name', 'exception->pname is pname');
 }
 else {
   ok(0, 'geee .. no exceptions raised when no parameters are given.');
 }

 # test for blank value
 eval {
   $module = new Rsync::Config::Module(name => q{});
 };
 if (my $e = Exception::Class->caught('REX::Param::Invalid')) {
   ok(1, 'exception raised when blank values are used');
   is($e->pname, 'name', 'exception->pname is name');
 }
 else {
   ok(0, 'geee .. no exceptions raised when blank values are used');
 }


 # test for undefined values
 eval {
   $module = new Rsync::Config::Module(name => undef);
 };
 if (my $e = Exception::Class->caught('REX::Param::Undef')) {
   ok(1, 'exception raised when undefined values are used');
   is($e->pname, 'name', 'exception->pname is name');
 }
 else {
   ok(0, 'geee .. no exceptions raised when undefined values are used');
 }

 #test if creating a simple valid node, works
 eval {
   $module = new Rsync::Config::Module(name => 'cpan');
 };
 if ($EVAL_ERROR) {
   ok(0, 'WTF ! This should work ! Fix this ASAP');
 }
 else {
   ok(1, 'Creating valid module, works');
 }

 #call from outside class
 eval {
   Rsync::Config::Module::has_atoms();
 };

 if (Exception::Class->caught('REX::OutsideClass')) {
   ok(1, 'exception raised when method is_blank() is called outside class instance');
 }
