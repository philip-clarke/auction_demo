-module(dsp).
-compile([export_all, debug_info]).

start(0) ->
    [];
start(N) ->
    Pid = erlang:spawn(fun run/0),
    [Pid | start(N - 1)].

run() ->
    handle_bid_request().

handle_bid_request() ->
    Bid = make_bid(),
    receive
        {Exchange, AuctionId} ->
            Exchange ! {self(), AuctionId, Bid}
    end.

make_bid() ->
    random:seed(erlang:now()),
    Delay = Bid = random:uniform(5),
    %timer:sleep(Delay * 1000),
    fac(Delay * 800),
    Bid.


fac(1) ->
    1;
fac(N) ->
    N * fac(N-1).

