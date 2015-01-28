-module(demo_ws).

-behaviour(cowboy_websocket).

-export([init/2, send/1]).
-export([websocket_handle/3]).
-export([websocket_info/3]).

send(Msg) ->
    gproc:send({p, l, ?MODULE}, Msg).

init(Req, Opts) ->
    self() ! post_init,
	{cowboy_websocket, Req, Opts}.

websocket_handle({text, Msg}, Req, State) ->
	{reply, {text, << "That's what she said! ", Msg/binary >>}, Req, State};
websocket_handle(_Data, Req, State) ->
	{ok, Req, State}.

websocket_info(post_init, Req, State) ->
    true = gproc:reg({p, l, ?MODULE}),
    Data = [
                {action, init},
                {data, [
                        #{<<"pid">> => <<"1">>,<<"value">> => 30},
                        #{<<"pid">> => <<"2">>,<<"value">> => 20},
                        #{<<"pid">> => <<"3">>,<<"value">> => 30}
                       ]
                }
           ],
    Json = jsx:encode(Data),
	{reply, {text, Json}, Req, State};
websocket_info({update, Pid, Value}, Req, State) ->
    Data = [
               {<<"action">>, update},
               {<<"data">>, [#{<<"pid">> => <<"3">>,<<"value">> => 10}]}
            ],
    Json = jsx:encode(Data),
	{reply, {text, Json}, Req, State};
websocket_info(_Info, Req, State) ->
	{ok, Req, State}.
