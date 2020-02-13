#!/usr/bin/perl
use strict 'vars';
use warnings;
use Storable qw(retrieve nstore);
use Coro::Twiggy;
use Plack::Request;
use Data::Dumper::Perltidy;
use JSON;
use AnyEvent;

my %stor = qw();

%stor = %{retrieve 'pages.db' or die};

my $application = sub {
    my ($env) = @_;
    my $req = Plack::Request->new($env);
    warn $req->path;

    if ($req->method eq 'OPTIONS') {
        return [
            200,
            [
                'Access-Control-Allow-Origin' => '*',
                'Access-Control-Allow-Headers' => '*',
                'Content-Type' => 'text/plain'
            ],
            [ 'hmm' ]
        ]
    }

    if ($req->path eq '/commit') {
        nstore \%stor, 'pages.db';
        return [
            200,
            [ 'Access-Control-Allow-Origin' => '*', 'Content-Type' => 'text/plain' ],
            [ time ]
        ]
    }

    elsif ($req->path eq '/load') {
        my $page = $req->param('page');
        unless (exists $stor{$page}) { $stor{$page} = '' }
        return [
            200,
            [ 'Access-Control-Allow-Origin' => '*', 'Content-Type' => 'text/plain' ],
            [ $stor{$page} ]
        ]
    }

    elsif ($req->path eq '/save') {
        my $page = $req->param('page');
        warn Dumper \$req->body_parameters;
        unless (exists $stor{$page}) { $stor{$page} = '' }
        return [
            200,
            [ 'Access-Control-Allow-Origin' => '*', 'Content-Type' => 'text/plain' ],
            [ $stor{$page} ]
        ]
    }

    elsif ($req->path eq '/list') {
        keys %stor;

        return [
            200,
            [ 'Access-Control-Allow-Origin' => '*', 'Content-Type' => 'application/json' ],
            [ encode_json([keys %stor]) ]
        ]
    }

    return [
        200,
        [
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Headers' => '*',
            'Content-Type' => 'text/plain'
        ],
        [ 'hmm' ]
    ]

};


my $server = Coro::Twiggy->new(host => '127.0.0.1', port => 8888);
$server->register_service( $application );

AE::cv->recv;