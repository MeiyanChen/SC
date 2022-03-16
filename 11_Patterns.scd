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
Pdef(
	\sinepat,
  Pbind(
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),
		\midinote, Pseq([33], inf).trace, // 29, 35
	\harmonic, Pexprand(1, 80, inf).round.trace, //1, 10
	\atk, Pwhite(2.0, 3.0, inf),
	\rel, Pwhite(5.0, 10.0, inf),
	\amp,Pkey(\harmonic).reciprocal * 0.3,
	\pan, Pwhite(-0.8, 0.8, inf),
).play;
)
)


//------------------------------------------------
(
d = Dictionary.new;
d.add(\l ->
	PathName().entries.collect({
		arg sf;
		Buffer.read(s, sf.fullpath);
	})
	);

d.add(\m ->
	PathName().entries.collect({
		arg sf;
		Buffer.read(s, sf.fullpath);
	})
	);

d.add(\h ->
	PathName().entries.collect({
		arg sf;
		Buffer.read(s, sf.fullpath);
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
		\buf, Prand(d[\l]++d[\m]++d[\h], inf), //Prand(d[\l], inf)
		\rate,1,
		\amp, 0.5,
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
		\buf, Prand(d[\l]++d[\m]++d[\h], inf), //Prand(d[\l], inf)  /  Pxrand
		//\buf, Pwrand(d[\l][0], d[\m][0], d[\h][0], [0.8, 0.15, 0.05], inf),
		//\buf, Pwrand(d[\l][0], d[\m][0], d[\h][0], [8, 2, 1].normalizeSum.postln, inf),
		\rate,1,
		\amp, 0.5,
		// \amp, Pseq([0.8, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1], inf), // \amp, Pseq([0.8]++(0.1!7), inf)
		// \amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
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
			[   Prand(d[\l], 1),
				Prand(d[\l]++d[\m]++d[\h], 7),
				Prand(d[\h],1),
				Prand(d[\l]++d[\m]++d[\h], 7),
			], inf
		),
		\rate,Pexprand(0.8, 1.25, inf),
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
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
			[   Prand(d[\l], 1),
				Prand(d[\l]++d[\m]++d[\h], 7),
				Prand(d[\h],1),
				Prand(d[\l]++d[\m]++d[\h], 7),
			], inf
		),
		\rate,Pexprand(4.0, 4.1, inf), // \rate,Pexprand(0.8, 1.25, inf),
		\amp, Pseq([0.8, Pexprand(0.005, 0.2, 7)], inf),
	);
)quant_(1.875); // .play(quant:1.875);
)

(
Pdef(
	\sinepat,
  Pbind(
	\instrument, \sine,
	\dur, Pseq([1/16], inf),
	\stretch, 1.875,
    \note, Pxrand(0.3, 5, 9, 10, 12], inf),
	// \gtranspose, -9,
	\atk, 0.005,
	\rel, Pexprand(0.01, 0.5, inf),
	\amp,Pexprand(0.05, 0.5, inf),
	\pan, Pwhite(-0.8, 0.8, inf),
).play;
)
)


Pdef(\rhythm).stop;
Pdef(\sinepat).stop;

