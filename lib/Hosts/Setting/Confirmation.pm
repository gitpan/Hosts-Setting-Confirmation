package Hosts::Setting::Confirmation;

use strict;
use warnings;
use base qw( Hosts::Setting::Confirmation::Base );

use POSIX qw(strftime);

use Hosts::Setting::Confirmation::PerlModuleVersion;
use Hosts::Setting::Confirmation::Environment;

our $VERSION = '0.00001_00';

__PACKAGE__->mk_virtual_methods($_) for qw( do_confirm );

sub confirm {
    my $self   = shift;
    my $params = shift;

    my $result     = {};
    my $error_code = $self->_validate($params);

    if ($error_code) {
        $result->{error_code} = $error_code;
        return $result;
    }

    my $check = {
        'perlmod'     => 'PerlModuleVersion',
        'disk_size'   => 'Environment',
        'memory_size' => 'Environment',
        'load_avg'    => 'Environment',
        'grep'        => 'Environment',
    };

    foreach my $mode ( keys %$check ) {
        if ( $params->{mode} eq $mode ) {
            my $class   = 'Hosts::Setting::Confirmation::' . $check->{$mode};
            my $compare = $class->new();
            $result = $compare->do_confirm( $params->{target}, $mode );
        }
    }
    return $result;
}

sub _validate {
    my $self = shift;
    my $data = shift;

    ## mode check
    return 'nothing mode' if ( !$data->{mode} );
}

sub _look_datetime {
    my $self   = shift;
    return strftime( "%Y-%m-%d %H:%M:%S", localtime() );
}

1;

__END__

=head1 NAME

Hosts::Setting::Confirmation - The tool which confirms setting between hosts done a connection of in OPEN SSh

=head1 DESCRIPTION

Hosts::Setting::Confirmation is The tool which confirms setting between hosts done a connection of in OPEN SSh

=head1 METHODS

=head2 confirm($params)

It is a method to confirm setting every host. I set 'mode' of the item which I want to confirm.

=head1 AUTHOR

kazuhiko yamakura E<lt>yamakura@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
