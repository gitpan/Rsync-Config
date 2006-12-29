############################################################
#                                                          #
# Copyright (C) 2006 Subredu Manuel.  All Rights Reserved. #
# This module is free software; you can redistribute it    #
# and/or modify it under the same terms as Perl itself.    #
#                                                          #
############################################################

package Rsync::Config::Atom;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = '0.2';

use Scalar::Util qw(blessed);
use English qw(-no_match_vars);
use CLASS;

use Rsync::Config::Exceptions;

use base qw(Rsync::Config::Renderer);

sub new {
  my ($class, %opt) = @_;
  my $self;

  $self = $class->SUPER::new(%opt);

  $self->_basic_checks();
  return $self;
}

sub _check_if_exists {
  my ($self, @plist) = @_;

  foreach(@plist) {
    my $pname = $_;

    if (! exists $self->{$pname}) {
      REX::Param::Missing->throw(
        message => $pname . ' was not found in parameters list',
        pname => $pname,
      );
    }
  }

  return $self;
}

sub _check_if_defined {
  my ($self, @plist) = @_;

  foreach(@plist) {
    my $pname = $_;

    if (! defined $self->{$pname}) {
      REX::Param::Undef->throw(
        pname => $pname,
      );
    }
  }

  return $self;
}

sub _check_if_blank {
  my ($self, @plist) = @_;

  foreach(@plist) {
    my $pname = $_;

    if (! $self->{$pname}) {
      REX::Param::Invalid->throw(
        pname => $pname,
      );
    }
  }

  return $self;
}

sub _basic_checks {
  my ($self) = @_;

  $self->_check_if_exists(qw(name));
  $self->_check_if_defined(qw(name));
  $self->_check_if_blank(qw(name));

  return if ($self->{name} eq '__blank__');

  $self->_check_if_exists('value');
  $self->_check_if_defined('value');
  $self->_check_if_blank('value');

  return $self;
}

sub name {
  my ($self, $new_name) = @_;

  if (! (blessed($self) && $self->isa($CLASS))) {
    REX::OutsideClass->throw(
      message => 'name called outside class instance',
    );
  }

  if ($new_name) {
    $self->{name} = $new_name;
  }

  return $self->{name};
}

sub value {
  my ($self, $new_value) = @_;

  if (! (blessed($self) && $self->isa($CLASS))) {
    REX::OutsideClass->throw(
      message => 'value called outside class instance',
    );
  }

  if ($new_value) {
    $self->{value} = $new_value;
  }

  return $self->{value};
}

sub is_blank {
  my ($self) = @_;

  if ($self->{name} eq '__blank__') {
    return 1;
  }
  else {
    return 0;
  }
}

sub is_comment {
  my ($self) = @_;

  if ($self->{name} eq '__comment__') {
    return 1;
  }
  else {
    return 0;
  }
}

sub to_string {
  my ($self) = @_;
  my $rval = q{};

  if ($self->is_comment) {
    if ($self->{value} !~ m{^ \s* \# .* $}xm) {
      $rval = '# ';
    }
    $rval = sprintf '%s%s%s', $self->indent_string, $rval, $self->{value};
  }
  elsif ($self->is_blank) {
    $rval .= q{};
  }
  else {
    $rval = sprintf '%s%s = %s', $self->indent_string, $self->{name}, $self->{value};
  }

  return $rval;
}

1;

__END__

=head1 NAME

Rsync::Config::Atom - atom of a rsync configuration file

=head1 VERSION

0.2

=head1 DESCRIPTION

Rsync::Config::Atom is the smallest element of a rsync configuration file.
Every atom has a name and a value. There are 2 types of atoms with special
treatment.

=over 2

=item blank atoms (empty lines)

=item comment atoms

=back

Rsync::Config::Atom inherits from Rsync::Config::Renderer.

=head1 SYNOPSIS

 use Rsync::Config::Atom;

 sub main {
   my $atom = new Rsync::Config::Atom(name => 'path', value => '/var/ftp/pub/mirrors/cpan.org');
 }

=head1 SUBROUTINES/METHODS

Please note that some methods may throw exceptions. Check the documentation
for each method to see what exceptions may be throwned.

=head2 new()

The constructor. The constructor accepts a hash as a argument. The hash must
contain 2 keys:

=over 2

=item *) name

=item *) value

=back

name can be:

=over 3

=item *) B<__blank__> who specifies that the atom is a blank line

=item *) B<__comment__> who specifies that the atom is a comment

=item *) B<a string> with the name of the atom

=back

In all cases name and value must be specified, except for __blank__ atoms. 
new may throw the following exceptions:

=over 3

=item *) REX::Param::Missing - when name or value are not specified

=item *) REX::Param::Undef - when the value of the parameters is not defined

=item *) REX::Param::Invalid - when the value of one of the parameters is blank or 0

=back

Also, options accepted by Rsync::Config::Renderer can be used. Check the documentation
of Rsync::Config::Renderer for a complete list of options.

=head2 is_blank()

returns true (1) if the atom is a blank atom (empty line), 0 otherwise

=head2 is_comment()

returns true (1) if the atom is a comment, 0 otherwise

=head2 name($new_name)

changes the name of the atom if $new_name is defined. Always returns the name of the atom.
If this method is called outside class instance a REX::OutsideClass exception is throwned.

=head2 value($new_value)

changes the value of the atom if $new_value is defined. Else, returns the value of the atom.
If this method is called outside class instance a REX::OutsideClass exception is throwned.

=head2 to_string()

returns a string representation of the atom.
If this method is called outside class instance a REX::OutsideClass exception is throwned.

=head1 DEPENDENCIES

Rsync::Config::Atom depends on the following modules:

=over 3

=item English

=item Scalar::Util

=item CLASS

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

Using atoms with values 0 or undef will trigger exceptions.

=head1 SEE ALSO

L<Rsync::Config::Exceptions> L<Rsync::Config::Module> L<Rsync::Config>
L<Rsync::Config::Renderer>

=head1 AUTHOR

Subredu Manuel <diablo@packages.ro>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2006 Subredu Manuel.  All Rights Reserved.
This module is free software; you can redistribute it 
and/or modify it under the same terms as Perl itself.
The LICENSE file contains the full text of the license.

=cut
