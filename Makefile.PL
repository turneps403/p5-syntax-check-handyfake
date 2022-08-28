use 5.6;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Syntax::Check::HandyFake',
    VERSION_FROM      => 'lib/Syntax/Check/HandyFake.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/Syntax/Check/HandyFake.pm', # retrieve abstract from module
    AUTHOR            => 'turneps403 <turneps403@mail.ru>',
    LICENSE           => 'MIT License',
    #Value must be from legacy list of licenses here
    #https://metacpan.org/pod/Module::Build::API
);
