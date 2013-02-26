#!/usr/bin/env escript
%% -*- erlang -*-
%%! -pz .

main([Mode,URL,CNum,RNum]) ->  
    
    ClientNum = list_to_integer(CNum),
    ReqNum    = list_to_integer(RNum),
    AvgNum    =  ReqNum div ClientNum,
    RemNum    =  ReqNum rem ClientNum,

    case ReqNum >= ClientNum of
      true -> 
          case Mode of
            "std" ->
              eHttpBenchStd:start(URL,ClientNum,AvgNum,RemNum);
            _ ->
              eHttpBenchDIY:start(URL,ClientNum,AvgNum,RemNum)
          end;
      false ->
        io:format("Error:The Request number should be greater than clients number."),
        usage()
    end;

main(_) ->
    usage().

usage() ->
    io:format("~nUsage: eHttpBench.erl <mode [std|nostd]> <http://ip:port/path> <client number> <request num>~n"),
    io:format("Example 1: eHttpBench.erl std   http://127.0.0.1:2280/abc 200 1000~n"),
    io:format("Example 2: eHttpBench.erl nostd http://127.0.0.1:2280/abc 200 1000~n~n").


