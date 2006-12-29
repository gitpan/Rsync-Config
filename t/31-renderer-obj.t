use strict;
use warnings;

use English qw(-no_match_vars);
# use Test::More qw(no_plan);
use Test::More tests => 14;

BEGIN {
  use_ok('Rsync::Config::Renderer');
};

my $render;

 # create works ?
 eval {
   $render = new Rsync::Config::Renderer();
 };
 ok(! $EVAL_ERROR, 'create works');


 is($render->indent(), 1, 'indent() is 1 by default');
 is($render->indent_char(), "\t", 'indent_char() is \t by default');
 is(ref($render->indent(0)), 'Rsync::Config::Renderer', 'renderer object is returned');
 is($render->indent(), 0, 'indent is 0');
 is(ref($render->indent_char(q{ })), 'Rsync::Config::Renderer', 'indent_char(q{ }) is render object');
 is($render->indent_char(), q{ }, 'indent char is q{ }');
 is($render->indent_string(), q{}, 'indent_string is q{}');
 is($render->indent_string(1, "\t"), "\t", 'indent_string is "\t"');

 $render->indent(2);
 is($render->indent, 2, 'indent is 2');
 is($render->indent_string(), '  ', 'indent_string is "  "');

 $render->indent_char("\t");
 is($render->indent_string, "\t\t", 'indent_string is "\t\t"');

 is(Rsync::Config::Renderer::indent_string(2, q{ }), '  ', 'indent_string works as a function, too');
