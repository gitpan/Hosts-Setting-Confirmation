use strict;
use warnings;
use Term::ReadLine;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Hosts::Setting::Confirmation::Prompt;

my $prompt = "\nhosts_setting> ";
my $term   = new Term::ReadLine('Host Setting Confirmation');
my $out    = $term->OUT || \*STDOUT;

while ( defined( my $command = $term->readline($prompt) ) ) {

    next if $command =~ m/^\s*$/;
    last if $command =~ m/^exit$|^quit$/;

    $term->addhistory($command);

    ## check dump_option
    my $dump_flag = 0;
    if( $command =~ m/\s+\--dump\s*(.*)/g){
        $dump_flag++;
    }

    my $prompt = Hosts::Setting::Confirmation::Prompt->new();
    print $prompt->look_help if( $command eq 'help' );
    print $prompt->show_config if( $command eq 'show config' );
    print $prompt->set_config($1) if( $command =~ /set config (\w+\=+\S+)/ );
    print $prompt->confirm($1,$dump_flag) if( $command =~ /confirm (\w+\_*\w+)/ );
    print $prompt->confirm($1,$dump_flag) if( $command =~ /grep (pattern\=\S+)/ );
}

1;

__END__


    
