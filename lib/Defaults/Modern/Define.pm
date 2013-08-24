package Defaults::Modern::Define;
use strict; use warnings FATAL => 'all';

# Forked from TOBYINK's PerlX::Define, copyright Toby Inkster
#  (... to avoid the Moops dep)
# This probably goes away if PerlX::Define gets pulled out later.

use B ();
use Keyword::Simple ();
sub import {
  shift;

  if (@_) {
    my ($name, $val) = @_;
    my $pkg = caller;
    local $@;
    if (ref $val) {
      eval
        "package $pkg; sub $name () { \$val }; 1;"
    } else {
      eval
        "package $pkg; sub $name () { ${\ B::perlstring($val) } }; 1;"
    }
    die $@ if $@;
    return
  }

  Keyword::Simple::define('define' => sub {
    my $line = shift;
    my ($ws1, $name, $ws2, $equals) =
      ( $$line =~ m{\A([\n\s]*)(\w+)([\n\s]*)(=\>?)}s )
        or Carp::croak("Syntax error near 'define'");
    my $len = length $ws1 . $name . $ws2 . $equals;
    substr($$line, 0, $len)
     = ";use Defaults::Modern::Define $name => ";
  });
}

1;
