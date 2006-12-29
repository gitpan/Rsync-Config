package Rsync::Config::Module;

use strict;
use warnings;

use vars qw($VERSION);

$VERSION='0.2';

use Scalar::Util qw(blessed);
use English      qw(-no_match_vars);
use CLASS;

use Rsync::Config::Exceptions;
use Rsync::Config::Atom;

use base qw(Rsync::Config::Renderer);

sub new {
  my ($class, %opt) = @_;
  my $self;

  $self = $class->SUPER::new(%opt);

  # make some checks on the parameters
  $self->_basic_checks();

  # initialize
  $self->_init(\%opt);

  return $self;
}

sub _init {
  my ($self, $opt) = @_;

  $self->{atoms} = undef;
  
  if (! $opt->{indent}) {
    $self->{indent} = 0;
  }

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

  $self->_check_if_exists('name');
  $self->_check_if_defined('name');
  $self->_check_if_blank('name');

  return 1;
}

sub atoms {
  my ($self) = @_;

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

  if (! $self->{atoms}) {
    return 0;
  }
  else {
    return (scalar @{$self->{atoms}});
  }
}

sub _add_atom_obj {
  my ($self, $atom_obj) = @_;

  push @{ $self->{atoms} }, $atom_obj;
  return $self;
}

sub add_atom_obj {
  my ($self, $atom_obj) = @_;

  if (! (blessed($self) && $self->isa($CLASS))) {
    REX::OutsideClass->throw(
      message => 'add_atom_obj called outside class instance',
    );
  }

  if (! $atom_obj->isa('Rsync::Config::Atom')) {
    REX::Param::Invalid->throw(
      message => 'atom_obj is not a instance of Rsync::Config::Atom',
      pname   => 'atom_obj',
    );
  }

  return $self->_add_atom_obj($atom_obj);
}

sub _add_atom {
  my ($self, $atom_name, $atom_value) = @_;
  my $atom;

  $atom = new Rsync::Config::Atom(
                name => $atom_name,
                value => $atom_value,
                indent => $self->{indent} + 1,
                indent_char => $self->{indent_char},
          );

  return $self->_add_atom_obj($atom);
}

sub add_blank {
  my ($self) = @_;

  if (! (blessed($self) && $self->isa($CLASS))) {
    REX::OutsideClass->throw(
      message => 'add_blank called outside class instance',
    );
  }

  return $self->_add_atom('__blank__', '');
}

sub add_comment {
  my ($self, $comment) = @_;

  if (! (blessed($self) && $self->isa($CLASS))) {
    REX::OutsideClass->throw(
      message => 'add_comment called outside class instance',
    );
  }

  return $self->_add_atom('__comment__', $comment);
}

sub add_atom {
  my ($self, $atom_name, $atom_value) = @_;

  if (! (blessed($self) && $self->isa($CLASS))) {
    REX::OutsideClass->throw(
      message => 'add_atom called outside class instance',
    );
  }

  return $self->_add_atom($atom_name, $atom_value);
}

sub to_string {
  my ($self) = @_;
  my $result;

  $result = sprintf "%s[%s]\n", $self->indent_string, $self->{name};
  foreach(@{ $self->{atoms}}) {
    my $atom = $_;

    $result .= $atom->to_string . $RS;
  }

  return $result;
}

1;

__END__

=head1 NAME

Rsync::Config::Module

=head1 VERSION

0.2

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

Please note that some methods may throw exceptions. Check the documentation
for each method to see what exceptions may be throwned.

=head2 new(%opt)

The class contructor. %opt must contain at least a key named B<name>
with the name of the module.
Name and value must be specified, except for __blank__ atoms. 
new may throw the following exceptions:

=over 3

=item *) REX::Param::Missing - when name is not specified

=item *) REX::Param::Undef - when name is not defined

=item *) REX::Param::Invalid - when name is blank or 0

=back

=head2 add_blank()

Adds a blank atom to this module. Returns the object.
This method internally calles Rsync::Config::Atom constructor.

=head2 add_comment($comment)

Adds a comment atom to this module. Returns the object.
This method internally calles Rsync::Config::Atom constructor with
$comment parameter. Please read B<Rsync::Config::Atom>
contructor documentation to see if any exceptions are throwned.

=head2 add_atom($name, $value)

Adds a new atom to this module.
This method internally calles Rsync::Config::Atom constructor with
$name and $value parameters. Please read B<Rsync::Config::Atom>
contructor documentation to see if any exceptions are throwned.

=head2 add_atom_obj($atom_obj)

Adds a previsiously created atom object to the list of current atoms. If
$atom_obj is not a instance of Rsync::Config::Atom B<REX::Param::Invalid>
exception is throwned.

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

L<Rsync::Config::Exceptions> L<Rsync::Config::Atom> L<Rsync::Config>
L<Rsync::Config::Renderer>

=head1 AUTHOR

Subredu Manuel <diablo@packages.ro>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2006 Subredu Manuel.  All Rights Reserved.
This module is free software; you can redistribute it 
and/or modify it under the same terms as Perl itself.
The LICENSE file contains the full text of the license.

=cut
