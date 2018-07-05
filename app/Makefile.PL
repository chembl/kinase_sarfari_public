use inc::Module::Install;
# $Id: Makefile.PL 268 2009-10-14 13:48:58Z mdavies $

# SEE LICENSE

perl_version '5.008001';

name 'SARfari';
all_from 'lib/SARfari.pm';

requires 'Digest::MD5';
requires 'Readonly';
requires 'FindBin';
requires 'IO::File';
requires 'Scalar::Util';
requires 'Storable';
requires 'YAML';
requires 'Archive::Tar';
requires 'Archive::Zip';
requires 'List::MoreUtils';
requires 'PerlIO::gzip';
requires 'Template';
requires 'Template::Stash::XS';
requires 'URI::Escape';
requires 'DBI' =>  '1.605';
requires 'DBD::SQLite' => '1.25';
requires 'Data::Page' => '2';
requires 'JSON::Any' =>  '1.18';
requires 'Module::Find' => '0.06';
requires 'SQL::Abstract' =>  '1.56';
requires 'SQL::Abstract::Limit' => '0.13';
requires 'Test::Warn' => '0.11';
requires 'IO::String';


requires 'DBIx::Class';
requires 'DBIx::Class::InflateColumn::DateTime';

requires 'Catalyst' => '5.7007';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';   
requires 'Catalyst::View::TT';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Catalyst::Plugin::Scheduler';
requires 'Catalyst::Plugin::Browser';
requires 'Catalyst::Plugin::Session';    
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Exception';

requires 'DBD::Oracle';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
