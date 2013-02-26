-module(eHttpBenchCommon).
-compile(export_all).

sleep(N) when N >= 0 ->
    receive
    after N -> ok
    end.

waitWorkersDone(PPid,TotalRequestNum) ->
   
   BeginTime = getTime(),
   
   waitWorkers(PPid,TotalRequestNum,0,0),         
         
   EndTime = getTime(),

   DurTime = (EndTime - BeginTime) / 1000000 ,

   %%io:format("~p,~p ~n",[TotalRequestNum,DurTime]),

   PageSpeed = TotalRequestNum / DurTime,   

   io:format("Speed: ~p pages/second. ~n",[PageSpeed]).


getTime() ->
    {MegaSecs, Secs, Microsecs} = now(),
    (MegaSecs * 1000000 + Secs)*1000000 + Microsecs.

waitWorkers(_PPid,0,OKNum,ErrorNum)->
   
   DoneNum = OKNum + ErrorNum,   
   
   io:format("*** The requests(~p) are processed.~n", [DoneNum]),
   io:format("*** All work is done!~n"),
   io:format("*** OK    Request(~p).~n", [OKNum]),
   io:format("*** Error Request(~p).~n", [ErrorNum]);  

   %PPid !{all_work_done};

waitWorkers(PPid,TotalNum,OKNum,ErrorNum)->
   
   DoneNum = OKNum + ErrorNum,   

   case DoneNum rem 1000 of 
   	  0 ->
   	    io:format("*** The requests(~p) are processed.~n", [DoneNum]);
   	  _Other ->
   	    void
   end,
   
   receive
      {one_req_done}->
         waitWorkers(PPid,TotalNum-1,OKNum+1,ErrorNum);
      {one_req_error}->
         waitWorkers(PPid,TotalNum-1,OKNum,ErrorNum+1);
      Other->
         io:format("*** waitChild Invalid message: ~p~n", [Other]),
         exit("receive invalid worker ack message") 
   end.

launchWorkers(_PPid, _Request, _Handler,CNum, 0, _RNum, _RemNum,Worker_list)->
    io:format("All the clients(~p) forked, ready for work!~n", [CNum]),
    io:format("Send go_work command to the workers!~n"),
    
    lists:foreach( fun(Pid)-> Pid ! {go_work} end, Worker_list);   

launchWorkers(PPid, Request, Handler,CNum, 1, RNum, RemNum,Worker_list)->

   Pid = spawn(
      fun () ->
         receive
          {go_work}->
             work(PPid,Request,Handler,RNum+RemNum)
          end
      end
     ),

   launchWorkers(PPid, Request, Handler, CNum, 0, RNum, RemNum,[Pid|Worker_list]); 

launchWorkers(PPid, Request, Handler, CNum, RemainCNum , RNum, RemNum, Worker_list)->

    Pid = spawn(
      fun () ->
         receive
          {go_work}->
             work(PPid,Request,Handler,RNum)
          end
      end
     ),

    launchWorkers(PPid, Request, Handler, CNum, RemainCNum-1, RNum, RemNum,[Pid|Worker_list]).  

work(_PPid,_Request,_Handler,0)->    
    void;
work(PPid,Request,Handler,RNum)->
     case Handler(Request) of 
     	ok ->
     	  PPid ! {one_req_done} ;
     	error ->
     	  PPid ! {one_req_error}
     end,
     work(PPid,Request,Handler,RNum-1).
