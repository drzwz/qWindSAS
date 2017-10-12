//产生随机行情，通过Socket传送到SAS
system "l wapi.q";
//配置开始：配置需要订阅行情的代码，代码格式为Wind代码格式；可以用wset函数读取代码列表，如wset[`IndexConstituent;`$"date=20150615;windcode=000300.SH"]`data。。。

wind_sub_syms:`000001.SH`399001.SZ`600036.SH`000001.SZ`RB1801.SHF`CU1801.SHF`AU1801.SHF`I1801.DCE`CF1801.CZC`EURUSD.FX;   //

//配置结束
\d .zz
//=============================读取动态库=============================
// ref: http://itfin.f3322.org/opt/cgi/wiki.pl/KdbPlus
dl:@[{(`:qx 2:(`loadlibrary;1))[]};`;(enlist`)!enlist(::)];    // .zzdl: ...
sockopen:{[x]if[3>count x;:-999];if[type[x[0]]<>-11h;:-998];if[not type[x 1] in (-5h;-6h;-7h);:-997];.zz.dl.sockopen[x]};  
sockclose:{[x]if[not type[x] in (-5h;-6h;-7h);:-999];.zz.dl.sockclose[x]};
sockcheck:{[x]if[not type[x] in (-5h;-6h;-7h);:-999];.zz.dl.sockcheck[x]};
tcpsend:{[x;y]if[not type[x] in (-5h;-6h;-7h);:-999];if[not abs[type[y]] in (4h;10h);:-998];.zz.dl.tcpsend[x;y]};  //.zz.tcpsend[h;"abcd\r\n"] .zz.tcpsend[h;0x1234]  
tcprecv:{[x]if[not type[x] in (-5h;-6h;-7h);:-999];.zz.dl.tcprecv[x]};
getsockbuf:{[x].zz.dl.getsockbuf[x]};
setsockbuf:{[x].zz.dl.setsockbuf[x]};

tcpconnasync:{[x]if[2>count x;:-999];if[type[x[0]]<>-11h;:-998];if[not type[x 1] in (-5h;-6h;-7h);:-997];.zz.dl.sockopen[x,enlist 1]};    //1:TCP client async
tcplistenasync:{[x]if[2>count x;:-999];if[type[x[0]]<>-11h;:-998];if[not type[x 1] in (-5h;-6h;-7h);:-997];.zz.dl.sockopen[x,enlist 2]};  //2:TCP server async
tcpconn:{[x]if[2>count x;:-999];if[type[x[0]]<>-11h;:-998];if[not type[x 1] in (-5h;-6h;-7h);:-997];.zz.dl.sockopen[x,enlist 3]};         //3:TCP client sync              //.zz.tcpconn(`127.0.0.1;5000)
tcpdisc:{[x]if[not type[x] in (-5h;-6h;-7);:-999];.zz.dl.sockclose[x]};
tcplisten:{[x]if[2>count x;:-999];if[type[x[0]]<>-11h;:-998];if[not type[x 1] in (-5h;-6h;-7h);:-997];.zz.dl.sockopen[x,enlist 4]};       //4:TCP server sync
udplisten:{[x]if[2>count x;:-999];if[type[x[0]]<>-11h;:-998];if[not type[x 1] in (-5h;-6h;-7h);:-997];.zz.dl.sockopen[x,enlist 0]};       //0:UDP

\d .

upd:()!();
taq:([sym:`$()]time:`time$();prevclose:`real$();open:`real$();high:`real$();low:`real$();close:`real$();volume:`real$();openint:`real$();bid:`real$();bsize:`real$();ask:`real$();asize:`real$());
taq2:taq2_0:`sym`time xcols update time:`real$() from delete date from 0#0!taq;
windtaq:([sym:`$()]rt_time:`float$();rt_pre_close:`float$();rt_open:`float$();rt_high:`float$();rt_low:`float$();rt_latest:`float$();rt_vol:`float$();rt_amt:`float$();rt_oi:`float$();rt_bid1:`float$();rt_bsize1:`float$();rt_ask1:`float$();rt_asize1:`float$());

onwsqsub:{[x]A::x;if[x[`errid]<>0;:()];mysyms:exec sym from x[`data];
	{`windtaq upsert x} each delete dt from x`data;
    `taq2 insert select sym,time:`real$0.001*`long$num2time each rt_time,prevclose:`real$rt_pre_close,open:`real$rt_open,high:`real$rt_high,low:`real$rt_low,close:`real$rt_latest,        volume:`real$rt_vol,openint:`real$?[rt_oi>0;rt_oi;rt_amt],bid:`real$rt_bid1,bsize:`real$rt_bsize1,ask:`real$rt_ask1,asize:`real$rt_asize1 from windtaq where sym in mysyms; 
  };
r:start[`;`];
$[0=r[`errid];
	[0N!(.z.Z;`wind_started;r[`errmsg]);wsqsub[wind_sub_syms;`$"rt_time,rt_pre_close,rt_open,rt_high,rt_low,rt_latest,rt_vol,rt_amt,rt_oi,rt_bid1,rt_bsize1,rt_ask1,rt_asize1";`]];
	0N!(.z.Z;`wind_start_error;r[`errmsg])];

pubtaq:{if[0=count taq2;:()];0N!(.z.T;count taq2);
	if[0<sas:.zz.tcpconn[(`127.0.0.1;5566)];r:.zz.tcpsend[sas;raze{raze(`byte$10#string[x`sym],10#" "),reverse each 0x0 vs/: value `sym _ x} each taq2];if[r>0;taq2::taq2_0];.zz.tcpdisc[sas]];
	};
pubinterval:"J"$first .z.x,enlist "1000";  //发布间隔，毫秒
lastpubtime:.z.D +`time$pubinterval xbar `long$.z.T;
.z.ts:{ 
   if[pubinterval<=`long$`time$.z.P -lastpubtime; pubtaq[];lastpubtime::.z.D +`time$pubinterval xbar `long$.z.T;];
   };    
\t 500
