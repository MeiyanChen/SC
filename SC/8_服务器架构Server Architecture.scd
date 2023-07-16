s.boot;
s.plotTree;
s.meter(8,8);


//许多synth同时运行，互相接入信号    参考资料 server architecture
/* Nodes节点，网点, Busses总线, Order of Execution 执行顺序

Node 抽象的class对象，代表音频服务器的模件。 通常不直接使用node， 而是它下分类的两个对象[Synth, Group]
bus 通常用来接入信号到synth，就是送出bus中的信号，利用这个信号， 然后通过读取bus, 作为输入进入到另一个synth

*/


(
SynthDef.new(\blip, {  //声音
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300, 1200).round(300);
	sig = SinOsc.ar(freq)* 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	Out.ar(out, sig);  // out为0的话，输出声音到左声道。 但可以自行定义输出地点。
}).add;

SynthDef.new(\reverb,{  //混响
	arg in, out = 0; //需要听到的声音
	var sig;
	sig = In.ar(in, 1);
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2)!2; // 干：没有混响， 湿：有混响
	Out.ar(out, sig);
}).add;
)

/* 怎么理解总线和通道：  通道有输出和输入，总线没有。
--> Audio bus: In audio engineering, a bus[1] (alternate spelling buss, plural busses) is a signal path which can be used to combine (sum) individual audio signal paths together. It is used typically to group several individual audio tracks which can be then manipulated, as a group, like another track. This can be achieved by routing the signal physically by ways of switches and cable patches on a mixing console, or by manipulating software features on a digital audio workstation (DAW).

Using busses allow the engineer to work in a more efficient way and with better consistency, for instance to apply sound processing effects and adjust levels for several tracks at a time.


--> Audio Channel: A channel is a representation of sound coming from or going to a single point. A single microphone can produce one channel of audio, and a single speaker can accept one channel of audio, for example.

A digital audio file can contain multiple channels of data. Music that is mixed for headphone listening is saved as a file with two channels - one sent to the left ear, one sent to the right, while surround-sound movie audio is often mixed for 6 channels.
*/


s.options.numAudioBusChannels;
s.options.numOutputBusChannels; // 0-7 输出信号
s.options.numInputBusChannels; //8-15 输入信号

//16 以后为private busses， internal routing audio signal between synth

s.options.numOutputBusChannels = 4; // 0-3 ->hardware output
s.options.numInputBusChannels = 2; // 4-5 ->hardware input , 6+ -> private busses

s.reboot;
s.meter;

y = Synth.new(\reverb, [\in, 6]); //The index of the bus to read in from.
x = Synth.new(\blip, [\out, 6]);
x.set(\out, 25);
y.set(\in, 25);  //输出和输入的总线索引应当一致

x.free;
y.free;

s.freeAll; //让声音突然消失

~reverbBus = Bus.audio(s, 1);//由于纯数字的总线索引可能与硬件输入输出的索引想混淆，因此，可以利用bus这个对象，来定位指定的bus
~reverbBus.index; //when use bus object to allocate audio bus, sc will always choose lowest available bus that doesn't conflict with hardware busses

// 因为前面已经指定了硬件输入和输出为索引0 - 5， 因此bus索引会从6开始算

y = Synth.new(\reverb, [\in, ~reverbBus.index]);
x = Synth.new(\blip, [\out, ~reverbBus.index]);
//可简化为
y = Synth.new(\reverb, [\in, ~reverbBus]);
x = Synth.new(\blip, [\out, ~reverbBus]);



//如何在总线中处理多通道扩展----------

(
SynthDef.new(\blip, {
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300, 1200).round(300);
	sig = SinOsc.ar(freq)* 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	sig = Pan2.ar(sig, LFNoise1.kr(10));   //monophonic signal across stereo field
	Out.ar(out, sig);
}).add;

SynthDef.new(\reverb,{
	arg in, out = 0;
	var sig;
	sig = In.ar(in, 2); //需要读取2个通道的声音
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2); // 干：没有混响， 湿：有混响。 由于声音已经为双声道，因此不用！2.
	Out.ar(out, sig);
}).add;
)


~reverbBus2 = Bus.audio(s, 2); //分配两个通道,占用两个索引
~reverbBus3 = Bus.audio(s, 1);

~reverbBus2.index;


y = Synth.new(\reverb, [\in, ~reverbBus2]);
x = Synth.new(\blip, [\out, ~reverbBus2]);

//when we output multichannel signal to a signal bus, SC distribute the remaining audio channels on consecutive ascending（连续升序） busses.

//确保通道数量与总线数量相符，并不能占用错误的通道



//------------------------------ 搜索参考资料 Order of execution：执行顺序   source -> effect
/*
if you have a synth on the server (i.e. an "effect") that depends on the output from another synth (the "source"), the effect must appear later in the chain of nodes on the server than the source.

head to tail / top to bottom
*/

y = Synth.new(\blip, [\out, ~reverbBus2]); // head
x = Synth.new(\reverb, [\in, ~reverbBus2]); // tail

//------------------------group -> a collection of nodes in a specific order, the nodes inside of a group can be either synth, or groups or some kind of combination.

//when we add a synth node to the server, it will appear a white rectangle.
//when we add a group node to the server, it will appear a grey rectangle.
// the lager grey rectangle represent the default group, which is created when the server is built.


g = Group.new;
x.free;
g.free;

 // 参考synth定义 ->target, addAction (where to place the node, reative to the target )


y = Synth.new(\reverb, [\in, ~reverbBus2, s, \addToTail]);
x = Synth.new(\blip, [\out, ~reverbBus2, s]); // target 为本地服务器

x = Synth.new(\blip, [\out, ~reverbBus2]);
y = Synth.new(\reverb, [\in, ~reverbBus2], x , \addAfter);

x.free;
y.free;

// after, before, head, tail, replace  -> works for nodes, also for groups

x = Synth.before(y, \blip, [\out, ~reverbBus2]);

//-------------------------------- since the sound source always need to appear before the effect, you can create a group for the sources, and a group for the effects

~sourceGrp = Group.new;  // 声音来源组
~fxGrp = Group.after(~sourceGrp); // 音效组

x = Synth.new(\blip, [\out, ~reverbBus2], ~sourceGrp);
y = Synth.new(\reverb, [\in, ~reverbBus2], ~fxGrp);   //只要组设置了正确顺序， 声音就能发声



//--------------------------------

(
SynthDef.new(\blip, {
	arg out, fund = 300, dens = 2, decay = 0.2;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(fund, fund*4).round(fund); //round 四舍五入
	sig = SinOsc.ar(freq)* 0.25;
	trig = Dust.kr(dens);
	sig = sig * EnvGen.kr(Env.perc(0.01, decay), trig);
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out, sig);
}).add;

SynthDef.new(\reverb,{
	arg in, out = 0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);
	Out.ar(out, sig);
}).add;
)

(
8.do{
	Synth.new(
		\blip,
		[
			\out, ~reverbBus2,
		    \fund, exprand(60, 300).round(30)
	    ],
	    ~sourceGrp
);
}

)

~sourceGrp.set(\decay, 0.03); //同时给多个声音，设定参数
~sourceGrp.set(\decay, 0.25);

~sourceGrp.freeAll;



