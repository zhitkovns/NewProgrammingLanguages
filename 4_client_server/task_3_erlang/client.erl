-module(client).
-export([start/0]).

start() ->
    io:format("Starting two test clients...~n"),
    spawn(fun() -> test_client("Client1", 0) end),
    spawn(fun() -> test_client("Client2", 500) end),
    timer:sleep(4000).

test_client(Name, Delay) ->
    timer:sleep(Delay),
    {ok, Socket} = gen_tcp:connect("127.0.0.1", 8083, [binary, {packet, 0}, {active, false}]),
    
    io:format("~s: Sending ACQUIRE lock~n", [Name]),
    gen_tcp:send(Socket, "ACQUIRE lock\n"),
    {ok, Resp1} = gen_tcp:recv(Socket, 0),
    io:format("~s: Got ~s", [Name, Resp1]),

    timer:sleep(2000),

    io:format("~s: Sending RELEASE lock~n", [Name]),
    gen_tcp:send(Socket, "RELEASE lock\n"),
    {ok, Resp2} = gen_tcp:recv(Socket, 0),
    io:format("~s: Got ~s", [Name, Resp2]),

    gen_tcp:close(Socket).