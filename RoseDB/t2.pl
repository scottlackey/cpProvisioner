#!/usr/bin/perl 
use strict;
use warnings;
use Provisioner;

#This is a test program to try out loading values into the DB using Rose::DB:Object methods rather than writing SQL. So far this funtionality works, with each table name as it's own object defined in 'Provisioner.pm'

my $p = Resourcetype->new(resource_type_name => 'mysql',
		tcpip_based => '1', 
		requires_agent => '1',	
		standard_port => '3306'
);
 my $res = Resourcetype::Manager->get_resource_types();
 foreach my $r (@$res) {
	print "\n Resource Type " . $r->resource_type_name . "\n";
}

    print $p->resource_type_name;
$p->save;

#Save a value to the DB
my $su = User->new(username => 'slackey',
		  password => 'test'
);
$su->save;

#Load a value from the DB
my $lu = User->new(user_id => '2');
$lu->load;

	print "\n" . $lu->username . "\n";
