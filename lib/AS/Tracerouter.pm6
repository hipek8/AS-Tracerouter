use v6;
unit class AS::Tracerouter;

class WhoisEntry {
    has $.query;
    has $.country;
    has $.address;  
    has $.phone;
    has $.rip;
    has $.ips;
    has $.origin-as;

    method new($dest) {
        my ($country,$phone,$address,$source,$ips,$origin-as,$query,$rip);
        $query = $dest;
        try {
        for lines(qq:x/whois $dest/) {
            #next unless /.*Found\s*a\s*referral.*/ fff *;
            my @words = .words;
            next unless @words >1;
            $country = @words[1..*].join(" ") if @words[0] ~~ /:i.*country.*/;
            $phone = @words[1..*].join(" ") if @words[0] ~~ /:i.*phone.*/;
            $address ~= @words[1..*].join(" ")~" " if @words[0] ~~ /:i.*address.*/;
            $ips = @words[1..*].join(" ") if @words[0] ~~ /:i.*inetnum.*/;
            $origin-as = @words[1..*].join(" ") if @words[0] ~~ /:i.*(origin|aut\-num).*/;
            $rip = @words[1..*].join(" ") if @words[0] ~~ /:i.*source.*/;
        };
        #with $origin-as {
            self.bless(:$country,:$phone,:$address,:$ips,:$query,:$origin-as,:$rip);
        } 
        #} else {
            #return WhoisEntry.new(dig-it($dest));
        #}
    }
};
sub find-hosts($to --> Hash) is export {
    my $hosts = qq:x/traceroute $to/;    
    my %h = gather for lines($hosts) {
        next if .words[1] ~~ m/\*/ or .words[0] !~~ m/\d+/;
        .words[0].take;
        .words[2].trim.comb[0^..^*-1].join("").take;
    }

    my %info = gather for %h.kv -> $k, $v {
        $k.take;
        get-entry($v).take;
    };
    return %info;
}

sub get-entry($destination) {
    return WhoisEntry.new($destination);
}

#sub dig-it($fqdn) {
    #for lines(qq:x/dig $fqdn/) { return .words[4] if m/\;\;\s*ANSWER/ ^fff^ m/^$/}    
#}


=begin pod

=head1 NAME

AS::Tracerouter - traces some routes, works ok for RIPE, not so well for others

=head1 SYNOPSIS

  deep-trace github.com
=head1 DESCRIPTION

AS::Tracerouter is …

=head1 AUTHOR

Paweł Szulc <pawel_szulc@onet.pl>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Paweł Szulc

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
