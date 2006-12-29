package Rsync::Config::Renderer;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION='0.1';

use Scalar::Util qw(blessed);

sub new {
  my ($class, %opt) = @_;
  my $self;

  $self = bless { %opt }, $class;
  
  $self->_init();

  return $self;
}

sub _init {
  my ($self) = @_;

  if ( ! defined $self->{indent}) {
    $self->{indent} = 1;
  }

  if ( ! defined $self->{indent_char}) {
    $self->{indent_char} = "\t";
  }

  return $self;
}

sub indent {
  my ($self, $indent_opt) = @_;

  if (! defined $indent_opt) {
    return $self->{indent};
  }
  else {
    $self->{indent} = $indent_opt;
    return $self;
  }
}

sub indent_char {
  my ($self, $indent_char_opt) = @_;

  if (! defined $indent_char_opt) {
    return $self->{indent_char};
  }
  else {
    $self->{indent_char} = $indent_char_opt;
    return $self;
  }
}

sub indent_string {
  my ($self, $indent, $indent_char) = @_;

  if (! blessed($self)) {
    # called as a function

    $indent_char = $indent;
    $indent = $self;
  }
  else {
    if (! $indent) {
      $indent = $self->{indent};
    }
    if (! $indent_char) {
      $indent_char = $self->{indent_char};
    }
  }

  return $indent_char x $indent;
}

1;

__END__

=head1 NAME

Rsync::Config::Renderer

=head1 VERSION

0.1

=head1 DESCRIPTION

Rsync::Config::Renderer is used as a base class for Rsync::Config::Atom and
Rsync::Config::Module.

=head1 SYNOPSIS

 use Rsync::Config::Renderer;

 use base qw(Rsync::Config::Renderer);

=head1 SUBROUTINES/METHODS

=head2 new()

Class contructor. Accepts a options hash as a parameter. The hash can
contain the following options:

=over 2

=item *) indent

=item *) indent_char

=back

The B<indent> option is used as a multiplicator. This means that if you set
B<indent> to 3 and B<indent_char> to q{ }, indent_string will be '   ' (3 spaces).

=head2 indent($new_indent)

If $new_indent is undefined, this method will return the current indent value. If
$new_indent is defined, the new value is set and $self is returned. This method
can be used only in a class instance.

=head2 indent_char($new_indent_char)

If $new_indent_char is undefined, this method will return the current indent char value. If
$new_indent_char is defined, the new value is set and $self is returned. This method
can be used only in a class instance.

=head2 indent_string($indent, $indent_char)

Returns a string with the current indentation. If $indent and $indent_char are defined, they
have higher precedence over the internal values. This method can also be called as a function.

=head1 DEPENDENCIES

Rsync::Config::Renderer depends on the following modules:

=over 1

=item Scalar::Util

=back

=head1 DIAGNOSTICS

All tests are located in the t directory .

=head1 PERL CRITIC

This module is perl critic level 1 compliant.

=head1 CONFIGURATION AND ENVIRONMENT

This module does not use any configuration files or environment
variables. The used modules however may use such things. Please
refer to each module man page for more information.

=head1 INCOMPATIBILITIES

None known to the author

=head1 BUGS AND LIMITATIONS

No bugs known to the author

=head1 SEE ALSO

L<Rsync::Config::Exceptions> L<Rsync::Config::Module> L<Rsync::Config::Atom> L<Rsync::Config>

=head1 AUTHOR

Subredu Manuel <diablo@packages.ro>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2006 Subredu Manuel.  All Rights Reserved.
This module is free software; you can redistribute it 
and/or modify it under the same terms as Perl itself.
The LICENSE file contains the full text of the license.

=cut
