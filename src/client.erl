-module(client).
-compile([export_all]).

start() ->
    random:seed(now()),
    handle_bid_request().

handle_bid_request() ->
    receive
        {From, AuctionId} ->
            send_bid_response(From, AuctionId)
    after 10000 ->
          ok
    end.

send_bid_response(From, AuctionId) ->
    Bid = random:uniform(5),
    util:fac(800),
    From ! {self(), AuctionId, Bid}.
