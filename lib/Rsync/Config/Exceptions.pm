package Rsync::Config::Exceptions;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION='0.1';

use Exception::Class (

  'REX::General' => {
    description => 'General pourpose exception',
  },


  # File related exceptions

  'REX::File' => {
    description => 'File related exceptions',
    fields      => [ 'filepath' ],
  },

  'REX::File::NotFound' => {
    description => 'File was not found on the filesystem',
    isa         => 'REX::File',
  },

  'REX::File::Create' => {
    description => 'Create file exception',
    isa         => 'REX::File',
  },

  'REX::File::Open' => {
    description => 'Could not open file',
    isa         => 'REX::File',
  },

  # Object exceptions
  'REX::OutsideClass' => {
    description => 'method was called outside class instance',
  },

  # Parameters exceptions
  'REX::Param' => {
    description => 'General parameter exception',
    fields      => [ 'pname' ],
  },

  'REX::Param::Missing' => {
    description => 'Parameter missing',
    isa         => 'REX::Param',
  },
  'REX::Param::Undef' => {
    description => 'Undefined values used',
    isa         => 'REX::Param',
  },
  'REX::Param::Invalid' => {
    description => 'parameter has invalid value',
    isa         => 'REX::Param',
  },

);

1;

__END__

=head1 NAME

Rsync::Config::Exceptions

=head1 VERSION

0.1

=head1 DESCRIPTION

Exceptions used by Rsync::Config modules

=head1 SYNOPSIS

 use Rsync::Config::Exceptions;

 REX::OutsideClass->throw(message => 'Called outside class instance');

=head1 SUBROUTINES/METHODS

There are no subroutines or methods.

=head1 EXCEPTIONS TREE

=head2 REX::General

General pourpose exception.

=head2 REX::OutsideClass

Exception throwned when methods are called outside the class instance.

=head2 REX::File

File related exception. This exception allows one parameter
to be set when exception is throwned: B<filepath>

=head3 REX::File::NotFound

File was not found in the filesystem

=head3 REX::File::Create

The file could not be created

=head3 REX::File::Open

The file could not be opened

=head2 REX::Param

Parameter related exception. This exception allows one parameter
to be set when exception is throwned: B<pname>

=head3 REX::Param::Missing

The specified parameter was not found in the parameters list

=head3 REX::Param::Undef

Parameter has undefined value

=head3 REX::Param::Invalid

The specified parameter does not have the expected value. The most
common cases are: value is 0, value is not a array ref (or a hash ref).

=head1 DIAGNOSTICS

All tests are located in the t directory.

=head1 CONFIGURATION AND ENVIRONMENT

This module does not use any configuration files or environment
variables. The used modules however may use such things. Please
refer to each module man page for more information.

=head1 DEPENDENCIES

This modules depends on the Exception::Class module.

=head1 INCOMPATIBILITIES

None known to the author

=head1 BUGS AND LIMITATIONS

None known to the author

=head1 AUTHOR

Subredu Manuel <diablo@packages.ro>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2006 Subredu Manuel.  All Rights Reserved.
This module is free software; you can redistribute it 
and/or modify it under the same terms as Perl itself.
