//MIDI = Music Instrument Digital Interface
//Guide -> Using MIDI  or  MIDI
// SC needs to connect with the MIDI functionality of the operating system

MIDIClient.init; //检测系统信息 输送midi 到连接界面
MIDIIn.connectAll; // 连接sc到所有midi设备


MIDIClient.sources; //检测到所有midi 设备
MIDIIn.connect(0); //输入索引，选择某个midi设备连接

//MIDIFunc / MIDIdef   不同写法，但作用相同  mididef is a subclass of midifunc, 用于发送和接收midi信息&数据

MIDIdef.noteOn(\noteOnTest, {"key down".postln}); //按键， 收到信息后，执行方程

MIDIdef(\noteOnTest).disable; //临时取消
MIDIdef(\noteOnTest).enable; //重新启用
MIDIdef(\noteOnTest).free; //停止和消除使用
MIDIdef.freeAll;


MIDIdef.noteOn(\noteOnTest, {"key down".postln}).permanent_(true); // ctrl+.  无法取消按键

MIDIdef(\noteOnTest).permanent_(false); // ctrl + . 可停止和消除midi按键

//When evaluated for noteOn, noteOff, control, and polytouch messages it will be passed the arguments val, num, chan, and src, corresponding to the message value (e.g. velocity, control value, etc.), message number (e.g. note number), MIDI channel, and MIDI source uid. For touch, program change and bend messages it will be passed only val, chan, and src.

(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src; // note velocity 音量, note number, midi channel, source device id设备来源（可用来区别别的设备）
	[vel, nn, chan, src].postln; // 一个midi数据线分配16个midi通道， 索引为0-15
});
)

(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;

	{
		var sig, env;
		sig = SinOsc.ar(nn.midicps)!2; //转化midi为freq
		env = EnvGen.kr(Env.perc, doneAction:2); // 声音自动停止，无法延续
		sig = sig * env * vel.linexp(1, 127, 0.01, 0.3); //转化midi音量为ugen音量。 并要避免同时触键时，音量太高   linexp -> simple number
	}.play;
});
)

s.boot;  //现在声音由sc控制

//---------------------------------------------------------------

(
SynthDef.new(\tone,{
	    arg freq = 440, amp = 0.3;
		var sig, env;
		sig = LFTri.ar(freq)!2;
		env = EnvGen.kr(Env.perc, doneAction:2);
	  	sig = sig * env *amp;
	    Out.ar(0, sig);
}).add;
)

Synth.new(\tone, [\freq, 700, \amp, 0.5]);


(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;

	Synth.new(\tone, [\freq, nn.midicps, \amp, vel.linexp(1, 127, 0.01, 0.3)]);
});
)

//-----------------------------------
(
SynthDef.new(\tone,{
	    arg freq = 440, amp = 0.3, gate = 0;
		var sig, env;
		sig = LFTri.ar(freq)!2;
		env = EnvGen.kr(Env.adsr, gate, doneAction:2); //adsr 延时声音， gate为0，释放声音； 为1，触发声音
	  	sig = sig * env *amp;
	    Out.ar(0, sig);
});
)

x = Synth.new(\tone, [\gate, 1]); //每个按键 声音将一直保持
x.set(\gate, 0);


~notes = Array.newClear(128);  // 128个可能的按键，

(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	~notes[nn] = Synth.new(   //储存声音在数列里，以索引的方式展现
		\tone,
		[
			\freq, nn.midicps,
			\amp, vel.linexp(1, 127, 0.01, 0.3),
			\gate, 1,
			//\bend,~bend.linlin(0, 16383, -2, 2),
	    ]
	);
});
)

(
MIDIdef.noteOff(\noteOnTest, {   //收键
	arg vel, nn;
	[vel, nn].postln;
	~notes[nn].set(\gate, 0); //每一个声音出现一次，就释放一次
	~notes[nn] = nil; //然后以nil代替声音
});
)


//-----------pitch bend
//The MIDI protocol specifies that a pitchbend value of 8192 (MSB of 64 and LSB of 0) means no bend. Thus, on the scale from 0 to 16,383, a value of 0 means maximum downward bend, 8,192 means no bend, and 16,383 means maximum upward bend. Almost all pitchbend wheels on MIDI controllers use a spring mechanism that has the dual function of a) providing tactile resistance feedback as one moves the wheel away from its centered position and b) snapping the wheel quickly back to its centered position when it’s not being manipulated.
//  https://en.wikipedia.org/wiki/Pitch_wheel
(
MIDIdef.bend(\bendTest, {
	arg val, chan, src;
	[val, chan, src].postln; //value 0-16383， 8192 at rest position
	~bend = val;
	~notes.do{arg synth; synth.set(\bend, val.linlin(0, 16383, -2, 2))};   // 确保更新每一个synth（按键）
}, chan:0);  //保证同一个声音通道出声
)

~bend = 8192;

nil.set(\freq, 880); // nil understands the set message， und responds to it by doing nothing

(
SynthDef.new(\tone,{
	    arg freq = 440, amp = 0.3, gate = 0, bend = 0;
		var sig, env;
		sig = LFTri.ar(freq * bend.midiratio)!2; // 半音转化为频率
		env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	  	sig = sig * env *amp;
	    Out.ar(0, sig);
});
)


(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	~notes[nn] = Synth.new(   //储存声音在数列里，以索引的方式展现
		\tone,
		[
			\freq, nn.midicps,
			\amp, vel.linexp(1, 127, 0.01, 0.3),
			\gate, 1,
			\bend,~bend.linlin(0, 16383, -2, 2), // 通知按键知晓 滑音 位置
	    ]
	);
});
)


// MIDIdef.cc










