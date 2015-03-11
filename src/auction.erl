-module(auction).
-compile([export_all, debug_info]).

start(NumClients) ->
    Clients = spawn_clients(NumClients),
    Pid = erlang:spawn(fun() -> init(Clients) end),
    logger ! {create, Pid, 0}.

spawn_clients(0) ->
    [];
spawn_clients(NumClients) ->
    Pid = spawn(client, start, []),
    [Pid | spawn_clients(NumClients - 1)].

init(Clients) ->
    AuctionId = erlang:now(),
    send_bid_requests(AuctionId, Clients),
    handle_bid_responses(AuctionId, length(Clients)).

send_bid_requests(_AuctionId, []) ->
    erlang:send_after(5000, self(), finished),
    ok;
send_bid_requests(AuctionId, [Client|Clients]) ->
    Client ! {self(), AuctionId},
    send_bid_requests(AuctionId, Clients).

handle_bid_responses(AuctionId, NumClients) ->
    handle_bid_responses(AuctionId, NumClients, []).

handle_bid_responses(AuctionId, _NumClients = 0, Responses) ->
    choose_winner(Responses, AuctionId);
handle_bid_responses(AuctionId, NumClients, Responses) ->
    receive
        finished ->
            choose_winner(Responses, AuctionId);
        {_From, AuctionId, Bid} ->
            logger ! {update, self(), length(Responses) + 1},
            handle_bid_responses(AuctionId, NumClients - 1, [Bid|Responses]);
        {_From, _, _} ->
            handle_bid_responses(AuctionId, NumClients, Responses)
    end.

choose_winner([], AuctionId) ->
    logger ! {no_winner, AuctionId};
choose_winner(Responses, AuctionId) ->
    Winner = lists:max(Responses),
    logger !{winner, AuctionId, Winner}.
