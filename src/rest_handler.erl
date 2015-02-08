-module(rest_handler).

-export([init/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).
-export([allowed_methods/2]).
-export([handle_post/2]).

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
    {[<<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
	{[
		{<<"text/html">>, hello_to_html},
        {<<"application/x-www-form-urlencoded">>, handle_post}
	], Req, State}.
content_types_provided(Req, State) ->
	{[
		{<<"text/html">>, hello_to_html},
        {<<"application/x-www-form-urlencoded">>, handle_post}
	], Req, State}.

handle_post(Req, State) ->
	{ok, PostVals, Req2} = cowboy_req:body_qs(Req),
	Auctions = proplists:get_value(<<"auctions">>, PostVals),
    io:format("Auctions: ~p~n", [Auctions]),
	Clients = proplists:get_value(<<"clients">>, PostVals),
    io:format("Clients: ~p~n", [Clients]),
    exchange:start(binary_to_integer(Auctions), binary_to_integer(Clients)),
	{true, Req2, State}.
