package Hosts::Setting::Confirmation::Base;

use strict;
use warnings;
use Carp;

use base qw( Class::Accessor::Fast );

sub new {
    my $class  = shift;
    my $self = {};
    return bless $self, $class;
}

sub mk_virtual_methods {
    my $class = shift;
    foreach my $method (@_) {
        my $slot = "${class}::${method}";
        {
            no strict 'refs';
            *{$slot} = sub {

                Carp::croak( ref( $_[0] ) . "::${method} is not overridden" );
              }
        }
    }
    return ();
}

1;

__END__

=head1 NAME

Hosts::Setting::Confirmation::Base - Base Class of Hosts::Setting::Confirmation

=head1 METHODS

=head2 new

=head2 mk_virtual_methods

=head1 AUTHOR

kazuhiko yamakura E<lt>yamakura@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut


