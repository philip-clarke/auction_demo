-module(auction).
-compile([export_all, debug_info]).

start(0) ->
    [];
start(N) ->
    Dsps = dsp:start(50),
    Pid = erlang:spawn(fun() -> run(Dsps) end),
    demo_ws:send({create, Pid, 1}),
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
            demo_ws:send({update, self(), length(Responses) + 1}),
            %%io:format("~p~n", [Response]),
            handle_bid_responses(AuctionId, [Response|Responses]);
        {_Dsp, _AuctionId, _Bid} ->
            handle_bid_responses(AuctionId, Responses)
    end.

choose_winner([]) ->
    io:format("*** NO WINNER *** ~n");
choose_winner(Bids) ->
    [Winner|_] = lists:reverse(lists:keysort(3, Bids)),
    io:format("*** WINNER *** ~p~n", [Winner]).
