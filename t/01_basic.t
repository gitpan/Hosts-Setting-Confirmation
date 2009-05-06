use strict;
use warnings;
use POSIX qw(strftime);

use Hosts::Setting::Confirmation;

use Test::More tests => 6;

my $hosts = Hosts::Setting::Confirmation->new();

## test -> _validate
{
    my $data      = {};
    my %check = (
        disk_size   => '',
        momory_size => '',
        load_avg => '',
        grep => '',
        '' => 'nothing mode',
    );

    my $counter = 0;
    foreach my $key ( keys %check ){
        $counter++;
        $data->{mode} = $key;
        my $result = $hosts->_validate($data);
        is( $result, $check{$key}, "check _validate method0$counter" );
    }
}

## test -> _look_datetime
{
    my $datetime = $hosts->_look_datetime();

    my $check_date = strftime( "%Y-%m-%d %H:%M:%S", localtime());
    is( $datetime, $check_date, 'check _look_datetime method01' );
}

1;

