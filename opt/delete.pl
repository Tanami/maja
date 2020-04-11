#!/usr/bin/perl
use strict 'vars';
use warnings;
use Storable qw(retrieve nstore);
my $page = $ARGV[0];
my %stor = %{retrieve 'pages.db' or die};
warn $stor{$page};
delete $stor{$page};
warn 'deleted';

