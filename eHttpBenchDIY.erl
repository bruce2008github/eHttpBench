-module(eHttpBenchDIY).
-export([start/4,sendHttpGetRequest/1]).

start(URL,CNum,RNum,RemNum)->

   Pid= self(),

   Request = buildRequest(URL),

   eHttpBenchCommon:launchWorkers(Pid,Request, fun eHttpBenchDIY:sendHttpGetRequest/1, 
   	             CNum,CNum,RNum,RemNum,[]),

   eHttpBenchCommon:waitWorkersDone(Pid,CNum*RNum+RemNum).

sendHttpGetRequest(Request)->

    {SocketAddr, SocketPort, BinRequest} = Request,

    {ok, US} = gen_tcp:connect(SocketAddr, SocketPort, [{active, true} | getSOCK_OPTS()]),
    
    gen_tcp:send(US, BinRequest),
    
    Status = checkResponse(),
	
	gen_tcp:close(US),

	Status.   

checkResponse()->
   receive
		{tcp, _US, Data} ->
		   %%io:format("Data:~p~n",[Data]),
		   case parse_Response(Data) of
		   	 Any -> 
		   	  Any
		   end
   end.

buildRequest(URL)->

    {Addr,Port,Path}= parse_URL(list_to_binary(URL)),

    Request = "GET "++ Path++" HTTP/1.1\r\n"++    
                   "User-Agent: eHttpBench DIY mode 1.0\r\n"++
                   "Host: "++Addr++"\r\n"++
                   "Connection: close\r\n"++
                   "\r\n",

    BinRequest = list_to_binary(Request),

    {ok,SocketAddr} = inet_parse:ipv4_address(Addr),

    SocketPort = list_to_integer(Port),

    {SocketAddr,SocketPort,BinRequest}.



parse_URL(<< "http://", Rest/binary >>) ->
        parse_URL(Rest);
parse_URL(URL) ->
        case binary:split(URL, <<"/">>) of
                [Addr] ->                       
                        {Host, Port} = parse_Address(Addr),
                        {Host, Port, "/"};
                [Addr, Path] ->                        
                        {Host, Port} = parse_Address(Addr),
                        {Host, Port, "/"++binary_to_list(Path)}
        end.

parse_Address(Addr) ->
        case binary:split(Addr, <<":">>) of
                [Host, Port] ->                       
                  {binary_to_list(Host), binary_to_list(Port)};
                Other ->
                  exit("Parse invalid address ~p failed!~n",[Other])
        end.

getSOCK_OPTS() -> [binary, {packet, 0}, {nodelay, true}].

parse_Response(<<"HTTP/1.1 ",Rest/binary>>)->      
      parse_Response(Rest);

parse_Response(Response)->
        case binary:split(Response,<<" ">>) of        	  
        	  [<<"200">>, _Tail] ->
        	    ok ;
        	  _Other ->
                %%io:format("Error ~p~n",[Other]),
                error
        end.
