use Test::More;

use Defaults::Modern;

# Carp
can_ok __PACKAGE__, qw/ carp croak confess /;

# Scalar::Util
can_ok __PACKAGE__, qw/ blessed reftype weaken /;

# Path::Tiny
can_ok __PACKAGE__, qw/ path /;

# Try::Catch
can_ok __PACKAGE__, qw/ try catch /;
  
# List::Objects::WithUtils
can_ok __PACKAGE__, qw/ array immarray hash /;

ok not(eval 'open F, __FILE__'), 'bareword fh eval failed ok';
ok $@, 'bareword fh died ok';
cmp_ok $@, '=~', qr/bareword/i, 'bareword fh threw exception ok';

ok not(eval "\$x"), 'strict eval failed ok';
ok $@, 'strict eval died ok';
cmp_ok $@, '=~', qr/^Global symbol "\$x" requires explicit package name/,
  'strict eval threw exception ok';

eval 'state $foo';
ok !$@, 'state imported ok';
eval 'given ("") {}';
ok $@, 'switch not imported ok';

fun calc (Int $x, Num $y) { $x + $y }
ok calc( 1, 0.5 ) == 1.5, 'Function::Parameters imported ok';

fun frob (ArrayObj $arr) { $arr->count }
ok frob( array(1,2,3) ) == 3, 'List::Objects::Types imported ok';

done_testing;
