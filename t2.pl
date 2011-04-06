#!/usr/bin/perl 
use strict;
use warnings;
use Resource;

my $p = Resource->new(resource_id => '1');
    print $p->resource_id;

