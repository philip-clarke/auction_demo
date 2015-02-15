-module(client).
-compile([export_all, debug_info]).

start() ->
    handle_bid_request().

handle_bid_request() ->
    receive
        {Exchange, AuctionId} ->
            send_bid_response(Exchange, AuctionId)
    end.

send_bid_response(Exchange, AuctionId) ->
    random:seed(now()),
    N = random:uniform(length(behaviour())),
    Behaviour = lists:nth(N, behaviour()),
    Bid = make_bid(Behaviour),
    Exchange ! {self(), AuctionId, Bid}.

make_bid(return) ->
    Bid = random:uniform(5),
    Bid;
make_bid(sleep) ->
    Bid = random:uniform(5),
    Delay = 1,
    timer:sleep(Delay * 1000),
    Bid;
make_bid(work) ->
    Delay = Bid = random:uniform(5),
    fac(Delay * 800),
    Bid;
make_bid(crash) ->
    exit(bad_client).

behaviour() ->
    [return, crash].

fac(1) ->
    1;
fac(N) ->
    N * fac(N-1).

