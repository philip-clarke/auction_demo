-module(auction).
-compile([export_all, debug_info]).

start(NumClients) ->
    Pid = erlang:spawn(fun() -> init(NumClients) end),
    logger ! {create, Pid, 0}.

init(NumClients) ->
    AuctionId = erlang:now(),
    Clients = spawn_clients(NumClients),
    send_bid_requests(AuctionId, Clients),
    handle_bid_responses(AuctionId, NumClients, []).

spawn_clients(0) ->
    [];
spawn_clients(NumClients) ->
    Pid = spawn_link(client, start, []),
    [Pid | spawn_clients(NumClients - 1)].


send_bid_requests(_AuctionId, []) ->
    erlang:send_after(5000, self(), finished);
send_bid_requests(AuctionId, [Client|Clients]) ->
    Client ! {self(), AuctionId},
    send_bid_requests(AuctionId, Clients).

handle_bid_responses(AuctionId, 0, Responses) ->
    choose_winner(AuctionId, Responses);
handle_bid_responses(AuctionId, NumClients, Responses) ->
    receive
        finished ->
            choose_winner(AuctionId, Responses);
        {_From, AuctionId, Bid} ->
            logger ! {update, self(), length(Responses) + 1},
            handle_bid_responses(AuctionId, NumClients - 1, [Bid|Responses]);
        {_From, _AuctionId, _Bid} ->
            handle_bid_responses(AuctionId, NumClients, Responses)
    end.



choose_winner(AuctionId, []) ->
    logger ! {no_winner, AuctionId};
choose_winner(AuctionId, Responses) ->
    logger ! {winner, AuctionId, lists:max(Responses)},
    ok.

