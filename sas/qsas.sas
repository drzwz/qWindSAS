options nosource nonumber nodate nonotes nomprint nomlogic noxwait error=10;
%macro TS();
	%put %sysfunc(time(),time.) ���ݴ���...;

	
%mend;
%macro qsas;
filename s socket ':5566' server reconn=0;
%let loop = 1;
%do %while (&loop);   %*�յ�һ���������ݣ�ִ��һ��do whileѭ����;
	data taqnew;  *������������;
		infile s recfm=f lrecl=58;   informat sym $10.;   format time time.;     
		input sym $10. time float4. prevclose float4. open float4. high float4. low float4. close float4. volume float4. openint float4. bid float4. bsize float4. ask float4. asize float4.; *�ֶ����ƿɸ���;
		sym = compress(sym);
	run;
	%*=====================���½������ݴ������Լ����;
	proc append base = taq data=taqnew force;run;
	%TS(); %*���ò��Դ���;
	%*let loop = 0;   %*loop=0���˳�ѭ��;
	%*=====================���Ͻ������ݴ������Լ����;
%end; %*==============ѭ������;
filename s clear;
%mend qsas;
%qsas;
