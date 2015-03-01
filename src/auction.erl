-module(auction).
-compile([export_all, debug_info]).

start(NumClients) ->
    Clients = spawn_clients(NumClients),
    Pid = erlang:spawn(fun() -> init(Clients) end),
    logger ! {create, Pid, 1}.

spawn_clients(0) ->
    [];
spawn_clients(NumClients) ->
    Pid = spawn(client, start, []),
    [Pid | spawn_clients(NumClients - 1)].

init(Clients) ->
    AuctionId = erlang:now(),
    send_bid_requests(AuctionId, Clients),
    handle_bid_responses(AuctionId).

send_bid_requests(_AuctionId, []) ->
    erlang:send_after(5000, self(), finished),
    ok;
send_bid_requests(AuctionId, [Client|Clients]) ->
    Client ! {self(), AuctionId},
    send_bid_requests(AuctionId, Clients).

handle_bid_responses(AuctionId) ->
    handle_bid_responses(AuctionId, []).

handle_bid_responses(AuctionId, Bids) ->
    receive
        finished ->
            choose_winner(AuctionId, Bids);
        {_From, AuctionId, Bid} ->
            logger ! {update, self(), length(Bids) + 1},
            handle_bid_responses(AuctionId, [Bid | Bids]);
        {_From, _AuctionId, _Bid} ->
            handle_bid_responses(AuctionId, Bids)
    end.

choose_winner(AuctionId, []) ->
    logger ! {no_winner, AuctionId};
choose_winner(AuctionId, Bids) ->
    logger ! {winner, AuctionId, lists:max(Bids)}.
