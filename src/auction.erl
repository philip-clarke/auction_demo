-module(auction).
-compile([export_all, debug_info]).

%start(NumClients) ->
%    Pid = erlang:spawn(fun() -> init(NumClients) end),
%    logger ! {create, Pid, 0}.
%
%init(NumClients) ->
%    AuctionId = erlang:now(),
%    Clients = spawn_clients(NumClients),
%    send_bid_requests(AuctionId, Clients),
%    handle_bid_responses(AuctionId, []).
%
spawn_clients(0) ->
    [];
spawn_clients(NumClients) ->
    Pid = spawn_link(client, start, []),
    [Pid | spawn_clients(NumClients - 1)].


send_bid_requests() ->
    ok.

handle_bid_responses() ->
    ok.

choose_winner() ->
    ok.
