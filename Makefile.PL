use 5.010;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Instagram::API',
    VERSION_FROM      => 'lib/Instagram/API.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
    PREREQ_PM         => { # e.g., Module::Name => 1.1
        'Try::Tiny'              => 0,
        'JSON::XS'               => 0,
        'JSON::PP'               => 0,
        'JSON::MaybeXS'          => 0,
        'Net::Domain::TLD'       => 1.74,
        'Data::Validate::Domain' => 0,
        'NetAddr::IP'            => 0,
        'Data::Validate::IP'     => 0,
        'Data::Validate::URI'    => 0,
    },
    ABSTRACT_FROM     => 'lib/Instagram/API.pm', # retrieve abstract from module
    AUTHOR            => 'Sergey Kovalev <info@neolite.ru>',
    LICENSE           => 'perl',
    #Value must be from legacy list of licenses here
    #http://search.cpan.org/perldoc?Module%3A%3ABuild%3A%3AAPI
);
