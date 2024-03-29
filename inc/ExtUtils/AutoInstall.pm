# $File: //member/autrijus/ExtUtils-AutoInstall/AutoInstall.pm $ 
# $Revision: #11 $ $Change: 1502 $ $DateTime: 2002/10/17 20:21:45 $

package ExtUtils::AutoInstall;
$ExtUtils::AutoInstall::VERSION = '0.42';

use strict;

use Cwd;
use ExtUtils::MakeMaker ();

=head1 NAME

ExtUtils::AutoInstall - Automatic install of dependencies via CPAN

=head1 VERSION

This document describes version 0.42 of B<ExtUtils::AutoInstall>,
released October 18, 2002.

=head1 SYNOPSIS

In F<Makefile.PL>:

    # ExtUtils::AutoInstall Bootstrap Code, version 4.
    BEGIN{my$p='ExtUtils::AutoInstall';my$v=.30;eval"use $p $v;1"or
    ($ENV{PERL_EXTUTILS_AUTOINSTALL}!~/--(?:default|skip|testonly)/
    and(-t STDIN)or eval"use ExtUtils::MakeMaker;WriteMakefile('PR'
    .'EREQ_PM'=>{'$p',$v});1"and exit)and print"==> $p $v needed. "
    ."Install it from CPAN? [Y/n] "and<STDIN>!~/^n/i and print"***"
    ." Fetching $p\n"and do{eval{require CPANPLUS;CPANPLUS::install
    $p};eval"use $p $v;1"or eval{require CPAN;CPAN::install$p};eval
    "use $p $v;1"or die"Please install $p $v manually first...\n"}}

    # pre-install handler; takes $module_name and $version
    sub MY::preinstall  { return 1; }	# return false to skip install
    # post-install handler; takes $module_name, $version, and $success
    sub MY::postinstall { ... }

    # the above handlers must be declared before the 'use' statement
    use ExtUtils::AutoInstall (
	-version	=> '0.40',	# required AutoInstall version
	                                # usually 0.30 is sufficient
	-config		=> {
	    make_args	=> '--hello'	# option(s) for CPAN::Config 
	    force	=> 1,		# pseudo-option to force install
	},
	-core		=> [		# core modules; may also be 'all'
	    Package0	=> '',		# any version would do
	],
	'Feature1'	=> [
	    # do we want to install this feature by default?
	    -default	=> ( system('feature1 --version') == 0 ),
	    Package1	=> '0.01',
	],
	'Feature2'	=> [
	    # associate tests to be disabled if this feature is missing
	    -tests	=> [ <t/feature2*.t> ],
	    # associate tests to be disabled if this feature is present
	    -skiptests	=> [ <t/nofeature2*.t> ],
	    Package2	=> '0.02',
	],
	'Feature3'	=> {		# hash reference works, too
	    # force installation even if tests fail
	    Package3	=> '0.03',
	}
    );

    WriteMakefile(
	AUTHOR          => 'Joe Hacker (joe@hacker.org)',
	ABSTRACT        => 'Perl Interface to Joe Hacker',
	NAME            => 'Joe::Hacker',
	VERSION_FROM    => 'Hacker.pm',
	DISTNAME        => 'Joe-Hacker',
    );

Invoking the resulting F<Makefile.PL>:

    % perl Makefile.PL			# interactive behaviour
    % perl Makefile.PL --defaultdeps	# accept default value on prompts
    % perl Makefile.PL --checkdeps	# check only, no Makefile produced
    % perl Makefile.PL --skipdeps	# ignores all dependencies
    % perl Makefile.PL --testonly	# don't write installation targets

Note that the trailing 'deps' of arguments may be omitted, too.

Using F<make> (or F<nmake>):

    % make [all|test|install]		# install dependencies first
    % make checkdeps			# same as the --checkdeps above
    % make installdeps			# install dependencies only

=head1 DESCRIPTION

B<ExtUtils::AutoInstall> lets module writers to specify a more
sophisticated form of dependency information than the C<PREREQ_PM>
option offered by B<ExtUtils::MakeMaker>.

=head2 Prerequisites and Features

Prerequisites are grouped into B<features>, and the user could choose
yes/no on each one's dependencies; the module writer may also supply a
boolean value via C<-default> to specify the default choice.

The B<Core Features> marked by the name C<-core> will double-check with
the user, if the user chooses not to install the modules that belongs to
it.  This differs with the pre-0.26 'silent install' behaviour.

Starting from version 0.27, if C<-core> is set to the string C<all>
(case-insensitive), every features will be considered mandatory.

The dependencies are expressed as pairs of C<Module> => C<version>
inside an a array reference.  If the order does not matter, and there
are no C<-default>, C<-tests> or C<-skiptests> directives for that
feature, you may also use a hash reference.

=head2 The Installation Process

Once B<ExtUtils::AutoInstall> has determined which module(s) are needed,
it checks whether it's running under the B<CPAN> shell and should
therefore let B<CPAN> handle the dependency.

Finally, the C<WriteMakefile()> is overridden to perform some additional
checks, as well as skips tests associated with disabled features by the
C<-tests> option.

The actual installation happens at the end of the C<make config> target;
both C<make test> and C<make install> will trigger the installation of
required modules.

If it's not running under B<CPAN>, the installer will probe for an
active connection by trying to resolve the domain C<cpan.org>, and check
for the user's permission to use B<CPAN>.  If all went well, a separate
    B<CPAN> instance is created to install the required modules.

If you have the B<CPANPLUS> package installed in your system, it is
preferred by default over B<CPAN>; it also accepts some extra options
(e.g. C<-target =E<gt> 'skiptest', -skiptest =E<gt> 1> to skip testing).

All modules scheduled to install will be deleted from C<%INC> first, so
B<ExtUtils::MakeMaker> will check the newly installed modules.

Additionally, you could use the C<make installdeps> target to install
the modules, and the C<make checkdeps> target to check dependencies
without actually installing them; the C<perl Makefile.PL --checkdeps>
command has an equivalent effect.

=head2 User-Defined Hooks

Starting from version 0.40, user-defined I<pre-installation> and
I<post-installation> hooks are available via C<MY::preinstall> and
C<MY::postinstall> subroutines.

Note that since B<ExtUtils::AutoInstall> performs installation at the
time of C<use> (i.e. before perl parses the remainder of
F<Makefile.PL>), you have to declare those two handlers I<before> the
C<use> statement for them to take effect.

If the user did not choose to install a module or it already exists on
the system, neither handlers are invoked.  Both handlers are invoked
exactly once for each module's attempted installation.

C<MY::preinstall> takes two arguments, C<$module_name> and C<$version>;
if it returns a false value, installation for that module will be
    skipped, and C<MY::postinstall> won't be called at all.

C<MY::postinstall> takes three arguments, C<$module_name>, C<$version>
and C<$success>.  The last one denotes whether the installation
succeeded or not: C<1> means installation completed successfully, C<0>
means failure during install, and C<undef> means that the installation
was not attempted at all, possibly due to connection problems, or that
module does not exist on CPAN at all.

=head1 CAVEATS

B<ExtUtils::AutoInstall> will add C<UNINST=1> to your B<make install>
flags if your effective uid is 0 (root), unless you explicitly disable
it by setting B<CPAN>'s C<make_install_arg> configuration option (or the
C<makeflags> option of B<CPANPLUS>) to include C<UNINST=0>.  This I<may>
cause dependency problems if you are using a fine-tuned directory
structure for your site.  Please consult L<CPAN/FAQ> for an explanation
in detail.

If either B<version> or B<Sort::Versions> is available, they will be
used to compare the required version with the existing module's version
and the CPAN module's.  Otherwise it silently falls back to use I<cmp>.
This may cause inconsistent behaviours in pathetic situations.

B<Inline::MakeMaker> is not happy with this module, since it prohibits
competing C<MY::postamble> functions.  Patches welcome.

=head1 NOTES

Since this module is needed before writing F<Makefile>, it makes little
use as a CPAN module; hence each distribution must include it in full.
The only alternative I'm aware of, namely prompting in F<Makefile.PL> to
force user install it (cf. the B<Template Toolkit>'s dependency on
B<AppConfig>) is not very desirable either.

The current compromise is to add the bootstrap code listed in the
L</SYNOPSIS> before every script, but that does not look pretty, and
will not work without an internet connection.

Since we do not want all future options of B<ExtUtils::AutoInstall> to
be painfully detected manually like above, this module provides a
I<bootstrapping> mechanism via the C<-version> flag.  If a newer version
is needed by the F<Makefile.PL>, it will go ahead to fetch a new
version, reload it into memory, and pass the arguments forward.

If you have any suggestions, please let me know.  Thanks.

=head1 ENVIRONMENT

B<ExtUtils::AutoInstall> uses a single environment variable,
C<PERL_EXTUTILS_AUTOINSTALL>.  It is taken as the command line argument
passed to F<Makefile.PL>; you could set it to either C<--defaultdeps> or
C<--skipdeps> to avoid interactive behaviour.

=cut

# special map on pre-defined feature sets
my %FeatureMap = (
    ''	    => 'Core Features', # XXX: deprecated
    '-core' => 'Core Features',
);

# various lexical flags
my (@Missing, @Existing, %DisabledTests, $UnderCPAN, $HasCPANPLUS);
my ($Config, $CheckOnly, $SkipInstall, $AcceptDefault, $TestOnly); 

$AcceptDefault = 1 unless -t STDIN; # non-interactive session
_init();

sub missing_modules {
    return @Missing;
}

sub do_install {
    __PACKAGE__->install(
	[ UNIVERSAL::isa($Config, 'HASH') ? %{$Config} : @{$Config}],
	@Missing,
    );
}

# initialize various flags, and/or perform install
sub _init {
    foreach my $arg (@ARGV, split(/[\s\t]+/, $ENV{PERL_EXTUTILS_AUTOINSTALL} || '')) {
	if ($arg =~ /^--config=(.*)$/) {
	    $Config = [ split(',', $1) ];
	}
	elsif ($arg =~ /^--installdeps=(.*)$/) {
	    __PACKAGE__->install($Config, split(',', $1));
	    exit 0;
	}
	elsif ($arg =~ /^--default(?:deps)?$/) {
	    $AcceptDefault = 1;
	}
	elsif ($arg =~ /^--check(?:deps)?$/) {
	    $CheckOnly = 1;
	}
	elsif ($arg =~ /^--skip(?:deps)?$/) {
	    $SkipInstall = 1;
	}
	elsif ($arg =~ /^--test(?:only)?$/) {
	    $TestOnly = 1;
	}
    }
}

# overrides MakeMaker's prompt() to automatically accept the default choice
sub _prompt {
    goto &ExtUtils::MakeMaker::prompt unless $AcceptDefault;

    my ($prompt, $default) = @_;
    my $y = ($default =~ /^[Yy]/);

    print $prompt, ' [', ($y ? 'Y' : 'y'), '/', ($y ? 'n' : 'N'), '] ';
    print "$default\n";
    return $default;
}

# the workhorse
sub import {
    my $class = shift;
    my @args  = @_ or return;
    my $core_all;

    print "*** $class version ".$class->VERSION."\n";
    print "*** Checking for dependencies...\n";

    my $cwd = Cwd::cwd();

    $Config  = [];

    my $maxlen = length((sort { length($b) <=> length($a) }
	grep { /^[^\-]/ }
        map { ref($_) ? keys %{ref($_) eq 'HASH' ? $_ : +{@{$_}}} : '' }
	map { +{@args}->{$_} }
	grep { /^[^\-]/ or /^-core$/i } keys %{+{@args}})[0]);

    while (my ($feature, $modules) = splice(@args, 0, 2)) {
	my (@required, @tests, @skiptests);
	my $default = 1;

	if ($feature =~ m/^-(\w+)$/) {
	    my $option = lc($1);

	    # check for a newer version of myself
	    _update_to($modules, @_) and return	if $option eq 'version';

	    # sets CPAN configuration options
	    $Config = $modules			if $option eq 'config';

	    # promote every features to core status
	    $core_all = ($modules =~ /^all$/i) and next
		if $option eq 'core';

	    next unless $option eq 'core';
	}

	print "[".($FeatureMap{lc($feature)} || $feature)."]\n";

	$modules = [ %{$modules} ] if UNIVERSAL::isa($modules, 'HASH');

	unshift @$modules, -default => &{shift(@$modules)}
	    if (ref($modules->[0]) eq 'CODE'); # XXX: bugward combatability

	while (my ($mod, $arg) = splice(@$modules, 0, 2)) {
	    if ($mod =~ m/^-(\w+)$/) {
		my $option = lc($1);

		$default   = $arg    if ($option eq 'default');
		@tests     = @{$arg} if ($option eq 'tests');
		@skiptests = @{$arg} if ($option eq 'skiptests');

		next;
	    }

	    printf("- %-${maxlen}s ...", $mod);

	    if (defined(my $cur = _version_check(_load($mod), $arg ||= 0))) {
		print "loaded. ($cur".($arg ? " >= $arg" : '').")\n";
		push @Existing, $mod => $arg;
		$DisabledTests{$_} = 1 for map { glob($_) } @skiptests;
	    }
	    else {
		print "failed! (need".($arg ? "s $arg" : 'ed').")\n";
		push @required, $mod => $arg;
	    }
	}

	next unless @required;

	my $mandatory = (($feature eq '-core' or $core_all) and $default);

	if (!$SkipInstall and ($CheckOnly or _prompt(
	    qq{==> Do you wish to install the }. (@required / 2).
	    ($mandatory ? ' mandatory' : ' optional').
	    qq{ module(s)?}, $default ? 'y' : 'n',
	) =~ /^[Yy]/)) {
	    push (@Missing, @required);
	    $DisabledTests{$_} = 1 for map { glob($_) } @skiptests;
	}

	elsif (!$SkipInstall and $mandatory and _prompt(
	    qq{==> The module(s) are mandatory! Really skip?}, 'n',
	) =~ /^[Nn]/) {
	    push (@Missing, @required);
	    $DisabledTests{$_} = 1 for map { glob($_) } @skiptests;
	}

	else {
	    $DisabledTests{$_} = 1 for map { glob($_) } @tests;
	}
    }

    _check_lock(); # check for $UnderCPAN

    print "*** Dependencies will be installed the next time you type 'make'.\n"
	if (@Missing and not ($CheckOnly or $UnderCPAN));
    print "*** $class configuration finished.\n";

    chdir $cwd;

    # import to main::
    no strict 'refs'; 
    *{'main::WriteMakefile'} = \&Write;
}

# CPAN.pm is non-reentrant, so check if we're under it and have no CPANPLUS
sub _check_lock {
    return unless @Missing;
    return if _has_cpanplus();

    require CPAN; CPAN::Config->load;
    my $lock = MM->catfile($CPAN::Config->{cpan_home}, ".lock");

    if (-f $lock and open(LOCK, $lock)
	and ($^O eq 'MSWin32' ? _under_cpan() : <LOCK> == getppid())
	and ($CPAN::Config->{prerequisites_policy} || '') ne 'ignore'
    ) {
	print << '.';

*** Since we're running under CPAN, I'll just let it take care
    of the dependency's installation later.
.
	$UnderCPAN = 1;
    }

    close LOCK;
}

sub install {
    my $class  = shift;

    my $i; # used below to strip leading '-' from config keys
    my @config = (map { s/^-// if ++$i; $_ } @{+shift});

    my @modules;
    my $installed = 0;
    while (my ($pkg, $ver) = splice(@_, 0, 2)) {
	# grep out those already installed
	($installed++, next)
	    if defined(_version_check(_load($pkg), $ver));
	push @modules, $pkg, $ver;
    }

    return $installed unless @modules; # nothing to do

    print "*** Installing dependencies...\n";

    return unless _connected_to('cpan.org');

    if (_has_cpanplus()) {
	$installed += _install_cpanplus(\@modules, \@config);
    }
    else {
	$installed += _install_cpan(\@modules, \@config);
    }

    print "*** $class installation finished.\n";

    return $installed;
}

sub _install_cpanplus {
    my @modules = @{+shift};
    my @config  = @{+shift};
    my $installed = 0;

    require CPANPLUS::Backend;
    my $cp   = CPANPLUS::Backend->new;
    my $conf = $cp->configure_object;

    return unless _can_write($conf->_get_build('base'));

    # if we're root, set UNINST=1 to avoid trouble unless user asked for it.
    my $makeflags = $conf->get_conf('makeflags') || '';
    if (UNIVERSAL::isa($makeflags, 'HASH')) {
	# 0.03+ uses a hashref here
	$makeflags->{UNINST} = 1 unless exists $makeflags->{UNINST};
    }
    else {
	# 0.02 and below uses a scalar
	$makeflags = join(' ', split(' ', $makeflags), 'UNINST=1')
	    if ($makeflags !~ /\bUNINST\b/ and eval qq{ $> eq '0' });
    }
    $conf->set_conf(makeflags => $makeflags);

    my $modtree = $cp->module_tree;
    while (my ($pkg, $ver) = splice(@modules, 0, 2)) {
	print "*** Installing $pkg...\n";

	MY::preinstall($pkg, $ver) or next if defined &MY::preinstall;

	my $success;
	my $obj = $modtree->{$pkg};

	if ($obj and defined(_version_check($obj->{version}, $ver))) {
	    my $pathname = $pkg; $pathname =~ s/::/\\W/;

	    foreach my $inc (grep { m/$pathname.pm/i } keys(%INC)) {
		delete $INC{$inc};
	    }

	    my $rv = $cp->install( modules => [ $obj->{module} ], @config);

	    if ($rv and ($rv->{$obj->{module}} or $rv->{ok})) {
		print "*** $pkg successfully installed.\n";
		$success = 1;
	    }
	    else {
		print "*** $pkg installation cancelled.\n";
		$success = 0;
	    }

	    $installed += $success;
	}
	else {
	    print << ".";
*** Could not find a version $ver or above for $pkg; skipping.
.
	}

	MY::postinstall($pkg, $ver, $success) if defined &MY::postinstall;
    }

    return $installed;
}

sub _install_cpan {
    my @modules = @{+shift};
    my @config  = @{+shift};
    my $installed = 0;
    my %args;

    return unless _can_write(MM->catfile($CPAN::Config->{cpan_home}, 'sources'));

    # if we're root, set UNINST=1 to avoid trouble unless user asked for it.
    my $makeflags = $CPAN::Config->{make_install_arg} || '';
    $CPAN::Config->{make_install_arg} = join(' ', split(' ', $makeflags), 'UNINST=1')
	if ($makeflags !~ /\bUNINST\b/ and eval qq{ $> eq '0' });

    # don't show start-up info
    $CPAN::Config->{inhibit_startup_message} = 1;

    # set additional options
    while (my ($opt, $arg) = splice(@config, 0, 2)) {
	($args{$opt} = $arg, next)
	    if $opt =~ /^force$/; # pseudo-option
	$CPAN::Config->{$opt} = $arg;
    }

    require CPAN; CPAN::Config->load;

    while (my ($pkg, $ver) = splice(@modules, 0, 2)) {
	MY::preinstall($pkg, $ver) or next if defined &MY::preinstall;

	print "*** Installing $pkg...\n";

	my $obj = CPAN::Shell->expand(Module => $pkg);
	my $success = 0;

	if ($obj and defined(_version_check($obj->cpan_version, $ver))) {
	    my $pathname = $pkg; $pathname =~ s/::/\\W/;

	    foreach my $inc (grep { m/$pathname.pm/i } keys(%INC)) {
		delete $INC{$inc};
	    }

	    $obj->force('install') if $args{force};

	    if ($obj->install eq 'YES') {
		print "*** $pkg successfully installed.\n";
		$success = 1;
	    }
	    else {
		print "*** $pkg installation failed.\n";
		$success = 0;
	    }

	    $installed += $success;
	}
	else {
	    print << ".";
*** Could not find a version $ver or above for $pkg; skipping.
.
	}

	MY::postinstall($pkg, $ver, $success) if defined &MY::postinstall;
    }

    return $installed;
}

sub _has_cpanplus {
    return (
	$HasCPANPLUS = (
	    $INC{'CPANPLUS/Config.pm'} or
	    _load('CPANPLUS::Shell::Default')
	)
    );
}

# make guesses on whether we're under the CPAN installation directory
sub _under_cpan {
    require Cwd;
    require File::Spec;

    my $cwd  = File::Spec->canonpath(Cwd::cwd());
    my $cpan = File::Spec->canonpath($CPAN::Config->{cpan_home});
    
    return (index($cwd, $cpan) > -1);
}

sub _update_to {
    my $class = __PACKAGE__;
    my $ver   = shift;

    return if defined(_version_check(_load($class), $ver)); # no need to upgrade

    if (_prompt(
	"==> A newer version of $class ($ver) is required. Install?", 'y'
    ) =~ /^[Nn]/) {
	die "*** Please install $class $ver manually.\n";
    }

    print << ".";
*** Trying to fetch it from CPAN...
.

    # install ourselves
    _load($class) and return $class->import(@_)
	if $class->install([], $class, $ver);

    print << '.'; exit 1;

*** Cannot bootstrap myself. :-( Installation terminated.
.
}

# check if we're connected to some host, using inet_aton
sub _connected_to {
    my $site = shift;

    return (
	( _load('Socket') and Socket::inet_aton($site) ) or _prompt(qq(
*** Your host cannot resolve the domain name '$site', which
    probably means the Internet connections are unavailable.
==> Should we try to install the required module(s) anyway?), 'n'
	) =~ /^[Yy]/
    );
}

# check if a directory is writable; may create it on demand
sub _can_write {
    my $path = shift;
    mkdir ($path, 0755) unless -e $path;

    return (
	-w $path or _prompt(qq(
*** You are not allowed to write to the directory '$path';
    the installation may fail due to insufficient permissions.
==> Should we try to install the required module(s) anyway?), 'n'
	) =~ /^[Yy]/
    );
}

# load a module and return the version it reports
sub _load {
    my $mod = pop; # class/instance doesn't matter
    my $file = $mod;

    $file =~ s|::|/|g;
    $file .= '.pm';

    local $@;
    return eval { require $file; $mod->VERSION } || ($@ ? undef : 0);
}

# compare two versions, either use Sort::Versions or plain comparison
sub _version_check {
    my ($cur, $min) = @_;
    return unless defined $cur;

    $cur =~ s/\s+$//;

    # check for version numbers that are not in decimal format
    if (ref($cur) or ref($min) or $cur =~ /v|\..*\./ or $min =~ /v|\..*\./) {
	if ($version::VERSION or defined(_load('version'))) {
	    # use version.pm if it is installed.
	    return ((version->new($cur) >= version->new($min)) ? $cur : undef);
	}
	elsif ($Sort::Versions::VERSION or defined(_load('Sort::Versions'))) {
	    # use Sort::Versions as the sorting algorithm for a.b.c versions
	    return ((Sort::Versions::versioncmp($cur, $min) != -1) ? $cur : undef);
	}

	warn "Cannot reliably compare non-decimal formatted versions.\n".
	     "Please install version.pm or Sort::Versions.\n";
    }

    # plain comparison
    local $^W = 0; # shuts off 'not numeric' bugs
    return ($cur >= $min ? $cur : undef);
}

# nothing; this usage is deprecated.
sub main::PREREQ_PM { return {}; }

# a wrapper to ExtUtils::MakeMaker::WriteMakefile
sub Write {
    require Carp;
    Carp::croak "WriteMakefile: Need even number of args" if @_ % 2;

    if ($CheckOnly) {
	print << ".";
*** Makefile not written in check-only mode.
.
	return;
    }


    my %args = @_;

    $args{PREREQ_PM} = { %{$args{PREREQ_PM} || {} }, @Existing, @Missing }
	if $UnderCPAN or $TestOnly;

    if ($args{EXE_FILES}) {
	require ExtUtils::Manifest;
	my $manifest = ExtUtils::Manifest::maniread('MANIFEST');

	$args{EXE_FILES} = [ 
	    grep { exists $manifest->{$_} } @{$args{EXE_FILES}} 
	];
    }

    $args{test}{TESTS} ||= 't/*.t';
    $args{test}{TESTS} = join(' ', grep {
	!exists($DisabledTests{$_}) 
    } map { glob($_) } split(/\s+/, $args{test}{TESTS}));

    my $missing = join(',', @Missing);
    my $config  = join(',',
	UNIVERSAL::isa($Config, 'HASH') ? %{$Config} : @{$Config}
    ) if $Config;

    my $action = (
	$missing ? "\$(PERL) $0 --config=$config --installdeps=$missing"
		 : "\$(NOOP)"
    );

    no strict 'refs';

    my $old_postamble = defined(&MY::postamble) ? \&MY::postamble : sub { '' };

    *{'MY::postamble'} = sub {
	return &{$old_postamble} . << ".";

config :: installdeps

checkdeps ::
	\$(PERL) $0 --checkdeps

installdeps ::
	$action
.
    } unless $TestOnly;

    ExtUtils::MakeMaker::WriteMakefile(%args);

    return 1;
}

1;

__END__

=head1 SEE ALSO

L<perlmodlib>, L<ExtUtils::MakeMaker>, L<Sort::Versions>, L<CPAN>,
L<CPANPLUS>

=head1 ACKNOWLEDGEMENTS

The test script included in the B<ExtUtils::AutoInstall> distribution
contains code adapted from Michael Schwern's B<Test::More> under the
I<Artistic License>.  Please refer to F<t/AutoInstall.t> for details.

Thanks also to Jesse Vincent for suggesting the semantics of various
F<make> targets, and Jos IBoumans for introducing me to his B<CPANPLUS>
project.

Eric Andreychek contributed to the C<-force> pseudo-option feature;
Brian Ingerson suggested the non-intrusive handling of C<-core> and
bootstrap installations, and let the user have total control.

Bryan Dumm suggested the pre-/post-install handler features which
makes up the 0.40 release.

Rocco Caputo made me write compatibility code for F<cpansmoke> and
other non-tty STDIN type installations.  Matt Cashner suggested the
C<-skiptest> semantic and caught a subtle bug involving C<require>
instead of C<use> of AutoInstall.  Chia-Liang Kao spotted the
incompatibility between the use of C<$0> and CPANPLUS's C<eval()>
munging.  Thanks!

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2001, 2002 by Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
