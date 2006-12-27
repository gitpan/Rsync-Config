package Rsync::Config::Module;

use strict;
use warnings;

use Scalar::Util qw(blessed);
use English qw(-no_match_vars);

use Rsync::Config::Exceptions;
use Rsync::Config::Atom;

sub new {
  my ($class, %opt) = @_;
  my $self;

  $self = bless { %opt }, $class;

  # make some checks on the parameters
  $self->_basic_checks();

  # initialize
  $self->_init();

  return $self;
}

sub _init {
  my ($self) = @_;

  $self->{atoms}       = undef;
  $self->{indent_char} = "\t";
  $self->{indent}      = 1;
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

  return 1;
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

  return 1;
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

  return 1;
}

sub _basic_checks {
  my ($self) = @_;

  $self->_check_if_exists('name');
  $self->_check_if_defined('name');
  $self->_check_if_blank('name');

  return 1;
}

sub atoms {
  my ($self) = @_;

  if (! blessed($self)) {
    REX::OutsideClass->throw(
      message => 'atoms called outside class instance',
    );
  }

  if ( wantarray ) {
    if (! $self->{atoms}) {
      return ();
    }
    else {
      return @{ $self->{atoms} };
    }
  }
  else {
    return $self->{atoms};
  }
}

sub atoms_no {
  my ($self) = @_;

  if (! blessed($self)) {
    REX::OutsideClass->throw(
      message => 'atoms called outside class instance',
    );
  }

  if (! $self->{atoms}) {
    return 0;
  }
  else {
    return (scalar @{$self->{atoms}});
  }
}

sub add_blank {
  my ($self) = @_;

  if (! blessed($self)) {
    REX::OutsideClass->throw(
      message => 'add_blank called outside class instance',
    );
  }

  my $atom = new Rsync::Config::Atom(name => '__blank__');
  push @{ $self->{atoms} }, $atom;

  return 1;
}

sub add_comment {
  my ($self, $comment) = @_;

  if (! blessed($self)) {
    REX::OutsideClass->throw(
      message => 'add_comment called outside class instance',
    );
  }

  my $atom = new Rsync::Config::Atom(name => '__comment__', value => $comment);

  push @{ $self->{atoms} }, $atom;

  return $self->atoms_no;
}

sub add_atom {
  my ($self, $atom_name, $atom_value) = @_;

  if (! blessed($self)) {
    REX::OutsideClass->throw(
      message => 'add_atom called outside class instance',
    );
  }

  my $atom = new Rsync::Config::Atom(name => $atom_name, value => $atom_value);

  push @{ $self->{atoms} }, $atom;

  return $self->atoms_no;
}

sub to_string {
  my ($self, $indent) = @_;
  my $result;

  if (! blessed($self)) {
    REX::OutsideClass->throw(
      message => 'to_string called outside class instance',
    );
  }

  if (! defined $indent) {
    if ($self->{indent}) {
      $indent = $self->{indent};
    }
    else {
      $indent = 0;
    }
  }

  $result = sprintf "[%s]\n", $self->{name};
  foreach(@{ $self->{atoms}}) {
    my $atom = $_;

    if ($indent) {
      $result .= $self->{indent_char} x $indent;
    }

    $result .= $atom->to_string . $RS;
  }

  return $result;
}

1;

__END__

=head1 NAME

Rsync::Config::Module

=head1 VERSION

0.1

=head1 DESCRIPTION

A module is a module entry from a rsync configuration file. 
Ex:
 [cpan]
   path = /var/ftp/pub/mirrors/ftp.cpan.org/
   comment = CPAN mirror

Rsync::Config::Module is used to create a module who can be later used in generating
a rsync configuration file. Each module is made by atoms (Rsync::Config::Atom).

=head1 SYNOPSIS

 use Rsync::Config::Module;

 sub main {
   my $mod_cpan;

   $mod_cpan = new Rsync::Config::Module(name => 'cpan');

   $mod_cpan->add_atom(name => 'path', value => '/var/ftp/pub/mirrors/ftp.cpan.org/');
   $mod_cpan->add_atom(name => 'comment', value => 'CPAN mirror');
 }

=head1 SUBROUTINES/METHODS

All subroutines and/or methods throw REX::OutsideClass when called
outside class instance. Besides this, each method may throw other
exceptions. Please see the documentation of each method for more
information.

=head2 new(%opt)

The class contructor. %opt must contain at least a key named B<name>
with the name of the module. At this moment it is possible to specify
two parameters:

=over 2

=item *) B<indent> - default 1

=item *) B<indent_char> - default TAB

=back

If B<indent> is E<gt> 0 the text is indented B<indent> times.

=head2 add_blank()

Adds a blank atom to this module.

=head2 add_comment($comment)

Adds a comment atom to this module.

=head2 add_atom($name, $value)

Adds a new atom to this module. The $name and $value are 
passed as they are to Rsync::Config::Atom

=head2 atoms_no()

Returns the number of current atoms.

=head2 atoms()

In scalar context returns a array reference to the list
of current atoms. In array content returns a array of current atoms.

=head2 to_string()

Returns the string representation of the current module. If B<indent>
is true, a best of effort is made to indent the module.

=head1 DEPENDENCIES

Rsync::Config::Module uses the following modules:

=over 2

=item English

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

Using atoms with values 0 or undef will trigger exceptions.

=head1 SEE ALSO

L<Rsync::Config::Exceptions> L<Rsync::Config::Atom> L<Rsync::Config>

=head1 AUTHOR

Subredu Manuel <diablo@packages.ro>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2006 Subredu Manuel.  All Rights Reserved.
This module is free software; you can redistribute it 
and/or modify it under the same terms as Perl itself.
The LICENSE file contains the full text of the license.

=cut
