package Hosts::Setting::Confirmation::Environment;

use strict;
use warnings;
use File::Spec;
use Parallel::ForkManager;
use IPC::Shareable;

use base qw( Hosts::Setting::Confirmation );

use Data::Dumper;

sub do_confirm {
    my $self   = shift;
    my $target = shift;
    my $option = shift;

    my $handle = tie my $all_result, 'IPC::Shareable', undef, { destroy => 1 };
    my $pm = Parallel::ForkManager->new(10);

    $all_result = {};
    foreach my $host_name ( @{ $target->{hosts} } ) {
        my $pid;
        $pid = $pm->start && next;
        $handle->shlock;

        my $ssh_string =
          $self->_make_ssh_string( $host_name, $option,
            $target->{grep_pattern},$target->{grep_target} );

        open( CMD, "$ssh_string  |" );
        my @result = <CMD>;
        close(CMD);

        my $host_result = [];
        foreach (@result) {

            my @list = split( /\s+/, $_ );
            my $data = '';

            if ( $option eq 'load_avg' ) {
                $data .= "avg(1min)\tavg(5min)\tavg(15min)\n";
                foreach ( $list[9], $list[10], $list[11] ) {
                    $_ =~ s/,//g;
                    $data .= $_ . "\t\t";
                }
            }
            else {
                foreach (@list) {
                    $data .= $_ . "\t";
                }
            }

            chop($data);
            push( @$host_result, $data );

        }

        $all_result->{$host_name} = $host_result;
        $handle->shunlock;
        $pm->finish;
    }
    $pm->wait_all_children;
    return ($all_result);
}

sub _make_ssh_string {
    my $self      = shift;
    my $host_name = shift;
    my $option    = shift;
    my $grep_lists  = shift;
    my $grep_target  = shift;

    my $put_cmd = '';
    $put_cmd = ' free'   if ( $option eq 'memory_size' );
    $put_cmd = ' df -h'  if ( $option eq 'disk_size' );
    $put_cmd = ' uptime' if ( $option eq 'load_avg' );

    my $counter = 1;
    if( $option eq 'grep'){
        foreach (@$grep_lists ){
            if( $counter == 1 ){
                $put_cmd = " grep \'$_\' $grep_target->[0]";
            } else {
                $put_cmd .= " \| grep \'$_\'";
            }
            $counter ++;
        }
    }
    my $cmd = 'ssh -A ' . $host_name . $put_cmd;
    return $cmd;
}

1;

__END__

Hosts::Setting::Confirmation::Environment -

=head1 METHODS

=head2 new

=head2 do_confirm()

=head1 AUTHOR

kazuhiko yamakura E<lt>yamakura@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut

