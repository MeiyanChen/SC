EnvGen

Env.new.plot;

(
{
	var sig, env;
	env = EnvGen.kr(Env.new, doneAction:2);
	sig = Pulse.ar(ExpRand(30, 500)) *env;
}.play;
)

 // string

Env.new([0, 5, 0.8, 0], [0.5, 1, 2]).plot;

Env.new([0.01, 1, 0.2, 0.01],  //指数不能为0
	    [0.5, 1, 2],
	    \exp).plot;

Env.new([0, 1, 0.2, 0],
	    [0.5, 1, 2],
	    [12, -3, 0]).plot;  //正数先慢后快， 负数先快后慢; 数值离0越远，幅度越大，

Env.new([0, 1, 0.2, 0], [0.5, 1, 2], [\sine, \sine, 0]).plot;

(
{
	var sig, env;
	env = EnvGen.kr(Env.new(
		[0, 1, 0.2, 0],
		[0.5, 1, 2],
		[3, -3, 0]),
		doneAction:2);
	sig = Pulse.ar(ExpRand(30, 500)) *env;
}.play;
)

//gate , t_gate :
//从非正数到正数，触发以重设包络  0为关闭, 1为打开
//gate不能自动控制， t_gate可以
(
x = {
	arg gate = 0;  //通常设置为1
	var sig, env;
	env = EnvGen.kr(Env.new(
		[0, 1, 0.2, 0],
		[0.5, 1, 2],
		[3, -3, 0]), gate, doneAction:2);
	sig = Pulse.ar(LFPulse.kr(8).range(600, 900)) *env;
}.play;
)

x.set(\gate, 0);  // gate需要重新关闭，然后再开启
//在使用可重启动触发时，最好让doneAction为0

(
x = {
	arg t_gate = 1;  //通常设置为1
	var sig, env;
	env = EnvGen.kr(Env.new(
		[0, 1, 0.2, 0],
		[0.5, 1, 2],
		[3, -3, 0]), t_gate, doneAction:2);
	sig = Pulse.ar(LFPulse.kr(8).range(600, 900)) *env;
}.play;
)

//x.set(\t_gate, 1);

//adsr 比一般包络多了延时 sustain， 只要gate为1， 声音就可以无限延长
(
x = {
	arg gate = 0;
	var sig, env;
	env = EnvGen.kr(Env.adsr, gate);
	sig = VarSaw.ar(SinOsc.kr(16).range(500, 1000)) *env;
}.play;
)

x.set(\gate, 1); // 因为doneaction为0， 声音可以随时被触发，所以最好不用t_gate,否则声音无法延时



(
x = {
	arg gate = 0;
	var sig, env, freq;
	freq = EnvGen.kr(Env.adsr(1), gate, 200, 0.1);
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = VarSaw.ar(SinOsc.kr(16).range(500, 1000)) *env;
}.play;
)

x.set(\gate, 0);



(
x = {
	var sig,env;
	env=EnvGen.kr(Env.new([0,2,5],[2,5],[3,-1]));
	sig={Pulse.ar(ExpRand(30,300))}*env;
}.play;
)


(
x = {
	arg gate=1;
	var sig,env;
	env=EnvGen.kr(
		Env.new(
			[0,1,5], [1,2], [-2,3,1])  ,gate,
	doneAction:2);

	sig=Pulse.ar(LFPulse.kr(8).range(600,900)) * env;
}.play;
)


