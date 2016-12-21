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

    my %info = await do for %h.kv -> $k, $v {
        start {$k => get-entry($v)};
    };
    return %info;
}

sub get-entry($destination) {
    return WhoisEntry.new($destination);
}

=begin pod

=head1 NAME

AS::Tracerouter - check which Autonomous System routers on path are from. Works ok for RIPE entries, not so well for others.

=head1 SYNOPSIS
Install with zef/panda

  zef install .

Trace your favourite site

  >deep-trace github.com

  1 => AS::Tracerouter::WhoisEntry.new(query => "84.116.254.140", country => "EU", address => "Liberty Global Europe Boeing Avenue 53 1119 PE Schiphol Rijk Netherlands ", phone => "+31 20 7788200", rip => "RIPE", ips => "84.116.224.0 - 84.116.255.255", origin-as => "AS6830")
  [...]
  7 => AS::Tracerouter::WhoisEntry.new(query => "207.88.15.77", country => "US", address => "13865 Sunrise Valley Drive ", phone => "+1-800-421-3872", rip => Any, ips => Any, origin-as => Any)

=head1 DESCRIPTION

AS::Tracerouter basically calls UNIX C<traceroute> and C<whois> programs and tries to parse their result in quite dumb way.

Country field doesn't necesarry mean router given router is there, just where Autonomous System it belongs to is registered in.

=head1 AUTHOR

Paweł Szulc <pawel_szulc@onet.pl>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Paweł Szulc

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
