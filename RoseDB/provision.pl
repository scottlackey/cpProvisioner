#!/usr/bin/perl

use My::Provisioner;
use My::Manager;

use Getopt::Long;

use warnings;
use strict;



my ( $opt );

GetOptions(
    \%{$opt},

    'type=s',       # Type of object to provision (account, appinstance, threadpack)
    'account=s',    # Account to provision or attach object to
    
    'instance=s',   # Appinstance to connect threadpack to

    'help'
);

if ( !$opt->{'type'} || !$opt->{'account'} || $opt->{'help'} ) { showUsage(); }

my $u = Account->new( accountname => $opt->{'account'} );

for ( lc( $opt->{'type'} ) ) {
    /account/ && do {
        if ( $u->load( speculative => 1 ) ) {
            die "Error: account '$opt->{'account'}' already exists.\n";
        }

        $u->save();

        print "Created account '$opt->{'account'}'.\n";
        exit();
    };

    /appinstance/ || /threadpack/ && do {
        unless ( $u->load( speculative => 1 ) ) {
            die "Error: no such account '$opt->{'account'}' can be found.\n";
        }
    };

    /appinstance/ && do {
        # Find an appserver
        my $as = getAppServer( '1' );

        # Create the appinstance
        my $ai = createAI( $u->account_id );
        addResourceToAI( [ 'mysql', 'memcached' ], $ai, $opt->{'account'} );

        # Attach an initial threadpack to the appinstance
        my $tp = createTP( $ai, '1', $as );
        attachAITP( $ai, $tp );

        print "Created appinstnace '$ai' attached to threadpack '$tp' for account '$opt->{'account'}' with '1' thread on appserver '$as'.\n";
        exit();
    };

    /threadpack/ && do {
        if ( !$opt->{'instance'} ) {
            die "Error: no appinstance specified.\n";
        }

        my $ai = Appinstance->new( appinstance_id => $opt->{'instance'} );

        # Check that appinstance exists
        unless ( $ai->load( speculative => 1 ) ) {
            die "Error: no such appinstance '$opt->{'instance'}' can be found.\n";
        }

        # Find an appserver
        my $as = getAppServer( '1' );

        # Create and attach the threadpack
        my $tp = createTP( $opt->{'instance'}, '1', $as );
        attachAITP( $opt->{'instance'}, $tp );

        print "Added threadpack '$tp' to appinstance '$opt->{'instance'}' for account '$opt->{'account'}' with '1' thread on appserver '1'.\n";
        exit();
    };

    print "Error: type '$opt->{'type'}' not recognized.\n";
    showUsage();
}



# Attaches a TP to an AI, and makes it live.
sub attachAITP {
    my ( $ai_id, $tp_id ) = @_;
    my $tp = Threadpack->new( threadpack_id => $tp_id );
    unless ( $tp->load( speculative => 1 ) ) {
        die "No such threadpack ID $tp_id can be found\n";
    }
    my $ai = Appinstance->new( appinstance_id => $ai_id );
    unless ( $ai->load( speculative => 1 ) ) {
        die "No such appinstance ID $ai_id can be found\n";
    }

    $tp->is_live('1');
    $tp->used('1');
    $tp->locked('0');
    $tp->save;

    my $totalthreads = $ai->threads_live + $tp->thread_count;
    $ai->threads_requested($totalthreads);
    $ai->threads_live($totalthreads);
    $ai->is_live('1');
    $ai->save;
}



# Finds and locks a given resource_type and returns the resource_id
sub findRes {
    my $rtype = shift;
    my $resource;    #resource object to return the ID of.
    my $found = 0;   #let us know if no resources were found.
    my $rt = Resourcetype->new( resource_type_name => $rtype );
    unless ( $rt->load( speculative => 1 ) ) {
        die "No such resourcetype $rtype can be found\n";
    }
    my $res =
      Resource::Manager->get_resource(
        query => [ resource_type_id => $rt->resource_type_id ] );
    foreach my $r (@$res) {
        if (   $r->resource_type_id == $rt->resource_type_id
            && $r->locked == '0'
            && $r->used == '0' )
        {
            $resource = Resource->new( resource_id => $r->resource_id );
            unless ( $resource->load( speculative => 1 ) ) {
                die "No such resource ID "
                  . $r->resource_id
                  . " can be found\n";
            }
            $resource->locked('1');
            $found = 1;
            last;
        }
    }
    unless ($found) {
        die "Cannot find unused, unlocked resource of type $rtype\n";
    }
    $resource->save;
    return $resource->resource_id;
}



#adds a list of resourcetypes to an appinstance by updating the ResourceAccess table
sub addResourceToAI {
    my ( $rtypes, $ai, $account ) = @_;
    foreach my $each (@$rtypes) {
        print " Allocating resourcetype: $each \n";
        my $res = findRes($each);
        if ($res) {
            my $ra = Resourceaccess->new(
                appinstance_id         => $ai,
                authorizing_account_id => $account,
                resource_id            => $res
            );
            $ra->save;

       #Here we update the resource's table with the accountid that now owns it.
            my $r = Resource->new( resource_id => $res );
            unless ( $r->load( speculative => 1 ) ) {
                die "No such resource ID "
                  . $r->resource_id
                  . " can be found\n";
            }
            $r->account_id($account);
            $r->used('1');
            $r->save;
        }
        else { die " Could not find available resource type $each \n"; }
    }
}



#Check for a viable Appserver that has enough threads available, or exit with error
sub getAppServer {
    my $threads = shift;
    my $appserverid;
    my $res = Appserver::Manager->get_appserver();
    foreach my $r (@$res) {
        if (   $r->thread_count - $r->threads_used >= $threads
            && $r->is_live
            && $r->is_allocating )
        {
            $appserverid = $r->appserver_id;
            last;
        }
        else { die "No suitable AppServer can be found. Exiting...\n"; }
    }
    return $appserverid;
}



#assuming a valid AppInstance, Threadcount and AppServer have been defined, make a threadpack
sub createTP {
    my ( $ai, $tc, $as ) = @_;
    my $tp = Threadpack->new(
        thread_count   => $tc,
        appinstance_id => $ai,
        appserver_id   => $ai,
        locked         => '1',
    );
    $tp->save;
    return $tp->threadpack_id;
}



#create a new AppInstance and associate it with the accountid defined at the command line
sub createAI {
    my ($uid) = @_;
    my $ai = Appinstance->new(
        account_id        => $uid,
        threads_requested => 1
    );
    $ai->save;
    return $ai->appinstance_id;
}



sub showUsage {
    print
        "Type 'perldoc provision.pl' for more options and information.\n\n"
      . "Usage: provision.pl -t <type> -a <accountname> ...\n";

    exit();
}

