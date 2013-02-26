-module(eHttpBenchStd).
-export([start/4,sendHttpGetRequest/1]).


start(URL,CNum,RNum,RemNum)->
   inets:start(),
   Pid= self(),
   Request = buildRequestForHttpLib(URL),
   eHttpBenchCommon:launchWorkers(Pid,Request, fun eHttpBenchStd:sendHttpGetRequest/1, 
   	             CNum,CNum,RNum,RemNum,[]),
   eHttpBenchCommon:waitWorkersDone(Pid,CNum*RNum+RemNum).
  
buildRequestForHttpLib(URL)->
    {get,
        {
          URL, 
          [
           {"Connection","keep-alive"},
           {"Accept", "*/*" },
           {"User-Agent","eHttpBench std mode 1.0"}                                
          ]
        },
        [                            
          {version,"HTTP/1.1"}
        ],
        []
     }.

sendHttpGetRequest(Request)->

    {Method, Req, HTTPOptions, Options} = Request,

    Result = httpc:request(Method,Req,HTTPOptions,Options),
    
    %io:format("Result:~p",[Result]),

    case Result of
        {ok, {{_, 200, _},_, _}}  ->
           ok;
        _ ->
           error
    end.




