-module(logger).
-export([start/0]).

start() ->
    Pid = erlang:spawn(fun() -> loop() end),
    register(?MODULE, Pid).

loop() ->
    receive
        {no_winner, AuctionId} ->
            io:format("No winner for ~p~n", [AuctionId]);
        {winner, AuctionId, Value} ->
            io:format("The winning value for ~p is ~p, took ~p ms~n", [AuctionId,
                                                           Value,
                                                           timer:now_diff(erlang:now(), AuctionId)/1000]);
        {'EXIT', _From, normal} ->
            ok;
        {'EXIT', From, Reason} ->
            io:format("Exit from ~p due to ~p~n", [From, Reason]);
        {create, Pid, Value} ->
            demo_ws:send({create, Pid, Value});
        {update, Pid, Value} ->
            demo_ws:send({update, Pid, Value});
        _ ->
            ok
    end,
    loop().

