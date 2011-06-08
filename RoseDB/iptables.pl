#!/usr/bin/perl
use warnings;
use strict;

use Net::SSH2;

my $ssh2 = Net::SSH2->new();

  $ssh2->connect('localhost') or die $!;
if ($ssh2->auth_password('slackey','power')) {
    #shell 
    my $chan2 = $ssh2->channel();
    $chan2->shell();
print $chan2 "uname -a\n";
print "LINE : $_" while <$chan2>;
print $chan2 "who\n";
print "LINE : $_" while <$chan2>;
    $chan2->close;
} else {
    warn "auth failed.\n";
    #  my $sftp = $ssh2->sftp();
    #  my $fh = $sftp->open('/etc/passwd') or die;
    #  print $_ while <$fh>;
  }
