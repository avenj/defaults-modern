package Defaults::Modern;

use strict; use warnings FATAL => 'all';
no bareword::filehandles;

use v5.14;
use Carp;

use Scalar::Util ();

use feature ();

use Function::Parameters ();
use Path::Tiny           ();
use Try::Tiny            ();
use Types::Standard      ();

use List::Objects::Types ();
use List::Objects::WithUtils ();

use Import::Into;

sub import {
  my $class  = shift;
  my $caller = caller;

  Carp->import::into($caller,
    qw/carp croak confess/,
  );

  Scalar::Util->import::into($caller,
    qw/blessed reftype weaken/,
  );
  
  strict->import;
  warnings->import(FATAL => 'all');
  warnings->unimport('once');
  bareword::filehandles->unimport;

  feature->import(':5.14');
  feature->unimport('switch');

  Function::Parameters->import::into($caller);
  Path::Tiny->import::into($caller, 'path');
  Try::Tiny->import::into($caller);

  List::Objects::WithUtils->import::into($caller,
    qw/array hash immarray/
  );

  List::Objects::Types->import::into($caller, '-all');
  Types::Standard->import::into($caller, '-types');

  1
}

1;

=pod

=head1 NAME

Defaults::Modern - A lightweight approach to modern syntax

=head1 SYNOPSIS

  use Defaults::Modern;

=head1 DESCRIPTION

A light-weight approach to writing modern Perl.

When you C<use Defaults::Modern>, you get:

=over

=item *

L<strict> and fatal L<warnings> except for C<once>

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

=back

Uses L<Import::Into> to provide B<import>; see the L<Import::Into>
documentation for details on extending the importer.

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut

# vim: ts=2 sw=2 et sts=2 ft=perl
