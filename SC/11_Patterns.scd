//Patterns provide a means of sequencing data through algorithmic and computational process.
// 用于sequence synth, MIDI data, graphical interfaces...
//参考资料  Browse -> Stream-Patterns-Events -> A-Practical Guide
//                                          -> Understanding -Streams-Patterns-and-Events

s.boot;

(
SynthDef.new(\sine,{
	arg freq = 440, atk = 0.005, rel = 0.3, amp = 1, pan = 0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0, 1, 0], [atk, rel], [1, -1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp); // stereo
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

Synth.new(\sine);


//what is event？  -> Pattern Guide 08: Event Types and Parameters
//Use Pbind to seuquence note events---------------------------------------
//参考资料： Pbind -> SynthDef and Event

(
p = Pbind(  // responds to the play message by generating a sequence of events 通过play来产生序列事件
	\type, \note,  // generates a synth on the audio server 在服务器上产生synth
	\instrument, \sine,
).play;
)

//Pbind().play  returns an event stream player, it is the object that acutally generates the events
s.plotTree;

p.stop;


(
p = Pbind(  // pbind expects a series of symbol(key) value pairs
	\type, \note, //事件类型决定了之后所采用的序列事件
	\instrument, \sine,
	\dur, 0.5,   //默认音高为中央c， 音量为0.1
).play;
)

//note为默认的事件类型，因此如用note事件时，可略写
//事件流需要在一定的时间内完成，每一个连续的事件发生的时间是可控的（delta time 增量时间）
// Pseq按前后顺序
(
p = Pbind(
	\instrument, \sine, // synthdef里的变量也可作为key 使用
	\dur, Pseq([0.6, 0.15, 0.15], inf).trace,  //以秒为单位， 默认为每秒一synth
	\freq, Pseq([330, 247, 370], inf).trace, //trace可用于调试或可视化数据
).play;
)

(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], 4).trace,  //会播放8个音
	\freq, Pseq([330, 247, 370, 220], 2).trace,
).play;
)

(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], inf).trace,
	\freq, Pseq([60, 65, 67, 74].midicps, inf).trace,  // \midinote, Pseq([60, 65, 67, 74], inf),
).play;
)
//there is a hierarchy of predefined keys for certain events, 某些事件有一个预定义键的层次结构， 使用时必须按默认名称

//**********

(
SynthDef.new(\sinetest,{
	arg hz = 440, atk = 0.005, rel = 0.3, amp = 1, pan = 0;
	var sig, env;
	sig = SinOsc.ar(hz);
	env = EnvGen.kr(Env.new([0, 1, 0], [atk, rel], [1, -1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

(
p = Pbind(
	\instrument, \sinetest,
	\dur, Pseq([0.6, 0.15, 0.15], inf).trace,
	\hz, Pseq([330, 247, 370], inf).trace,  //根据声音变量调整
).play;
)



//**************
(
p = Pbind(
	\instrument, \sine,
	\dur, Pseq([0.6, 0.15, 0.15], inf), // 控制节拍
	\freq, Pexprand(50, 4000, inf).trace,
).play;
)

(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf).trace,
	\freq, Pexprand(50, 4000, inf).trace,
	\atk, Pwhite(2.0, 3.0, inf), //让每个声音变长
	\rel, Pwhite(5.0, 10.0, inf),
	\amp, Pexprand(0.01, 0.2, inf),
	\pan, Pwhite(-0.8, 0.8, inf), //避免极左或极右
).play;
)

(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),
	\freq, Pexprand(50, 4000, inf).round(55).trace,
	\atk, Pwhite(2.0, 3.0, inf),
	\rel, Pwhite(5.0, 10.0, inf),
	\amp, Pexprand(0.01, 0.2, inf),
	\pan, Pwhite(-0.8, 0.8, inf),
).play;
)

//泛音-------
(
p = Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),
	\midinote, 33,
	\harmonic, Pexprand(1, 80, inf).round.trace,
	\atk, Pwhite(2.0, 3.0, inf),
	\rel, Pwhite(5.0, 10.0, inf),
	\amp,Pkey(\harmonic).reciprocal * 0.3,
	\pan, Pwhite(-0.8, 0.8, inf),
).play;
)




(
Pdef( // manipulate patterns in real time 在声音播放时，可实时更新各种参数
	\sinepat,
     Pbind(
	    \instrument, \sine,
		\dur, Pwhite(0.05, 0.5, inf),
		\midinote, Pseq([33], inf).trace, // 29, 35
		\harmonic, Pexprand(1, 80, inf).round, //1, 10
		\atk, Pwhite(2.0, 3.0, inf),
		\rel, Pwhite(5.0, 10.0, inf),
		\amp,Pkey(\harmonic).reciprocal * 0.3,
		\pan, Pwhite(-0.8, 0.8, inf),
).play;
)
)


//buffer playback------------------------------------------------
//将要用音频存入数据词库中，以便随时提用
//round robins(轮循) effects: https://musicalsanctuary.com/round-robins-what-are-they/
(
d = Dictionary.new;
d.add(\l ->
	PathName("/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Buffersound/Drum/Low/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	})
	);

d.add(\m ->
	PathName("/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Buffersound/Drum/Mid/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	})
	);

d.add(\h ->
	PathName("/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Buffersound/Drum/High/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	})
	);
)

d[\l].choose.play;


(
SynthDef.new(\sine,{
	arg freq = 440, atk = 0.005, rel = 0.3, amp = 1, pan = 0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0, 1, 0], [atk, rel], [1, -1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;

SynthDef.new(\bufplay, {
	arg buf = 0, rate = 1, amp = 1;
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.ir(buf)* rate, doneAction:2);
	sig = sig * amp;
	Out.ar(0, sig);
}).add;
)


Synth.new(\bufplay, [\buf, d[\m].choose.bufnum]);

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([0, 12], inf),
		\buf, Prand(d[\l]++d[\m]++d[\h], inf), //Prand(d[\l], inf) 可随机选择集合中的一个。 双加号将不同数列内容合成一个数列
		\rate,1,
		\amp, 0.5,
	);
).play; //stop;
)

60/128 *4;

//Nesting--------------
(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf), // 16分音符在4/4中播放
		\stretch, 60/100 *4, // 以 100bpm的速度 length in seconds of one bar of 4/4 at 128 bpm (60/128 bps, 4 beats per bar)
		\buf, Prand(d[\l]++d[\m]++d[\h], inf), //Prand(d[\l], inf)  /  Pxrand never choose the same value twice in a row
		//\buf, Pwrand(d[\l][0], d[\m][0], d[\h][0], [0.8, 0.15, 0.05], inf),  //random choice from a collection according to a second array of weights根据百分比重来随机选择
		//\buf, Pwrand(d[\l][0], d[\m][0], d[\h][0], [8, 2, 1].normalizeSum.postln, inf), //自动平衡比重    //Pshuf 不在连续随机选择中重复同一内容两次
		\rate,1,
		\amp, 0.5,
		// \amp, Pseq([0.8, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1], inf), // \amp, Pseq([0.8]++(0.1!7), inf)
		// \amp, Pseq([0.8, Pexprand(Prand([0.001, 0.002,0.003] inf), 0.2, 7)], inf), //除去开始的重音，后面7次都在设定范围内随机按指数趋势选择音量 // nest嵌套 pattern inside of one another  //https://en.wikipedia.org/wiki/Nesting_(computing)
	);
).play; //stop;
)


(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 60/128 *4,
		\buf, Pseq(
			[   Prand(d[\l], 1),  //第一拍
				Prand(d[\l]++d[\m]++d[\h], 7), //第二拍
				Prand(d[\h],1),  //第三拍
				Prand(d[\l]++d[\m]++d[\h], 7), //第四拍
			], inf
		),
		\rate,Pexprand(0.8, 1.25, inf), //改变了音频播放速度 导致节拍无法锁定
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
	);
).play; //stop;
)


//可将以下两个声音当作两个乐器同时播放，并随时调整参数
(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/16], inf),
		\stretch, 60/128 *4,
		\buf, Pseq(
			[   Prand(d[\l], 1),
				Prand(d[\l]++d[\m]++d[\h], 7),
				Prand(d[\h],1),
				Prand(d[\l]++d[\m]++d[\h], 7),
			], inf
		),
		\rate,Pexprand(4.0, 4.1, inf), // \rate,Pexprand(0.8, 1.25, inf),
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
	);
).play(quant:1.875); //quant_(1.875); 正在播放时如要改变，可用此形式
)

(
Pdef(
	\sinepat,
  Pbind(
	\instrument, \sine,
	\dur, Pseq([1/16], inf),
	\stretch, 1.875,
    \note, Pxrand([0, 3, 5, 9, 10, 12], inf),
	// \gtranspose, -9, //向下移调大六度
	\atk, 0.005,
	\rel, Pexprand(0.01, 0.5, inf),
	\amp,Pexprand(0.05, 0.5, inf),
	\pan, Pwhite(-0.8, 0.8, inf),
).play(quant:1.875);
)
)


Pdef(\rhythm).stop;
Pdef(\sinepat).stop;

