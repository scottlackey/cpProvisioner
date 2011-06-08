#!/usr/bin/perl
use warnings;
use strict;
#scott lackey 6/6/2011
# finds a given appserver, creates iptables rules for it, saves them in a file, SCPs them to the server, connects and restarts iptables on the server.

use Net::SSH2;
use My::Provisioner;
use My::Manager;


unless ($ARGV[0]){ showUsage();}

my $as = getAppServer( $ARGV[0]);
print "successfully found the appserver $as \n";

my $ssh2 = Net::SSH2->new();
  $ssh2->connect('localhost') or die $!;
if ($ssh2->auth_password('slackey','power')) {
	#shell 
	my $chan = $ssh2->channel();
	$chan->shell();
	print $chan "uname -a\n";
	print "LINE : $_" while <$chan>;
	$chan->close;
} 
else {
    warn "auth failed.\n";
    #  my $sftp = $ssh2->sftp();
    #  my $fh = $sftp->open('/etc/passwd') or die;
    #  print $_ while <$fh>;
}

sub getAppServer{
 my $id = shift;
 my $as = Appserver->new( appserver_id => $id );
            unless ( $as->load( speculative => 1 ) ) {
                die "No such appserver ID "
                  . $id
                  . " can be found\n";
            }
 return $id;
}

sub showUsage {
    print
        "Type 'perldoc iptables.pl' for more options and information.\n\n"
      . "Usage: iptables.pl <AppServerID>\n";
    exit();
}
