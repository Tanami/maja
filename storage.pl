#!/usr/bin/perl
use strict 'vars';
use warnings;
use Storable qw(retrieve nstore);
use Coro::Twiggy;
use Plack::Request;
use Data::Dumper::Perltidy;
use JSON;
use AnyEvent;
use Graph;
use Graph::D3;

if (!-e 'pages.db') {
    nstore { 'index' => 'this is the index' }, 'pages.db';
}

my %stor = %{retrieve 'pages.db' or die};

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
        my %new = %{ $req->body_parameters };
        for my $key (keys %new) {
            # trying to catch a bug
            die if $key eq '';
            $stor{$key} = $new{$key};
        }
        nstore \%stor, 'pages.db' or die;
        return [
            200,
            [ 'Access-Control-Allow-Origin' => '*', 'Content-Type' => 'text/plain' ],
            [ 'ok' ]
        ]
    }

    elsif ($req->path eq '/graph') {
        my @files = keys %stor;
        my @links;
        for my $file (keys %stor) {
            my @items = split /( |(?=\n))/ => $stor{$file};
            for (0 ..$#items) {
                next if $items[$_] eq "\n";
                next if $items[$_] eq " ";
                next unless $items[$_] =~ /\w/i;
                my($word) = $items[$_] =~ /(\w+)/i;
                # it doesn't matter if this is lc since it's only for the edge
                if (defined $stor{$word})
                {
                    push @links => [$file, $word];
                }
                elsif (defined $stor{lc $word}) {
                    push @links => [$file, lc $word];
                }
            }
        }
        my $g = new Graph(
            vertices => \@files,
            edges => \@links 
        );
        my $d3 = new Graph::D3(graph => $g, type => 'json'); 
        return [
            200,
            [ 'Access-Control-Allow-Origin' => '*', 'Content-Type' => 'application/json' ],
            [ $d3->force_directed_graph() ]
        ]
    }
    elsif ($req->path eq '/delete') {
        my $page = $req->param('page');
        if (defined $stor{$page}) {
            delete $stor{$page};
            nstore \%stor, 'pages.db' or die;
            return [
                200,
                [ 'Access-Control-Allow-Origin' => '*', 'Content-Type' => 'text/plain' ],
                [ 'deleted' ]
            ]
        }
        else {
            return [
                200,
                [ 'Access-Control-Allow-Origin' => '*', 'Content-Type' => 'text/plain' ],
                [ 'page not found' ]
            ]
        }
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
