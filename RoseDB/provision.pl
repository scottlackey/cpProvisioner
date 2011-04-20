#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
#Our Rose::Db schema map as well as other object definitions.
use My::Provisioner;
use My::Manager;


my %Opts;
GetOptions(\%Opts, 'new|n', 'help|h', 'user|u=s',);
my $new = $Opts{'new'};
my $help = $Opts{'help'};
my $user = $Opts{'user'};

#validate
my $usage = "Usage: provision.pl -n -u <username>  (creates new default appinstance)\n";
if ($help) { die $usage };
die $usage unless ($user);

my $u = User->new(username => $user);
unless($u->load(speculative => 1)) {
      die "No such user in DB";
    }

my $threads = '1';
#my $ai = createAI($u->user_id);
#my $tp = createTP($ai, $threads);

#print "APPInstance = $ai, ThreadPack = $tp\n";

#attach AI to TP
#attachAITP($ai, $tp);

getAppServer($threads);

#end main
#subs
#################################################################################################
#UNUSED
sub checkTP{
my $tc = shift;
	my $tp = Threadpack->new(thread_count => $tc
				);
}

sub getAppServer{
my $threads = shift;

my $res = Appserver::Manager->get_appserver();
foreach my $r (@$res) {
       print "\n Appserver " . $r->hostname . " Thread Count ". $r->thread_count ."\n";
	if ($r->thread_count - $r->threads_used >= $threads){
		my $val = $r->thread_count - $r->threads_used ;
print "value  $val \n";
		}
	}
}

sub createTP{
my ($ai, $tc) = shift;
my $tp = Threadpack->new(thread_count => $tc,
			 appinstance_id => $ai,
			);
$tp->save;
return $tp->threadpack_id;
}

sub createAI{
my ($uid) = shift;
my $ai = Appinstance->new(account_id => $uid,
			  threads_requested => 1
			  );
$ai->save;
return $ai->appinstance_id;
}



