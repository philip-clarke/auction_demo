-module(auction).
-compile([export_all, debug_info]).

start(NumClients) ->
    Pid = erlang:spawn(fun() -> init(NumClients) end),
    logger ! {create, Pid, 0}.

init(NumClients) ->
    process_flag(trap_exit, true),
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
        {'EXIT', _From, Reason} = Term when Reason /= normal ->
            logger ! Term,
            handle_bid_responses(AuctionId, NumClients - 1, Responses);
        _Other ->
            handle_bid_responses(AuctionId, NumClients, Responses)
    end.

choose_winner([], AuctionId) ->
    logger ! {no_winner, AuctionId};
choose_winner(Responses, AuctionId) ->
    Winner = lists:max(Responses),
    logger !{winner, AuctionId, Winner}.
