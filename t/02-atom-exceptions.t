use strict;
use warnings;

use English qw(-no_match_vars);
# use Test::More qw(no_plan);
use Test::More tests => 16;

BEGIN {
  use_ok('Rsync::Config::Atom');
};

my $atom;

 # test if exception is raised when no parameters are given
 eval {
   $atom = new Rsync::Config::Atom();
 };

 if (my $e = Exception::Class->caught('REX::Param::Missing')) {
   ok(1, 'exception raised when no parameters are given');
   is($e->pname,'name', 'exception->pname is pname');
 }
 else {
   ok(0, 'geee .. no exceptions raised when no parameters are given.');
 }


 # test if exception is raised when only name is given
 eval {
   $atom = new Rsync::Config::Atom(name => 'uid');
 };
 if (my $e = Exception::Class->caught('REX::Param::Missing')) {
   ok(1, 'exception raised when only name is given');
   is($e->pname, 'value', 'exception->pname is value');
 }
 else {
   ok(0, 'geee .. no exceptions raised when only name of the atom is given');
 }
 
 # test if exception is raised when only value is given
 eval {
   $atom = new Rsync::Config::Atom(value => 'root');
 };
 if (my $e = Exception::Class->caught('REX::Param::Missing')) {
   ok(1, 'exception raised when only value is given');
   is($e->pname, 'name', 'exception->pname is name');
 }
 else {
   ok(0, 'geee .. no exceptions raised when only name of the atom is given');
 }

 # test for undefined values
 eval {
   $atom = new Rsync::Config::Atom(name => undef);
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
   $atom = new Rsync::Config::Atom(name => 'uid', value => 'root');
 };
 if ($EVAL_ERROR) {
   ok(0, 'WTF should I create a valid node ?! Fix this ASAP');
 }
 else {
   ok(1, 'Creating valid nodes, works');
 }

 #test if blank works
 eval {
   $atom = new Rsync::Config::Atom(name => '__blank__');
 };
 if ($EVAL_ERROR) {
   ok(0, 'Ups ! Creating blank atoms does not work');
 }
 else {
   ok(1, 'Create blanks works');
 }

 #test if comments works
 eval {
   $atom = new Rsync::Config::Atom(name => '__comment__', value => 'this is a comment');
 };
 if ($EVAL_ERROR) {
   ok(0, 'Ups ! Creating comment atoms does not work');
 }
 else {
   ok(1, 'Create comment works');
 }
 
 #test if comments (without the comments value) works
 eval {
   $atom = new Rsync::Config::Atom(name => '__comment__');
 };
 if (my $e = Exception::Class->caught('REX::Param::Missing')) {
   ok(1, 'good. Exception raised when name => "__comment__" and no value was given');
   is($e->pname, 'value', 'good. Value of $e->pname is value');
 }
 else {
   ok(0, 'Uff .. creating a comment node without the value of the comment works. FIX THIS !');
 }

 #test for blank values
 eval {
   $atom = new Rsync::Config::Atom( name => '', value => '100');
 };
 if (my $e = Exception::Class->caught('REX::Param::Invalid')) {
   ok(1, 'exception raised when name is q{}');
   is($e->pname, 'name', '$e->pname is name');
 }
 else {
   ok(0, 'UPS ! exception was not raised when name => q{} . Fix this !');
 }
