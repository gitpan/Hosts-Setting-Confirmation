package Hosts::Setting::Confirmation::Prompt;

use strict;
use warnings;

use File::HomeDir;
use IO::All;

use base qw( Hosts::Setting::Confirmation );

__PACKAGE__->mk_accessors($_) for qw( setting_file );

use Data::Dumper;

sub new {
    my $class = shift;

    my $self = {
        setting_file  => __PACKAGE__->_check_setting_file,
        checking_list => [ 'hosts', 'perlmod', 'grep_target', 'dumpdir' ]
    };

    return bless $self, $class;
}

sub confirm {
    my $self      = shift;
    my $mode      = shift;
    my $dump_flag = shift;
    my $args      = {};

    my $setting_data = io( $self->{setting_file}->{path} )->all;

    my $check_args;
    foreach ( split( "\n", $setting_data ) ) {

        my $lists = {};
        foreach my $select ( @{ $self->{checking_list} } ) {
            if ( $_ =~ /^$select: (.*)$/ ) {
                @{ $lists->{$select} } = split( ';', $1 );
                foreach my $params ( @{ $lists->{$select} } ) {
                    push( @{ $args->{target}->{$select} }, $params )
                      if ($params);
                }
            }
        }
    }

    if ( $mode =~ m/pattern\=(.*)/g ) {
        $args->{mode} = 'grep';

        foreach ( split( ';', $1 ) ) {
            $_ =~ s/\'//g;
            push( @{ $args->{target}->{grep_pattern} }, $_ );
        }

    }
    else {
        $args->{mode} = $mode;
    }

    my $compare = Hosts::Setting::Confirmation->new();
    my $result  = $compare->confirm($args);

    my $result_str = "\n<<$args->{mode} confirm result>>\n";
    foreach my $host ( keys %$result ) {
        $result_str .= "<$host>----------------------------\n";
        if ( $mode eq 'perlmod' ) {
            foreach my $name ( keys %{ $result->{$host} } ) {
                $result_str .= $name . " : ";
                $result_str .= $result->{$host}->{$name} . "\n";
            }
        }
        else {
            foreach ( @{ $result->{$host} } ) {
                $result_str .= $_ . "\n";
            }
        }
    }

    if ($dump_flag) {
        my $dump_dir = $args->{target}->{dumpdir}->[0];
        if ( !$dump_dir ) {
            $result_str = "dump directory is not exist\n";
        }
        else {
            my $option   = 'connect';
            my $datetime = $self->_look_datetime();
            $datetime =~ s/-//g;
            $datetime =~ s/\s//g;
            $datetime =~ s/://g;

            my $file_name = $dump_dir . '/confirm_result' . $datetime . '.txt';
            io($file_name)->print($result_str);

            $result_str = 'confirm result is ' . $file_name . ' writed.';
        }
    }

    return $result_str . "\n";
}

sub look_help {
    my $self = shift;

    my $help_string = '';
    $help_string .= "\n========================================\n";
    $help_string .= "<Hosts::Setting::Confirmation Help menu>\n";
    $help_string .= "\n(Command)\t\t: (Meaning)\n";
    $help_string .= "show config\t\t: show this module setting\n";
    $help_string .= "set config ( option )\t: fix this module setting\n";
    $help_string .= "confirm ( option )\t: show hosts setting\n";
    $help_string .= "exit | quit\t\t: this module exit\n";

    return $help_string;
}

sub show_config {
    my $self                = shift;
    my $setting_file_status = shift;

    if ( !$setting_file_status ) {
        $setting_file_status = $self->{setting_file}->{status};

    }

    my $view = "\n========================================\n";
    $view .= "<Show Now Config>\n";

    if ( $setting_file_status eq 'nothing' ) {
        $view .= "Last Update\t=> \n";
        $view .= "Hosts\t\t=> \n";
        $view .= "Perl Modules\t=> \n";
        $view .= "Dump Directory\t=> \n";
    }
    else {
        my $setting_data = io( $self->{setting_file}->{path} )->all;

        my $insert = {};
        foreach ( split( "\n", $setting_data ) ) {
            $insert->{uptime}      = $1 if ( $_ =~ /^update: (.*)$/ );
            $insert->{hosts}       = $1 if ( $_ =~ /^hosts: (.*)$/ );
            $insert->{perlmod}     = $1 if ( $_ =~ /^perlmod: (.*)$/ );
            $insert->{grep_target} = $1 if ( $_ =~ /^grep_target: (.*)$/ );
            $insert->{dumpdir}     = $1 if ( $_ =~ /^dumpdir: (.*)$/ );
        }
        $view .= "Last Update\t=> " . $insert->{uptime};
        $view .= "\nHosts\t\t=> ";
        $view .= $insert->{hosts} if ( $insert->{hosts} );
        $view .= "\nPerl Modules\t=> ";
        $view .= $insert->{perlmod} if ( $insert->{perlmod} );
        $view .= "\nGrep Target\t=> ";
        $view .= $insert->{grep_target} if ( $insert->{grep_target} );
        $view .= "\nDump Directory\t=> ";
        $view .= $insert->{dumpdir} if ( $insert->{dumpdir} );
        $view .= "\n";
        return $view;
    }
}

sub set_config {
    my $self   = shift;
    my $option = shift;

    foreach ( @{ $self->{checking_list} } ) {
        if ( $option =~ /$_=(.*)/ ) {
            my $target = $1;
            if ( $target =~ /^[a-zA-Z0-9\-\.\/\:\_\;]*$/ ) {
                $self->_update_config( $_, $target );
            }
        }
    }
}

sub _update_config {
    my $self  = shift;
    my $key   = shift;
    my $value = shift;

    my $datetime = $self->_look_datetime();

    my $io_str .= 'update: ' . $datetime . "\n";

    if ( $self->{setting_file}->{status} eq 'nothing' ) {
        $io_str .= $key . ': ' . $value . "\n";
    }
    else {

        ## file reading ...
        my $config_data = io( $self->{setting_file}->{path} )->all;

        foreach my $select ( @{ $self->{checking_list} } ) {
            if ( $config_data =~ /$select: (.*)\n/g ) {
                if ( $key eq $select ) {
                    $io_str .= $select . ': ' . $value . "\n";
                }
                else {
                    $io_str .= $select . ': ' . $1 . "\n";
                }
            }
            else {
                if ( $key eq $select ) {
                    $io_str .= $select . ': ' . $value . "\n";
                }
            }
        }
    }

    ## writing .,.
    io( $self->{setting_file}->{path} )->print($io_str);

    return "\nupdate config file !!:: " . $key . '=> ' . $value . "\n";
}

sub _check_setting_file {
    my $self = shift;

    my $config = {};
    $config->{path} = File::HomeDir->my_home . '/.hosts-setting-config';

    $config->{status} = 'nothing';

    if ( -e $config->{path} ) {
        $config->{status} = 'exist';
    }
    return $config;
}

1;

__END__

=head1 NAME

Hosts::Setting::Confirmation::Prompt - display shell prompt for many remote hosts. 

=head1 METHODS

=head2 new

=head2 confirm

=head2 look_help

=head2 show_config

=head2 set_config 

=cut

=head1 AUTHOR

kazuhiko yamakura E<lt>yamakura@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut


