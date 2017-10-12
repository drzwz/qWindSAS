options nosource nonumber nodate nonotes nomprint nomlogic noxwait error=10;
%macro TS();
	%put %sysfunc(time(),time.) 数据处理...;

	
%mend;
%macro qsas;
filename s socket ':5566' server reconn=0;
%let loop = 1;
%do %while (&loop);   %*收到一批行情数据，执行一次do while循环体;
	data taqnew;  *最新行情数据;
		infile s recfm=f lrecl=58;   informat sym $10.;   format time time.;     
		input sym $10. time float4. prevclose float4. open float4. high float4. low float4. close float4. volume float4. openint float4. bid float4. bsize float4. ask float4. asize float4.; *字段名称可更改;
		sym = compress(sym);
	run;
	%*=====================以下进行数据处理、策略计算等;
	proc append base = taq data=taqnew force;run;
	%TS(); %*调用策略处理;
	%*let loop = 0;   %*loop=0将退出循环;
	%*=====================以上进行数据处理、策略计算等;
%end; %*==============循环结束;
filename s clear;
%mend qsas;
%qsas;
