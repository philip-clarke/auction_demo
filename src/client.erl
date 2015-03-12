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
    Bid = random:uniform(5),
    case Bid of
        3 ->
            erlang:exit({unluckly, Bid});
        _ ->
            ok
    end,

    From ! {self(), AuctionId, Bid}.

