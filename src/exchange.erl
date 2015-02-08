-module(exchange).
-export([start/2]).

start(0, _NumClients) ->
    [];
start(NumAuctions, NumClients) ->
    spawn_link(auction, start, [NumClients]),
    start(NumAuctions - 1, NumClients).
