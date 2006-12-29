use strict;
use warnings;

# use Test::More qw(no_plan);
use Test::More tests => 17;

BEGIN {
  use_ok('Rsync::Config::Exceptions');
};

my (@ex_gen, @ex_file, @ex_obj);

@ex_gen  = qw(
               REX::General
             );

@ex_file = qw(
               REX::File
               REX::File::NotFound
               REX::File::Open
               REX::File::Create
             );
@ex_obj  = qw(
               REX::OutsideClass
             );

# Test is exception is throwned and catched
sub test_ex_throw {
  my @ex_list = @_;

  foreach(@ex_list) {
    my $e_name = $_;

    eval {
      $e_name->throw('Exception test');
    };

    if (Exception::Class->caught($e_name)) {
      ok(1, "$e_name raised and catched");
    }
    else {
      ok(0, "$e_name not raised");
    }
  }
}

# Test is parameters are ok
sub test_ex_file_param {
  foreach(@ex_file) {
    my $e_name = $_;

    eval {
      $e_name->throw(message => 'Exception test', filepath => '/tmp/testing.stuff');
    };

    if (my $e = Exception::Class->caught($e_name)) {
      ok($e->filepath eq '/tmp/testing.stuff', "$e_name filepath parameter ok");
    }
  }
}

# Test exception message
sub test_ex_message {
  my @ex_list = @_;

  foreach(@ex_list) {
    my $e_name = $_;

    eval {
      $e_name->throw(message => 'Exception test');
    };

    if (my $e = Exception::Class->caught($e_name)) {
      ok($e->message eq 'Exception test', "$e_name message ok");
    }
  }
}

test_ex_throw(@ex_gen);
test_ex_throw(@ex_file);
test_ex_throw(@ex_obj);

test_ex_message(@ex_gen);
test_ex_message(@ex_file);
test_ex_message(@ex_obj);

test_ex_file_param();
