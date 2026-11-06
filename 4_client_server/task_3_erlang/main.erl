-module(main).
-export([main/0]).

-define(HOST, "127.0.0.1").
-define(PORT, 8080).
-define(MESSAGE, <<"Hello from Erlang client">>).
-define(CONNECT_TIMEOUT_MS, 1000).
-define(RECV_TIMEOUT_MS, 5000).
-define(MAX_ATTEMPTS, 3).

main() ->
    case connect_with_retries(?MAX_ATTEMPTS) of
        {ok, Socket} ->
            io:format("connected~n"),
            send_and_receive(Socket),
            gen_tcp:close(Socket);
        {error, Reason} ->
            io:format(standard_error,
                      "failed to connect after ~p attempts: ~p~n",
                      [?MAX_ATTEMPTS, Reason]),
            halt(1)
    end.

connect_with_retries(MaxAttempts) ->
    connect_with_retries(1, MaxAttempts).

connect_with_retries(Attempt, MaxAttempts) when Attempt =< MaxAttempts ->
    io:format("attempt ~p of ~p~n", [Attempt, MaxAttempts]),
    Options = [binary, {packet, 0}, {active, false}],
    case gen_tcp:connect(?HOST, ?PORT, Options, ?CONNECT_TIMEOUT_MS) of
        {ok, Socket} ->
            {ok, Socket};
        {error, Reason} ->
            io:format(standard_error,
                      "connect error: ~p~n", [Reason]),
            timer:sleep(1000),
            connect_with_retries(Attempt + 1, MaxAttempts)
    end;
connect_with_retries(_, _) ->
    {error, connect_failed}.

send_and_receive(Socket) ->
    case gen_tcp:send(Socket, ?MESSAGE) of
        ok ->
            io:format("sent: ~s~n", [?MESSAGE]),
            receive_response(Socket);
        {error, Reason} ->
            io:format(standard_error, "send error: ~p~n", [Reason])
    end.

receive_response(Socket) ->
    case gen_tcp:recv(Socket, 0, ?RECV_TIMEOUT_MS) of
        {ok, Data} ->
            io:format("received: ~s~n", [Data]);
        {error, timeout} ->
            io:format("timeout waiting for response~n");
        {error, Reason} ->
            io:format(standard_error, "recv error: ~p~n", [Reason])
    end.