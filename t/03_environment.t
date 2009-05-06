use strict;
use warnings;
use POSIX qw(strftime);

use Hosts::Setting::Confirmation::Environment;

use Test::More tests => 4;

my $env = Hosts::Setting::Confirmation::Environment->new();

## test -> _make_ssh_string 
{
    my $data      = {};
    my $check = [ 
        { 
            host_name   => 'localhost',
            option   => 'disk_size',
            result   => 'ssh -A localhost df -h'
        },
        { 
            host_name   => 'localhost',
            option   => 'memory_size',
            result   => 'ssh -A localhost free'
        },
        { 
            host_name   => 'localhost',
            option   => 'load_avg',
            result   => 'ssh -A localhost uptime'
        },
        { 
            host_name   => 'localhost',
            option   => 'grep',
            grep_target   => [ '/var/log/grep_target.log' ],
            grep_pattern   => [ 'name=myname', 'param01=value01' ],
            result   => "ssh -A localhost grep \'name=myname\' /var/log/grep_target.log | grep \'param01=value01\'" 
        }
    ];

    my $counter = 0;
    foreach ( @$check ){
        $counter++;

        my $result = $env->_make_ssh_string( $_->{host_name}, $_->{option}, $_->{grep_pattern}, $_->{grep_target});

        is( $result, $_->{result}, "check method _make_ssh_string0$counter" );

    }  
}

1;

