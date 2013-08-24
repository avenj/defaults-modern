use Test::More;

use Defaults::Modern;

# Imports
#  Carp
can_ok __PACKAGE__, qw/ carp croak confess /;
  
#  List::Objects::WithUtils
can_ok __PACKAGE__, qw/ array immarray hash /;

#  Path::Tiny
can_ok __PACKAGE__, qw/ path /;

#  PerlX::Maybe
can_ok __PACKAGE__, qw/ maybe provided /;

#  Scalar::Util
can_ok __PACKAGE__, qw/ blessed reftype weaken /;

#  Try::Catch
can_ok __PACKAGE__, qw/ try catch /;

# true
use lib 't/inc';
use_ok 'PkgTrue';

# no indirect
package T { 
    sub f { 1 } 
}
ok not(eval 'f T'), 'indirect eval failed ok';
ok $@, 'indirect method call died ok';
cmp_ok $@, '=~', qr/indirect/i, 'indirect method call threw exception ok'
  or diag explain $@;

# no bareword::filehandles
ok not(eval 'open F, __FILE__'), 'bareword fh eval failed ok';
ok $@, 'bareword fh died ok';
cmp_ok $@, '=~', qr/bareword/i, 'bareword fh threw exception ok'
  or diag explain $@;

# strict
ok not(eval "\$x"), 'strict eval failed ok';
ok $@, 'strict eval died ok';
cmp_ok $@, '=~', qr/^Global symbol "\$x" requires explicit package name/,
  'strict eval threw exception ok' or diag explain $@;

# warnings
ok not(eval "my \$foo = 'bar'; 1 if \$foo == 1"),
  'fatal numeric warning ok';
ok $@, 'numeric warning died ok';
cmp_ok $@, '=~', qr/numeric/, 'numeric warning threw exception ok'
  or diag explain $@;

# 5.14 features
eval 'state $foo';
ok !$@, 'state imported ok';
eval 'given ("") {}';
ok $@, 'switch not imported ok';

# Function::Parameters
fun calc (Int $x, Num $y) { $x + $y }
ok calc( 1, 0.5 ) == 1.5, 'Function::Parameters imported ok';

# List::Objects::Types
fun frob (ArrayObj $arr) { $arr->count }
ok frob( array(1,2,3) ) == 3, 'List::Objects::Types imported ok';

# bad import tag
package My::Bad {
  use Test::More;
  require Defaults::Modern;

  ok not(eval "Defaults::Modern->import('foobar')"),
    'eval with bad import tag failed';
  ok $@, 'eval with bad import tag died';
  cmp_ok $@, '=~', qr/export/, 'eval with bad import tag exception ok'
    or diag explain $@;
}

# autobox_lists
package My::Foo {
  use Test::More;
  use Defaults::Modern 'autobox_lists';

  ok []->count == array->count, 'ARRAY autoboxed ok';
  ok +{}->keys->count == 0, 'HASH autoboxed ok';
  ok +{foo => 1}->inflate->foo == 1, 'autoboxed ->inflate ok';
}

# 'all' import tag
package My::Bar {
  use Test::More;
  use Defaults::Modern ':all';

  ok []->count == 0, ':all import tag ok';
}

# define
define FOO = 'bar';
ok FOO eq 'bar', 'define ok';

done_testing;
