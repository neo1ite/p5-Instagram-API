use 5.016;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Instagram::API',
    VERSION_FROM      => 'lib/Instagram/API.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
    PREREQ_PM         => {
        'JSON::MaybeXS'       => 0,
        'Data::Validate::URI' => 0,
    }, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/Instagram/API.pm', # retrieve abstract from module
    AUTHOR            => 'A. U. Thor <a.u.thor@a.galaxy.far.far.away>',
    #LICENSE           => 'perl',
    #Value must be from legacy list of licenses here
    #http://search.cpan.org/perldoc?Module%3A%3ABuild%3A%3AAPI
);
