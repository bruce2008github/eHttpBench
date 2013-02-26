
*****************************************************************************************************
Note:
   
   The eHttpBench is a tool for benchmarking web servers. It can simulate thousands clients to access 
   the the web page(HTTP/1.1 requests). This benchmark can test if your HTTP Server can realy handle that many clients at once without taking your machine down. 


   It's written in the Erlang programming language and has been verified in the OTP-15B.

   For Erlang programming language, pls refer to http://en.wikipedia.org/wiki/Erlang_(programming_language)   
   

*****************************************************************************************************
Build:

   1) Make sure you have install the erlang(http://www.erlang.org/) 

   2) run make command

*****************************************************************************************************
Usage:
   
   1) launch your web server application

   2) launch the eHttpBench.erl with the specified the server url info , concurrent clients number and 
      total requests number.
      (run ./eHttpBench.erl -h to see the detail info)

  


