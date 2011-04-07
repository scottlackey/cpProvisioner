#!/usr/bin/perl 
use strict;
use warnings;
use Provisioner;

#This is a test program to try out loading values into the DB using Rose::DB:Object methods rather than writing SQL. So far this funtionality works, with each table name as it's own object defined in 'Provisioner.pm'

my $p = Resource->new(resource_id => '1');
    print $p->resource_id;

#Save a value to the DB
#my $u = User->new(username => 'testuserfromRoseDB',
#		  password => 'test'
#);

#$u->save;

#Load a value to the DB
my $u = User->new(user_id => '1');
$u->load;

	print "\n" . $u->username . "\n";
