#!/usr/bin/perl
use strict;
use warnings;
use DBI;

my $sth;
our $dbh = DBI->connect("DBI:mysql:database=cp;host=localhost", 'root', 'power')
	 || die "could not connect to DB: $DBI::errstr";

#Create some user accounts
$sth=$dbh->prepare("INSERT INTO users (username, password) VALUES (?,MD5(?))");
$sth->execute('slackey', 'password');

# create the 3 resource types
$sth=$dbh->prepare("INSERT INTO resource_type (resource_type_name, tcpip_based, requires_agent, standard_port) VALUES (?,?,?,?)");
$sth->execute('mysql', '1', '1', '3306');
$sth->execute('storage', '1', '0', '');
$sth->execute('memcached', '1', '0', '11211');

#create a resource server for mysql, server size is number of mysql instances available, usage is how many mysql images are deployed
$sth=$dbh->prepare("INSERT INTO resourceserver (hostname, osimage_id, resource_type_id, resource_version_id, server_size, server_usage, is_live, is_allocating) VALUES (?,?,?,?,?,?,?,?)");
$sth->execute('localhost', '1', '1', '1', '2', '0', '1', '1');

#create a resource server for storage, server size is MB of storage, I guess
$sth=$dbh->prepare("INSERT INTO resourceserver (hostname, osimage_id, resource_type_id, resource_version_id, server_size, server_usage, is_live, is_allocating) VALUES (?,?,?,?,?,?,?,?)");
$sth->execute('localhost', '1', '2', '1', '2', '0', '1', '1');

#create a resource server for memcached, server size is MB of memcache available and server_usage is MB used.
$sth=$dbh->prepare("INSERT INTO resourceserver (hostname, osimage_id, resource_type_id, resource_version_id, server_size, server_usage, is_live, is_allocating) VALUES (?,?,?,?,?,?,?,?)");
$sth->execute('localhost', '1', '3', '1', '2', '0', '1', '1');
