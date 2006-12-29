package Rsync::Config;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION='0.2';

use Scalar::Util qw(blessed);
use English      qw(-no_match_vars);
use CLASS;

use Rsync::Config::Exceptions;
use Rsync::Config::Module;
use Rsync::Config::Atom;

use base qw(Rsync::Config::Module);

sub new {
  my ($class, %opt) = @_;
  my $self;

  #add a name to the module, else we get a exception and we don't want that :)
  $opt{name} = '_main_';
  $self = $class->SUPER::new(%opt);

  $self->_init(\%opt);

  return $self;
}

sub _init {
  my ($self, $opt) = @_;

  $self->{modules} = ();

  if (! $opt->{indent}) {
    $self->indent(-1);
  }

  return $self;
}

sub add_module {
  my ($self, $module) = @_;

  if (! (blessed($self) && $self->isa($CLASS))) {
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

  if (! $module->isa('Rsync::Config::Module')) {
    REX::Param::Invalid->throw(
      message => 'module is not a instance of Rsync::Config::Module',
      pname   => 'module',
    );
  }

  push @{ $self->{modules} }, $module;

  return $self;
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

sub to_string {
  my ($self) = @_;
  my $res;

  if (! blessed($self)) {
    REX::OutsideClass->throw(
      message => 'to_string() called outside class instance',
    );
  }

  foreach($self->atoms()) {
    my $atom = $_;

    $res .= $atom->to_string . $RS;
  }

  foreach(@{ $self->{modules} }) {
    my $module = $_;

    $res .= $module->to_string();
  }

  return $res;
}

sub to_file {
  my ($self, $filename) = @_;
  my $fh;

  if (! (blessed($self) && $self->isa($CLASS))) {
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

  if ( ! open $fh, '>', $filename ) {
    REX::File::Create->throw(message => 'Could not create file', filepath => $filename);
  }
  print {$fh} $self->to_string();
  close $fh;

  return 1;
}

1;

__END__

=head1 NAME

Rsync::Config

=head1 VERSION

0.2

=head1 DESCRIPTION

Rsync::Config is a module who can be used to create rsync configuration files.
A configuration file (from Rsync::Config point of view) is made by atoms and
modules with atoms. A atom is the smallest piece from the configuration file.
This module inherits from B<Rsync::Config::Module> .

=head1 INHERITANCE

Objects from Rsync::Config inherits as in the next scheme

                         /--- Rsync::Config::Atom
 Rsync::Config::Renderer 
                         \--- Rsync::Config::Module --- Rsync::Config


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

=head2 add_module($module)

Adds the $module (a instance of Rsync::Config::Module) to the list of modules.
If $module is not defined B<REX::Param::Missing> exception is throwned. If
$module is not a instance of B<Rsync::Config::Module>, B<REX::Param::Invalid>
exception is throwned.

=head2 modules_no()

Returns the number of modules

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

=over 4

=item English

=item Scalar::Util

=item CLASS

=item Rsync::Config::Module

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
