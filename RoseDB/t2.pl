#!/usr/bin/perl 
use strict;
use warnings;
#This is a test program to try out loading values into the DB using Rose::DB:Object methods rather than writing SQL. So far this funtionality works, with each table name as it's own object defined in 'Provisioner.pm'

#Our Rose::Db schema map as well as other object definitions.
use My::Provisioner;
#Manager objects are Rose::DB::Objects that correspond to methods for operating on more than one item in the DB, which is usually the case and it seems stupid that there is a separate module and set of objects for that, but whatever.
use My::Manager;

rtype('mysql','1','1','3306');
rtype('memcache','1','0','11211');
rtype('storage','1','0','2049');

my $rtypes = [ 'mysql', 'memcache', 'storage'];

rserver('localhost', '1', $rtypes);

sub rtype{
	my ($tname, $tcpip, $agent, $port) = @_;
	my $p = Resourcetype->new(resource_type_name => $tname,
		tcpip_based => $tcpip, 
		requires_agent => $agent,	
		standard_port => $port
	);
	$p->save;
}

sub rserver{
	my ($host, $os, $rtypes) = @_;

	my $p = Resourceserver->new(hostname => $host,
		osimage_id => $os
	);
	print "Resource Server " . $p->hostname . " created\n";
	$p->save;

	foreach my $item (@$rtypes){
		my $r = Resourcetype->new(resource_type_name => $item);
		$r->load;
		$p->resource_type_id($r->resource_type_id);
print "resourcetypeID " . $p->resource_type_id . "  \n";
		$p->save;
	}
}



#Manager multiple values
# my $res = Resourcetype::Manager->get_resourcetypes();
# foreach my $r (@$res) {
#	print "\n Resource Type " . $r->resource_type_name . $r->resource_type_id . "\n";
#}


#Save a value to the DB
my $su = User->new(username => 'slackey',
		  password => 'test'
);
#$su->save;

#Load a value from the DB
my $lu = User->new(user_id => '1');
$lu->load;

	print "\n" . $lu->username . "\n";
