package Defaults::Modern;
use v5.14;
use strict; use warnings FATAL => 'all';
no bareword::filehandles;

use Carp;
use Scalar::Util ();
use feature ();
use true    ();

use Function::Parameters ();
use Path::Tiny           ();
use Try::Tiny            ();
use Types::Standard      ();

use PerlX::Maybe         ();

use List::Objects::Types ();
use List::Objects::WithUtils ();

use Defaults::Modern::Define ();

use Import::Into;

sub import {
  my (undef, @imports) = @_;
  my $pkg = caller;

  my %params = map {; $_ => 1 } @imports;

  Defaults::Modern::Define->import::into($pkg);

  Carp->import::into($pkg,
    qw/carp croak confess/,
  );

  Scalar::Util->import::into($pkg,
    qw/blessed reftype weaken/,
  );
  
  strict->import;
  warnings->import(FATAL => 'all');
  warnings->unimport('once');
  bareword::filehandles->unimport;

  feature->import(':5.14');
  feature->unimport('switch');

  true->import;

  Function::Parameters->import::into($pkg);
  Path::Tiny->import::into($pkg, 'path');
  Try::Tiny->import::into($pkg);

  PerlX::Maybe->import::into($pkg, qw/maybe provided/);

  my @lowu = qw/array hash immarray/;
  push @lowu, 'autobox' 
    if defined $params{autobox_lists}
    or defined $params{autoboxed_lists};
  List::Objects::WithUtils->import::into($pkg, @lowu);

  List::Objects::Types->import::into($pkg, '-all');
  Types::Standard->import::into($pkg, '-types');

  1
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

  # define keyword for defining constants ->
  define ARRAY_MAX = 10;
  fun slice_to_max ( ArrayObj $arr ) {
    $arr->sliced( 0 .. ARRAY_MAX )
  }

  # Optionally utobox list-type refs via List::Objects::WithUtils ->
  use Defaults::Modern 'autobox_lists';

  # See DESCRIPTION for complete details on imported functionality.

=head1 DESCRIPTION

Yet another approach to writing Perl in a modern style.

. . . also saves me extensive typing ;-)

When you C<use Defaults::Modern>, you get:

=over

=item *

L<strict> and fatal L<warnings> except for C<once>; additionally disallow
L<bareword::filehandles>

=item *

The C<v5.14> feature set (state, say, unicode_strings, array_base) except for
C<switch>

=item *

B<carp>, B<croak>, and B<confess> from L<Carp>

=item *

B<blessed>, B<reftype>, and B<weaken> from L<Scalar::Util>

=item *

B<array>, B<immarray>, and B<hash> object constructors from
L<List::Objects::WithUtils>

=item *

B<fun> and B<method> from L<Function::Parameters>

=item *

The full L<Types::Standard> set and L<List::Objects::Types>, which are useful
in combination with L<Function::Parameters>

=item *

B<try> and B<catch> from L<Try::Tiny>

=item *

B<path> from L<Path::Tiny>

=item *

B<maybe> from L<PerlX::Maybe>

=item *

A B<define> keyword for defining constants

=item *

L<true> to avoid adding '1;' to all of your modules

=back

If you import C<autobox_lists>, ARRAY and HASH type references are autoboxed
via L<List::Objects::WithUtils>.

Uses L<Import::Into> to provide B<import>; see the L<Import::Into>
documentation for details.

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

Licensed under the same terms as Perl.

Inspired by L<Defaults::Mauke> and L<Moops>.

The code backing the B<define> keyword is forked from TOBYINK's
L<PerlX::Define> to avoid the L<Moops> dependency and is copyright Toby
Inkster.

=cut

# vim: ts=2 sw=2 et sts=2 ft=perl
