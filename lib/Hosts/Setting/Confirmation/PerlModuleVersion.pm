package Hosts::Setting::Confirmation::PerlModuleVersion;

use strict;
use warnings;
use File::Spec;
use Parallel::ForkManager;
use IPC::Shareable;

use base qw( Hosts::Setting::Confirmation );

sub do_confirm{
    my $self = shift;
    my $target = shift;

    my $handle = tie my $all_result, 'IPC::Shareable', undef, { destroy => 1 };
    my $pm = Parallel::ForkManager->new(10);

    $all_result = {};
    foreach my $host_name (@{$target->{hosts}}) {
        my $pid;
        $pid = $pm->start && next;
        $handle->shlock;
        my $result = $self->_analyze_by_host( $host_name, $target->{perlmod} );
        $all_result->{$host_name} = $result;
        $handle->shunlock;
        $pm->finish;
    }
    $pm->wait_all_children;
    return ($all_result);
}

sub _analyze_by_host{
    my $self = shift;
    my $host_name = shift;
    my $module_list = shift;

    my $version_result = {};
    foreach my $module_name (@$module_list) {
        my $ssh_string = $self->_make_ssh_string($host_name, $module_name);

        ## STDERR is not display.
        open( STDERR, '> ' . File::Spec->devnull() );
        open( CMD,    "$ssh_string  |" );
        my $version = <CMD>;
        close(CMD);
        chomp($version);
        $version = 'not_install' if ( !$version );

        ## set module_version
        $version_result->{$module_name} = $version;
    }
    return ($version_result);
}

sub _make_ssh_string {
    my $self      = shift;
    my $host_name = shift;
    my $module    = shift;

    my $module_str = 'ssh -A ';
    $module_str .= $host_name;
    $module_str .= ' perl -e ';
    $module_str .= '\\\'use ' . $module . '\;';
    $module_str .= ' print ' . $module . '\-\>VERSION\\\'';

    return $module_str;
}

1;

__END__

=head1 NAME

Hosts::Setting::Confirmation::PerlModuleVersion - 

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






