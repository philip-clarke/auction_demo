-module(rest_handler).

-export([init/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).
-export([allowed_methods/2]).
-export([hello_to_html/2]).
-export([hello_to_json/2]).
-export([hello_to_text/2]).
-export([handle_post/2]).

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
    {[<<"GET">>, <<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
	{[
		{<<"text/html">>, hello_to_html},
		{<<"application/json">>, hello_to_json},
		{<<"text/plain">>, hello_to_text},
        {<<"application/x-www-form-urlencoded">>, handle_post}
	], Req, State}.
content_types_provided(Req, State) ->
	{[
		{<<"text/html">>, hello_to_html},
		{<<"application/json">>, hello_to_json},
		{<<"text/plain">>, hello_to_text},
        {<<"application/x-www-form-urlencoded">>, handle_post}
	], Req, State}.

handle_post(Req, State) ->
	{ok, PostVals, Req2} = cowboy_req:body_qs(Req),
	Auctions = proplists:get_value(<<"auctions">>, PostVals),
    io:format("Auctions: ~p~n", [Auctions]),
	Clients = proplists:get_value(<<"clients">>, PostVals),
    io:format("Clients: ~p~n", [Clients]),
    demo_ws:clear(),
    auction:start(binary_to_integer(Auctions), binary_to_integer(Clients)),
	{true, Req2, State}.
hello_to_html(Req, State) ->
	Body = <<"<html>
<head>
	<meta charset=\"utf-8\">
	<title>REST Hello World!</title>
</head>
<body>
	<p>REST Hello World as HTML!</p>
</body>
</html>">>,
	{Body, Req, State}.

hello_to_json(Req, State) ->
	Body = <<"{\"rest\": \"Hello World!\"}">>,
	{Body, Req, State}.

hello_to_text(Req, State) ->
	{<<"REST Hello World as text!">>, Req, State}.
