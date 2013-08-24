use Test::More;

use Defaults::Modern;

fun calc (Int $x, Num $y) { $x + $y }
ok calc( 1, 0.5 ) == 1.5, 'Function::Parameters imported ok';

can_ok __PACKAGE__, qw/ carp croak confess /;
can_ok __PACKAGE__, qw/ blessed reftype weaken /;
can_ok __PACKAGE__, qw/ path /;
can_ok __PACKAGE__, qw/ try catch /;
can_ok __PACKAGE__, qw/ array immarray hash /;

ok not(eval 'open F, __FILE__'), 'bareword fh eval failed ok';
ok $@, 'bareword fh died ok';
cmp_ok $@, '=~', qr/bareword/i, 'bareword fh threw exception ok';

ok not(eval "\$x"), 'strict eval failed ok';
ok $@, 'strict eval died ok';
cmp_ok $@, '=~', qr/^Global symbol "\$x" requires explicit package name/,
  'strict eval threw exception ok';

done_testing;
