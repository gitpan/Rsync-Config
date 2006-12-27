package Rsync::Config;

use strict;
use warnings;

use vars qw($VERSION);

$VERSION='0.1';

use Scalar::Util qw(blessed);
use English qw(-no_match_vars);

use Rsync::Config::Exceptions;
use Rsync::Config::Module;
use Rsync::Config::Atom;

sub new {
  my ($class, %opt) = @_;
  my $self;

  $self = bless { %opt }, $class;

  #init
  $self->{modules} = ();
  $self->{_main_} = new Rsync::Config::Module(name => '_main_');

  return $self;
}

sub add_blank {
  my ($self) = @_;

  if (! blessed($self)) {
    REX::OutsideClass->throw(
      message => 'add_blank() called outside class instance',
    );
  }

  $self->{_main_}->add_blank();

  return $self->{_main_}->atoms_no();
}

sub add_comment {
  my ($self, $value) = @_;
  my $atom;

  if (! blessed($self)) {
    REX::OutsideClass->throw(
      message => 'add_comment() called outside class instance'
    );
  }

  $self->{_main_}->add_comment($value);
  return $self->{_main_}->atoms_no();
}

sub add_atom {
  my ($self, $atom_name, $atom_value) = @_;

  if (! blessed($self)) {
    REX::OutsideClass->throw(
      message => 'add_atom() called outside class instance',
    );
  }

  $self->{_main_}->add_atom($atom_name, $atom_value);
  return $self->{_main_}->atoms_no();
}

sub add_module {
  my ($self, $module) = @_;

  if (! blessed($self)) {
    REX::OutsideClass->throw(
      message => 'Called outside class instance',
    );
  }

  if (! $module) {
    REX::Param::Missing->throw(
      message => 'module is not defined',
      pname   => 'module',
    );
  }

  if (ref $module ne 'Rsync::Config::Module') {
    REX::Param::Invalid->throw(
      message => 'module is not a instance of Rsync::Config::Module',
      pname   => 'module',
    );
  }

  push @{ $self->{modules} }, $module;

  return $module;
}

sub modules_no {
  my ($self) = @_;

  if (! blessed($self)) {
    REX::OutsideClass->throw(
      message => 'Called outside class instance',
    );
  }

  if (! $self->{modules}) {
    return 0;
  }
  else {
    return (scalar @{ $self->{modules} });
  }
}

sub atoms_no {
  my ($self) = @_;

  if (! blessed($self)) {
    REX::OutsideClass->throw(
      message => 'Called outside class instance',
    );
  }

  return $self->{_main_}->atoms_no();
}

sub to_string {
  my ($self, $indent) = @_;
  my $res;

  if (! blessed($self)) {
    REX::OutsideClass->throw(
      message => 'to_string() called outside class instance',
    );
  }

  foreach($self->{_main_}->atoms()) {
    my $atom = $_;

    $res .= $atom->to_string . $RS;
  }

  foreach(@{ $self->{modules} }) {
    my $module = $_;

    $res .= $module->to_string($indent) . $RS;
  }

  return $res;
}

sub to_file {
  my ($self, $filename, $indent) = @_;
  my $fh;

  if (! blessed($self)) {
    REX::OutsideClass->throw(
      message => 'write called outside class instance',
    );
  }

  if (! $filename) {
    REX::Param::Missing->throw(
      message => 'filename not specified',
      pname   => 'filename',
    );
  }

  if (! defined $indent) {
    if ($self->{indent}) {
      $indent = $self->{indent};
    }
  }

  if ( ! open $fh, '>', $filename ) {
    REX::File::Create->throw(message => 'Could not create file', filepath => $filename);
  }
  print $fh $self->to_string($indent);
  close $fh;

  return 1;
}

1;

__END__

=head1 NAME

Rsync::Config

=head1 VERSION

0.1

=head1 DESCRIPTION

Rsync::Config is a module who can be used to create rsync configuration files.
A configuration file (from Rsync::Config point of view) is made by atoms and
modules with atoms. A atom is the smallest piece from the configuration file.

=head1 SYNOPSIS

 use Rsync::Config;
 use Rsync::Config::Atom;
 use Rsync::Config::Module;

 sub main {
   my ($conf, $module);

   $conf = new Rsync::Config();
   $conf->add_comment('Main configuration file for our rsync daemon');
   $conf->add_atom('read only','yes');
   $conf->add_atom('chroot','yes');

   $module = new Rsync::Config::Module(name => 'cpan');
   $module->add_atom('path','/var/ftp/pub/mirrors/ftp.cpan.org/');
   $module->add_atom('comment', 'CPAN mirror');

   $conf->add_module($module);
   $conf->to_file('/etc/rsyncd.conf');
 }

=head1 SUBROUTINES/METHODS

Each subroutine and/or method throws REX::OutsideClass exception
if called outside class instance. Besides this exception, each
method may throw another exception. Please read the documentation for
each method for more information

=head2 new(%opt)

The class contructor. At this moment, only one parameter can be specified:
B<indent> (true/false value)

=head2 add_blank()

Adds a new blank global atom. Returns the number of global atoms

=head2 add_comment($value)

Adds a new global comment atom. Returns the number of global atoms

=head2 add_atom($name, $value)

Adds a new global atom. Returns the number of global atoms

=head2 add_module($module)

Adds the $module (a instance of Rsync::Config::Module) to the list of modules.
If $module is not defined B<REX::Param::Missing> exception is throwned. If
$module is not a instance of B<Rsync::Config::Module>, B<REX::Param::Invalid>
exception is throwned.

=head2 modules_no()

Returns the number of modules

=head2 atoms_no()

Returns the number of global atoms

=head2 to_string($indent)

Returns the string representation for this configuration file. If $indent
is specified, a best effort indentation is tried. Please note that $indent
has high preference over option $indent specified at B<new()>

=head2 to_file($filename, $indent)

Writes the configuration into the file specified by $filename. 
if $indent is specified, a best effort indentation is tried. Please note that $indent
has high preference over option $indent specified at B<new()>
The following exceptions may be throwned:

=over 2

=item REX::Param::Missing - $filename not specified

=item REX::File::Create - file could not be created

=back

If the file already exists, the content of that file will be lost.

=head1 DEPENDENCIES

Rsync::Config depends on the following modules:

=over 2

=item English

=item Scalar::Util

=back

=head1 DIAGNOSTICS

All tests are located into t directory.

=head1 PERL CRITIC

This module is perl critic level 1 compliant.

=head1 CONFIGURATION AND ENVIRONMENT

This module does not use any configuration files or environment
variables. The used modules however may use such things. Please
refer to each module man page for more information.

=head1 INCOMPATIBILITIES

None known to the author

=head1 BUGS AND LIMITATIONS

=over 3

=item *) Using atoms with values 0 or undef will trigger exceptions.

=item *) Parsing of rsync configuration file is not yet implemented

=item *) Global atoms can't be indented

=back

=head1 SEE ALSO

L<Rsync::Config::Exceptions> L<Rsync::Config::Module> L<Rsync::Config::Atom>

=head1 AUTHOR

Subredu Manuel <diablo@packages.ro>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2006 Subredu Manuel.  All Rights Reserved.
This module is free software; you can redistribute it 
and/or modify it under the same terms as Perl itself.
The LICENSE file contains the full text of the license.

=cut
