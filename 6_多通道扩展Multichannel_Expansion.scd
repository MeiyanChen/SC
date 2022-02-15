s.meter(8,8);  //显示输入和输出的通道 0-7  八个通道 // 改变显示的输出和输入通道数量 //ctrl + m

//spatializazion 空间化
// Multichannel Expansion 多通道扩展
//where as single UGen products single channel audio, an array of UGens will products multiple channels of audio

x = {SinOsc.ar}.play; // 一个UGen
x = {[SinOsc.ar(300), SinOsc.ar(500)]}.play; //多个UGen
x = {SinOsc.ar([300, 500,400, 600],mul: 0.1)}.play;
x.free;

//Mix：将所有通道的声音融合在有限的通道里
(
x = {
	var sig, amp;
	amp = SinOsc.kr([7, 1, 2, 4]).range(0, 1); // left channel: 7 times per second, right channel: 1 times per second
	sig = SinOsc.ar([300, 500, 400, 600]);
	sig = sig*amp;
	[Mix.new(sig), Mix.new(sig), Mix.new(sig),Mix.new(sig)]*0.25; // Mix.new(sig).dup(4)*0.25;  // Mix.new(sig)!4*0.25; // avoid clipping
}.play;

)

60.dup(4); //将数据变成排列形式

60!4;

"hello".dup(4);


// Splay 将所有通道的声音融合在双声道中
(
x = {
	var sig, amp;
	amp = SinOsc.kr(7).range(0, 1); // 2 channel 7/s
	sig = SinOsc.ar([300, 500, 700]);
	sig = sig*amp;
	Splay.ar(sig) * 0.5;
}.play;

)



x = {PinkNoise.ar(0.5)!2}.play;//两通道声音一样
x = {PinkNoise.ar(0.5!2)}.play;//两通道各自独立
x.free;


(
SynthDef.new(\multi, {
	var sig, amp;
	amp = SinOsc.kr([7, 1, 2, 6]).range(0, 1); // 可以设定多通道，但其他通道的声音无法播放
	sig = SinOsc.ar([300, 500, 700,1100]);
	sig = sig*amp;
	sig = Splay.ar(sig) * 0.5;
	Out.ar(0, sig);
}).add;
)


x = Synth.new(\multi);
x.free;



//错误范例
(
SynthDef.new(\multi, {
	var sig, amp;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0, 1);
	sig = SinOsc.ar([300, 500, 700]);
	sig = sig*amp;
	sig = Splay.ar(sig) * 0.5;
	Out.ar([0, 1], sig);  //偶然触发多通道扩展  0 代表通道0和1， 1代表通道1和2， 因此这种写法使错误的
}).add;
)


rrand(50, 1200)!4;

{rrand(50, 1200)}!4; //方程+多倍

{exprand(0.2, 12)}!8;

(
SynthDef.new(\multi, {
	var sig, amp;
	amp = SinOsc.kr({exprand(0.2, 12)}!8).range(0, 1); //产生的数据只随机一次
	sig = SinOsc.ar({exprand(50, 1200)}!8);
	sig = sig*amp;
	sig = Splay.ar(sig) * 0.5;
	Out.ar(0, sig);
}).add;
)

(
SynthDef.new(\multi, {
	var sig, amp;
	amp = SinOsc.kr({ExpRand(0.2, 12)}!8).range(0, 1); //数据只在每次synthdef播放时产生
	sig = SinOsc.ar({ExpRand(50, 1200)}!8);
	sig = sig*amp;
	sig = Splay.ar(sig) * 0.5;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\multi);
x.free;

//参考资料：Browse -> UGen -> Random

(
SynthDef.new(\multi, {
	var sig, amp, env;
	env = EnvGen.kr(Env.new([0,1,0],[10,10],[1, -1]), doneAction:2);  //10s attack, 10s release
	amp = SinOsc.kr({ExpRand(0.2, 12)}!8).range(0, 1);
	sig = SinOsc.ar({ExpRand(50, 1200)}!8);
	sig = sig*amp;
	sig = Splay.ar(sig) * 0.5;
	Out.ar(0, sig);
}).add;
)
