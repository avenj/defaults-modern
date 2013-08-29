package Defaults::Modern;
use v5.14;

use strict; use warnings FATAL => 'all';

no bareword::filehandles;
no indirect ':fatal';

use Carp    ();
use feature ();
use true    ();

use match::simple ();

use Defaults::Modern::Define  ();
use Function::Parameters      ();
use List::Objects::WithUtils  ();
use Path::Tiny                ();
use PerlX::Maybe              ();
use Try::Tiny                 ();
use Scalar::Util              ();


use Types::Standard           ();
use Types::Path::Tiny         ();
use Type::Registry            ();
use Type::Utils               ();
use List::Objects::Types      ();


use Import::Into;

sub import {
  my ($class, @imports) = @_;

  state $known = +{ 
    map {; $_ => 1 } qw/
      all
      autobox_lists 
      moo
    /
  };

  my %params = map {; 
    my $opt = lc($_ =~ s/^://r);
    Carp::croak "$class does not export $opt" 
      unless $known->{$opt};
    $opt => 1
  } @imports;

  if (delete $params{all}) {
    $params{$_} = 1 for grep {; $_ ne 'all' } keys %$known
  }

  my $pkg = caller;

  # Us
  Defaults::Modern::Define->import::into($pkg);

  # Core
  Carp->import::into($pkg,
    qw/carp croak confess/,
  );

  Scalar::Util->import::into($pkg,
    qw/blessed reftype weaken/,
  );
  
  # Pragmas
  strict->import;
  warnings->import(FATAL => 'all');
  warnings->unimport('once');

  bareword::filehandles->unimport;
  indirect->unimport(':fatal');

  feature->import(':5.14');
  feature->unimport('switch');

  match::simple->import::into($pkg);
  true->import;

  # External functionality

  state $reify = sub {
    state $guard = do { require Type::Utils };
    Type::Utils::dwim_type($_[0], for => $_[1])
  };

  state $fp_defaults = +{
    default_arguments     => 1,
    check_argument_count  => 1,
    named_parameters      => 1,
    types                 => 1,
    reify_type            => $reify,
  };

  Function::Parameters->import::into( $pkg,
    +{
      fun => {
        name                  => 'optional',
        %$fp_defaults
      },
      method => {
        name                  => 'required',
        attrs                 => ':method',
        shift                 => '$self',
        invocant              => 1,
        %$fp_defaults
      }
    }
  );

  Path::Tiny->import::into($pkg, 'path');
  PerlX::Maybe->import::into($pkg, qw/maybe provided/);
  Try::Tiny->import::into($pkg);

  my @lowu = qw/array hash immarray/;
  push @lowu, 'autobox' if defined $params{autobox_lists};
  List::Objects::WithUtils->import::into($pkg, @lowu);

  # Types
  Types::Standard->import::into($pkg, '-all');
  List::Objects::Types->import::into($pkg, '-all');
  Types::Path::Tiny->import::into($pkg, '-all');

  Type::Registry->for_class($pkg)->add_types($_) for qw/
    Types::Standard
    Types::Path::Tiny
    List::Objects::Types
  /;

  if (defined $params{moo}) {
    require Moo;
    Moo->import::into($pkg);
    require MooX::late;
    MooX::late->import::into($pkg);
  }

  $class
}

1;

=pod

=head1 NAME

Defaults::Modern - Yet another approach to modernistic Perl

=head1 SYNOPSIS

  use Defaults::Modern;

  # Function::Parameters + List::Objects::WithUtils + types ->
  fun to_immutable ( (ArrayRef | ArrayObj) $arr ) {
    # blessed() and confess() are available (amongst others):
    my $immutable = immarray( blessed $arr ? $arr->all : @$arr );
    confess "No items in array!" unless $immutable->has_any;
    $immutable
  }

  package My::Foo {
    use Defaults::Modern;

    # define keyword for defining constants ->
    define ARRAY_MAX = 10;

    # Moo(se) with types ->
    use Moo;
    use MooX::late;

    has myarray => (
      isa => ArrayObj,
      is  => 'ro',
      writer  => '_set_myarray',
      # MooX::late allows us to coerce from an ArrayRef:
      coerce  => 1,
      default => sub { [] },
    );

    # Method with optional positional param and implicit $self ->
    method slice_to_max (Int $max = -1) {
      my $arr = $self->myarray;
      $self->_set_myarray( 
        $arr->sliced( 0 .. $max >= 0 ? $max : ARRAY_MAX )
      )
    }
  }

  # Optionally autobox list-type refs via List::Objects::WithUtils ->
  use Defaults::Modern 'autobox_lists';
  my $obj = +{ foo => 'bar', baz => 'quux' }->inflate;
  my $baz = $obj->baz;

  # See DESCRIPTION for complete details on imported functionality.

=head1 DESCRIPTION

Yet another approach to writing Perl in a modern style.

. . . also saves me extensive typing ;-)

When you C<use Defaults::Modern>, you get:

=over

=item *

L<strict> and fatal L<warnings> except for C<once>; additionally disallow
L<bareword::filehandles> and L<indirect> method calls

=item *

The C<v5.14> feature set (C<state>, C<say>, C<unicode_strings>, C<array_base>) -- except for
C<switch>, which is deprecated in newer perls

=item *

B<carp>, B<croak>, and B<confess> error reporting tools from L<Carp>

=item *

B<blessed>, B<reftype>, and B<weaken> utilities from L<Scalar::Util>

=item *

B<array>, B<immarray>, and B<hash> object constructors from
L<List::Objects::WithUtils>

=item *

B<fun> and B<method> keywords from L<Function::Parameters>

=item *

The full L<Types::Standard> set and L<List::Objects::Types>, which are useful
in combination with L<Function::Parameters> (see the L</SYNOPSIS> and
L<Function::Parameters> POD)

=item *

B<try> and B<catch> from L<Try::Tiny>

=item *

The B<path> object constructor from L<Path::Tiny> and related types/coercions
from L<Types::Path::Tiny>

=item *

B<maybe> and B<provided> definedness-checking syntax sugar from L<PerlX::Maybe>

=item *

A B<define> keyword for defining constants based on L<PerlX::Define>

=item *

The C<|M|> match operator from L<match::simple>

=item *

L<true>.pm so you can skip adding '1;' to all of your modules

=back

If you import the tag C<autobox_lists>, ARRAY and HASH type references are autoboxed
via L<List::Objects::WithUtils>:

  use Defaults::Modern 'autobox_lists';
  my $itr = [ 1 .. 10 ]->natatime(2);

L<Moo> and L<MooX::late> are depended upon in order to guarantee their
availability, but not automatically imported:

  use Moo;
  use MooX::late;
  use Defaults::Modern;

  has foo => (
    is  => 'ro',
    isa => ArrayObj,
    coerce  => 1,
    default => sub { [] },
  );

=begin comment

 ## Undocumented for now, because Moops is a better solution.

If you import C<Moo>, you get L<Moo> and L<MooX::late> (but you should really
be using L<Moops> instead):

  use Defaults::Modern 'Moo';
  has foo => (
    is      => 'ro',
    isa     => ArrayObj,
    coerce  => 1,
    default => sub { [] },
  );

=end comment

Uses L<Import::Into> to provide B<import>; see the L<Import::Into>
documentation for details.

=head1 SEE ALSO

This package just glues together useful parts of CPAN, the
most visible portions of which come from the following modules:

L<Carp>

L<Function::Parameters>

L<List::Objects::WithUtils>

L<List::Objects::Types>

L<Path::Tiny>

L<PerlX::Maybe>

L<Scalar::Util>

L<Try::Tiny>

L<Types::Standard>

L<Type::Tiny>

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

Licensed under the same terms as Perl.

Inspired by L<Defaults::Mauke> and L<Moops>.

The code backing the B<define> keyword is forked from TOBYINK's
L<PerlX::Define> to avoid the L<Moops> dependency and is copyright Toby
Inkster.

=cut

# vim: ts=2 sw=2 et sts=2 ft=perl
