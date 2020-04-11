#!/usr/bin/perl
use strict 'vars';
use warnings;
use Storable qw(retrieve);
my %stor = qw();
%stor = %{retrieve 'pages.db' or die};
print $stor{'newpage'};
