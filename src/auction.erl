-module(auction).
-compile([export_all, debug_info]).

start(1) ->
    Dsps = dsp:start(100),
    erlang:spawn(fun() -> run(Dsps) end);
start(N) ->
    Dsps = dsp:start(100),
    Pid = erlang:spawn(fun() -> run(Dsps) end),
    [Pid | start(N - 1)].

run(Dsps) ->
    AuctionId = erlang:now(),
    send_bid_requests(AuctionId, Dsps),
    handle_bid_responses(AuctionId).

send_bid_requests(_AuctionId, []) ->
    erlang:send_after(5000, self(), finished),
    ok;
send_bid_requests(AuctionId, [Dsp|Dsps]) ->
    Dsp ! {self(), AuctionId},
    send_bid_requests(AuctionId, Dsps).

handle_bid_responses(AuctionId) ->
    handle_bid_responses(AuctionId, []).

handle_bid_responses(AuctionId, Responses) ->
    receive
        finished ->
            choose_winner(Responses);
        {_Dsp, AuctionId, _Bid} = Response ->
            io:format("~p~n", [Response]),
            handle_bid_responses(AuctionId, [Response|Responses]);
        {_Dsp, _AuctionId, _Bid} ->
            handle_bid_responses(AuctionId, Responses)
    end.

choose_winner([]) ->
    io:format("*** NO WINNER *** ~n");
choose_winner(Bids) ->
    [Winner|_] = lists:reverse(lists:keysort(3, Bids)),
    io:format("*** WINNER *** ~p~n", [Winner]).
