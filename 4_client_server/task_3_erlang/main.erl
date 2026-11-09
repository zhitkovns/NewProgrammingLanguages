-module(main).
-export([start/0, manager_loop/1, handle_client/1]).

start() ->
    ManagerPid = spawn(fun() -> manager_loop(#{}) end),
    register(semaphore_manager, ManagerPid),
    
    {ok, ListenSocket} = gen_tcp:listen(8083, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]),
    io:format("Semaphore TCP server listening on 127.0.0.1:8083~n"),
    accept_loop(ListenSocket).

accept_loop(ListenSocket) ->
    case gen_tcp:accept(ListenSocket) of
        {ok, Socket} ->
            io:format("Client connected~n"),
            spawn(fun() -> handle_client(Socket) end),
            accept_loop(ListenSocket);
        {error, Reason} ->
            io:format("Accept error: ~p~n", [Reason])
    end.

handle_client(Socket) ->
    case gen_tcp:recv(Socket, 0) of
        {ok, Data} ->
            Line = string:trim(binary_to_list(Data)),
            io:format("Received command: ~s~n", [Line]),
            case string:split(Line, " ") of
                ["ACQUIRE", Name] ->
                    semaphore_manager ! {acquire, Name, self()},
                    receive
                        {acquired, Name} ->
                            gen_tcp:send(Socket, "OK\n"),
                            io:format("Granted ~s~n", [Name]),
                            handle_client(Socket)
                    end;
                ["RELEASE", Name] ->
                    semaphore_manager ! {release, Name},
                    gen_tcp:send(Socket, "OK\n"),
                    io:format("Released ~s~n", [Name]),
                    handle_client(Socket);
                _ ->
                    gen_tcp:send(Socket, "ERROR\n"),
                    handle_client(Socket)
            end;
        {error, closed} ->
            io:format("Client disconnected~n"),
            gen_tcp:close(Socket)
    end.

manager_loop(State) ->
    receive
        {acquire, Name, Pid} ->
            case maps:get(Name, State, free) of
                free ->
                    Pid ! {acquired, Name},
                    NewState = State#{Name => {busy, queue:new()}},
                    manager_loop(NewState);
                {busy, Queue} ->
                    NewQueue = queue:in(Pid, Queue),
                    NewState = State#{Name => {busy, NewQueue}},
                    manager_loop(NewState)
            end;
        {release, Name} ->
            case maps:get(Name, State, free) of
                free ->
                    manager_loop(State);
                {busy, Queue} ->
                    case queue:out(Queue) of
                        {{value, NextPid}, NewQueue} ->
                            NextPid ! {acquired, Name},
                            NewState = State#{Name => {busy, NewQueue}},
                            manager_loop(NewState);
                        {empty, _} ->
                            NewState = State#{Name => free},
                            manager_loop(NewState)
                    end
            end
    end.