# $URL
# $Id
#!/usr/bin/perl 
use strict;
use warnings;
#This is a test program to try out loading values into the DB using Rose::DB:Object methods rather than writing SQL. So far this funtionality works, with each table name as it's own object defined in 'Provisioner.pm'

#Our Rose::Db schema map as well as other object definitions.
use My::Provisioner;
#Manager objects are Rose::DB::Objects that correspond to methods for operating on more than one item in the DB, which is usually the case and it seems stupid that there is a separate module and set of objects for that, but whatever.
use My::Manager;

rtype('mysql','1','1','3306');
rtype('memcached','1','0','11211');
rtype('storage','1','0','2049');

my $rtypes = [ 'mysql', 'memcached', 'storage'];
my $servers = [ 'localhost' ];

rserver('localhost', '1', $rtypes);

createresources($rtypes, $servers); 
createappservers('localhost', '1');
createuser('test1');
createuser('test2');
#end main


##########################################################################################33
#begin subs
sub createuser{
my $un = shift;
my $u = User->new(username => $un);
$u->save;
}

sub createappservers{
 my ($name, $os) = @_;
 my $a = Appserver->new(hostname => $name,
			osimage_id => $os,
			thread_count => '100',
			threads_used => '0',
			is_live => '1',
			is_allocating => '1'
			);
$a->save;
}

#creates resources
#WARNING, this function only creates a mysql and memcache resource on the one resourceserer
sub createresources{
 my ($rtypes, $servers) = @_;
my $rt = Resourcetype->new(resource_type_name => 'mysql');
my $rs = Resourceserver->new(hostname => 'localhost');
$rt->load;
$rs->load;
#this creates two mysql resources on the one localhost resourceserer
my $resource = Resource->new(resource_type_id => $rt->resource_type_id,
			     resourceserver_id => $rs->resourceserver_id,
			     resource_version => '5.1'
			    );
$resource->save;
$resource = Resource->new(resource_type_id => $rt->resource_type_id,
			     resourceserver_id => $rs->resourceserver_id,
			     resource_version => '5.1'
			    );
$resource->save;
#this creates two memcache resources on the one localhost resourceserer
 $rt = Resourcetype->new(resource_type_name => 'memcached');
 $rt->load;
 $resource = Resource->new(resource_type_id => $rt->resource_type_id,
			     resourceserver_id => $rs->resourceserver_id,
			     resource_version => '1.4.5'
			    );
$resource->save;
 $resource = Resource->new(resource_type_id => $rt->resource_type_id,
			     resourceserver_id => $rs->resourceserver_id,
			     resource_version => '1.4.5'
			    );
$resource->save;
}


#creates resourcetypes
sub rtype{
	my ($tname, $tcpip, $agent, $port) = @_;
	my $p = Resourcetype->new(resource_type_name => $tname,
		tcpip_based => $tcpip, 
		requires_agent => $agent,	
		standard_port => $port
	);
	$p->save;
}

#creates resourceservers
sub rserver{
	my ($host, $os, $rtypes) = @_;

	my $p = Resourceserver->new(hostname => $host,
		osimage_id => $os,
		is_live => '1',
		is_allocating => '1'
	);
	print "Resource Server " . $p->hostname . " created\n";
	$p->save;

	foreach my $item (@$rtypes){
		#load each resourceid using its name
		my $r = Resourcetype->new(resource_type_name => $item);
		$r->load;
		#insert new XR record associating this serverid with the resourceid
		my $xr = Resourceservertypexr->new(resourceserver_id => $p->resourceserver_id,
						  resource_type_id => $r->resource_type_id
		); 
		$xr->save;
	}
}



#Manager multiple values
# my $res = Resourcetype::Manager->get_resourcetypes();
# foreach my $r (@$res) {
#	print "\n Resource Type " . $r->resource_type_name . $r->resource_type_id . "\n";
#}

