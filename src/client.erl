-module(client).
-compile([export_all, debug_info]).

start() ->
    random:seed(now()),
    handle_bid_request().

handle_bid_request() ->
    receive
        {From, AuctionId} ->
            send_bid_response(From, AuctionId)
    end.

send_bid_response(From, AuctionId) ->
    N = random:uniform(length(behaviour())),
    Behaviour = lists:nth(N, behaviour()),
    Bid = make_bid(Behaviour),
    From ! {self(), AuctionId, Bid}.

make_bid(return) ->
    Bid = random:uniform(5),
    Bid;
make_bid(sleep) ->
    Bid = random:uniform(5),
    Delay = 1,
    timer:sleep(Delay * 1000),
    Bid;
make_bid(work) ->
    Bid = random:uniform(5),
    Delay = 3,
    fac(Delay * 800),
    Bid;
make_bid(reds) ->
    reds(10000);

make_bid(crash) ->
    exit(bad_client).

behaviour() ->
    %[return, sleep, work, crash].
    %[work].
    [return].

fac(1) ->
    1;
fac(N) ->
    N * fac(N-1).


reds(0) ->
    ok;
reds(N) ->
    reds(N -1).
