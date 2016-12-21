[![Build Status](https://travis-ci.org/hipek8/AS-Tracerouter.svg?branch=master)](https://travis-ci.org/hipek8/AS-Tracerouter)

NAME
====

AS::Tracerouter - check which Autonomous System routers on path are from. Works ok for RIPE entries, not so well for others.

SYNOPSIS Install with zef/panda
===============================

    zef install .

Trace your favourite site

    >deep-trace github.com

    1 => AS::Tracerouter::WhoisEntry.new(query => "84.116.254.140", country => "EU", address => "Liberty Global Europe Boeing Avenue 53 1119 PE Schiphol Rijk Netherlands ", phone => "+31 20 7788200", rip => "RIPE", ips => "84.116.224.0 - 84.116.255.255", origin-as => "AS6830")
    [...]
    7 => AS::Tracerouter::WhoisEntry.new(query => "207.88.15.77", country => "US", address => "13865 Sunrise Valley Drive ", phone => "+1-800-421-3872", rip => Any, ips => Any, origin-as => Any)

DESCRIPTION
===========

AS::Tracerouter basically calls UNIX `traceroute` and `whois` programs and tries to parse their result in quite dumb way.

Country field doesn't necesarry mean router given router is there, just where Autonomous System it belongs to is registered in.

AUTHOR
======

Paweł Szulc <pawel_szulc@onet.pl>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Paweł Szulc

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
