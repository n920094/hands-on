#!/usr/bin/env escript
%% -*- mode:erlang; coding:utf-8 -*-
%%! -smp enable -name riak_client@127.0.0.1 -pa /home/ossforum/riak/deps/riak_core/ebin

main([BucketName, Key]) ->
    Node = 'riak1@127.0.0.1',
    Cookie = 'riak',
    N = 3,

    true = erlang:set_cookie(node(), Cookie),

    case rpc:call(Node, riak_core_ring_manager, get_my_ring, []) of
        {badrpc, Error1} ->
            io:format("error: ~p~n", [Error1]);
        {ok, Ring} ->
            case rpc:call(Node, riak_core_util, chash_key,
                          [{list_to_binary(BucketName), list_to_binary(Key)}]) of
                {badrpc, Error2} ->
                    io:format("error: ~p~n", [Error2]);
                <<HashInt:160/integer>>=HashBin ->
                    Preflist = riak_core_ring:preflist(HashBin, Ring),
                    {Targets, Fallbacks} = lists:split(N, Preflist),

                    io:format("~s/~s: ~p~n~n",      [BucketName, Key, HashInt]),
                    io:format("Targets:~n~p~n~n",   [Targets]),
                    io:format("Fallbacks:~n~p~n",   [Fallbacks])
            end
    end;
main(_) ->
    io:format("usage: riak-preflist-ossforum.escript <bucket-name> <key>~n").
