#!/usr/bin/perl
use strict 'vars';
use warnings;
use Data::Dumper::Perltidy;
use AnyEvent;
use Plack::Request;
use Coro::Twiggy;

my %CORS = (
    'BIN'    =>  ['Access-Control-Allow-Headers' => 'Application-Token, Authorization, X-Requested-With, Content-Type, Cache-Control', 'Access-Control-Allow-Origin' => q{*}, 'Content-Type' => 'application/octet-stream'],
    'HTML'   =>  ['Access-Control-Allow-Headers' => 'Application-Token, Authorization, X-Requested-With, Content-Type, Cache-Control', 'Access-Control-Allow-Origin' => q{*}, 'Content-Type' => 'text/html'],
    'JSON'   =>  ['Access-Control-Allow-Headers' => 'Application-Token, Authorization, X-Requested-With, Content-Type, Cache-Control', 'Access-Control-Allow-Origin' => q{*}, 'Content-Type' => 'application/json'],
    'PLAIN'  =>  ['Access-Control-Allow-Headers' => 'Application-Token, Authorization, X-Requested-With, Content-Type, Cache-Control', 'Access-Control-Allow-Origin' => q{*}, 'Content-Type' => 'text/plain'],
    'CUSTOM' =>  ['Access-Control-Allow-Headers' => 'Application-Token, Authorization, X-Requested-With, Content-Type, Cache-Control', 'Access-Control-Allow-Origin' => q{*}, 'Content-Type' => ],
);

my $app = sub {
    my ($e) = (@_);
    my $r = Plack::Request->new($e);
    return [
        200
        => $CORS{'PLAIN'}
        => [time]
    ]
};

my $twiggy = Coro::Twiggy->new('host' => '127.0.0.1', port=> '9898');
$twiggy->register_service($app);

warn 'started';
AE::cv->recv;