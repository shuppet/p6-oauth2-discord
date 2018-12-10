unit class OAuth2::Discord;

use HTTP::UserAgent;
use JSON::Fast;

has $.config;
has $.grant-type = 'authorization_code';
had $.code;
has Str:D $.redirect-uri is required;
has $.scope is required;

method !client-id { $.config<web><client_id> }
method !client-secret { $.config<web><client_secret> }

method auth-uri {
    my $web-config = $.config<web>;
    die "missing client_id" unless $web-config<client_id>;
    return $web-config<auth_uri> ~ '?' ~
     ( client_id              => self!client-id,
       client_secret          => self!client-secret,
       grant_type             => $.grant-type,
       code                   => $.code,
       redirect_uri           => $.redirect-uri,
       scope                  => $.scope,
     ).sort.map({ "{.key}={.value}" }).join('&');
}

method code-to-token(:$code!) {
    my %payload =
        code => $code,
        client_id => self!client-id,
        client_secret => self!client-secret,
        redirect_uri => $.redirect-uri,
        grant_type => 'authorization_code';
    my $ua = HTTP::UserAgent.new;
    my $res = $ua.post("https://discordapp.com/api/v6/oauth2/token", %payload);
    $res.is-success or return { error => $res.status-line };
    return from-json($res.content);
}

