-module(auction_demo_app).

-behaviour(application).

%% Application callbacks
-export([start/0, start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
    application:ensure_all_started(auction_demo).

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", cowboy_static, {priv_file, auction_demo, "index.html"}},
            {"/s/[...]", cowboy_static, {priv_dir, auction_demo, "static"}},
            {"/p", rest_handler, []},
            {"/ws", demo_ws, []}
        ]}
    ]),
    {ok, _} = cowboy:start_http(http, 100, [{port, 8888}], [
        {env, [{dispatch, Dispatch}]}
    ]),
    logger:start(), %% TODO put this into the supervision tree
    auction_demo_sup:start_link().

stop(_State) ->
    ok.
