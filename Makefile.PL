use inc::Module::Install;
name 'Hosts-Setting-Confirmation';
all_from 'lib/Hosts/Setting/Confirmation.pm';
build_requires 'Test::More';
build_requires 'File::Spec';
build_requires 'Parallel::ForkManager';
build_requires 'IPC::Shareable';

build_requires 'Test::More';
use_test_base;
auto_install;
WriteAll;

