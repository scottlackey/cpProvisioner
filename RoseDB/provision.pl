#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

#Our Rose::Db schema map as well as other object definitions.
use My::Provisioner;
use My::Manager;

my %Opts;
GetOptions( \%Opts, 'new|n', 'help|h', 'account|a=s', );
my $new     = $Opts{'new'};
my $help    = $Opts{'help'};
my $account = $Opts{'account'};

#validate
my $usage =
"Usage: provision.pl -n -a <accountname>  (creates new default appinstance)\n";
if ($help) { die $usage }
die $usage unless ($account);

my $u = Account->new( accountname => $account );
unless ( $u->load( speculative => 1 ) ) {
    die "No such account $account can be found\n";
}

my $threads = '1';

my $as = getAppServer($threads);
my $ai = createAI( $u->account_id );
addResourceToAI( [ 'mysql', 'memcached' ], $ai, $account );
my $tp = createTP( $ai, $threads, $as );
attachAITP( $ai, $tp );

print
"APPInstance = $ai, attached to ThreadPack = $tp for account $account with $threads thread(s) on appserver #$as\n";

#end main
#subs
#################################################################################################

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

