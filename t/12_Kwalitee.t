use strict;
use warnings;

BEGIN {
    unless ( $ENV{RELEASE_TESTING} ) {
        use Test::More;
        plan( skip_all => 'these tests are for release candidate testing' );
    }
}

eval "use Test::Kwalitee qw/kwalitee_ok/";

if ($@) {
    use Test::More;
    plan skip_all => 'Test::Kwalitee not installed';
}

kwalitee_ok();
done_testing;
