-module(demo_ws).

-behaviour(cowboy_websocket).

-export([init/2, send/1, clear/0]).
-export([websocket_handle/3]).
-export([websocket_info/3]).

send(Msg) ->
    gproc:send({p, l, ?MODULE}, Msg).

clear() ->
    gproc:send({p, l, ?MODULE}, clear).

init(Req, Opts) ->
    self() ! post_init,
	{cowboy_websocket, Req, Opts}.

websocket_handle({text, Msg}, Req, State) ->
	{reply, {text, << "That's what she said! ", Msg/binary >>}, Req, State};
websocket_handle(_Data, Req, State) ->
	{ok, Req, State}.

websocket_info(post_init, Req, State) ->
    true = gproc:reg({p, l, ?MODULE}),
    Json = jsx:encode([]),
	{reply, {text, Json}, Req, State};
websocket_info(clear, Req, State) ->
    Data = [
               {action, clear},
               {data, [#{}]}
            ],
    Json = jsx:encode(Data),
	{reply, {text, Json}, Req, State};
websocket_info({create, Pid, Value}, Req, State) ->
    BinPid = list_to_binary(pid_to_list(Pid)),
    Data = [
               {action, create},
               {data, [#{<<"pid">> => BinPid, <<"value">> => Value}]}
            ],
    Json = jsx:encode(Data),
	{reply, {text, Json}, Req, State};
websocket_info({update, Pid, Value}, Req, State) ->
    BinPid = list_to_binary(pid_to_list(Pid)),
    Data = [
               {action, update},
               {data, [#{<<"pid">> => BinPid, <<"value">> => Value}]}
            ],
    Json = jsx:encode(Data),
	{reply, {text, Json}, Req, State};
websocket_info(Info, Req, State) ->
    exit(Info),
	{ok, Req, State}.
