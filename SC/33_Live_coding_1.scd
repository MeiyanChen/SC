// two way to start with livecoding: 1. with blank sheet. 2. planed structure


//Reference: JITLib (Just in Time library). it's a collection of classes and methods which are highly optimized for live coding

// NodeProxy, Ndef, ProxySpace

//all three of these involve the use of what are called Nodeproxy. we use it explicitly here Ndef that is sort of a wrapper which stores NodeProxy in a dictionary.  ProxySpace is kind of transforms the environment of supercollider into a space where everything is a NodeProxy but a proxy the word that these documents most often use to describe what a proxy is placeholder 占位符.

// a node proxy is basically an object which keeps a reference to a reserved space where a node may or may not exist and proxies allow us to manipulate and use and do operations with objects which may not actually exist yet or may not have a value

//we can actually sort of create them and then define what they actually sound like after they're already playing

s.options.sampleRate = 48000;
s.boot;

{PinkNoise.ar(0.1!2)}.play;

//////////////////
//NodeProxy

n = NodeProxy.new(s, \audio, 2);
e = NodeProxy.new(s, \audio, 2);
n.play;
e.play;

//if we change the definition while it's playing it just kind of replaces the old one rather than creating a second one

n.source = {LFTri.ar([300,302]) * 0.9};
n.source = {LFTri.ar([300,302] * 0.5) * 0.06 * SinOsc.kr(0.5).range(0.2,0.8)};
n.source = {BPF.ar(PinkNoise.ar(0.5!2), 500, 0.1, 2)};
n.source = nil;

//release/create monitoring process
n.stop;
n.play;

//what's specifically play and stop do is that they create and destroy the monitoring process and that's the system audio link.  When you play them, they play out to a private bus. they don't go straight to hardware. they go to a private bus and there's automatically a monitoring synth the number of which depends on the number of channels. and they listen on that private bus and play out to hardware. So by stopping and playing a NodeProxy, we're really doing is destroying and creating this monitoring process. so  "play" in this context means playing two hardware so we can stop and play that right as far as the actual source process

//release/create source process
n.release;
n.release(12);
n.send;

//end both processes
n.end;
n.play;

//end and reset proxy to neutral state
// there is clear which is similar to "end". but it will also reset the NodeProxy's source to a neutral state. so if we try to play it again, we don't hear anything. because it also has the effect of just resetting the nodeproxy to a state where it's like we've never used it

n.clear;
n.clear(15); // a amount of time to fade it out before the actual removal of those nodes




/////////////////////
//fade times
//it doesn't do any sort of magical crossfading inside the source function. all it's doing is making a new source node and just applying a sort of linear fade with a duration determined by the fade time. while simultaneously fading out the previous node, so there's a period of time equal to the fade time in which both nodes both source nodes exist and one of them is fading in and one of them is fading out

n.fadeTime;
n.fadeTime_(5);
n.fadeTime;

n.source = {LFTri.ar([300,302] * 0.5) * 0.06 * SinOsc.kr(0.5).range(0.2,0.8)};
n.source = {LFTri.ar([300,302]) * 0.06 * SinOsc.kr(0.5).range(0.2,0.8)};
n.source = {LFTri.ar([300,302] * -2.midiratio) * 0.06 * SinOsc.kr(0.5).range(0.2,0.8)};
n.source = nil;

////////////////
//rhythm and quantizing

n.fadeTime_(0.02);
n.source = {LFTri.ar([300,302] * 3.midiratio) * 0.1 * LFPulse.kr(4, 0, 0.1)};
n.source = nil;

t = TempoClock.new(84/60).permanent_(true);
t.tempo;
t.beatDur;

(
n.source = {
	var sig, f; // f is the appropriate frequency for something that happens once per beat
	f = t.tempo;
	sig = LFTri.ar([300,302] * 5.midiratio);
	sig = sig * 0.1;
	sig = sig * LFPulse.kr(f*2, 0, 0.1)
};
)

n.source = nil;

n.clock_(t); // the clock it's using for any quantization is that tempo clock t that we've made
n.quant_(4); //a value in beats
//whenever we change the source function that change will be quantized to the nearest beat that is a the nearest multiple of 4 beat so some beat that divides by 4 evenly


(
n.source = {
	var sig, f;
	f = t.tempo; // 1/t.beatDur
	sig = LFTri.ar([300,302] * 5.midiratio);
	sig = sig * 0.1;
	sig = sig * LFPulse.kr(f*2, 0, 0.1) //two pulses per beat
};
)

n.fadeTime_(5);

n.source = nil;

/////////////////////////////////////
//Ndef

n.clear;

Ndef(\n).play;
Ndef(\n).fadeTime_(4);
Ndef(\n).clock_(t);
Ndef(\n).quant_(1);

(
Ndef(\n, {
	var sig, f;
	f = t.tempo;
	sig = PinkNoise.ar(0.5!2);
	sig = BPF.ar(sig, SinOsc.kr(f/1).exprange(200,2000), 0.1, 2); //a sine wave which is going up and down at one one cycle per second
	sig = sig * LFPulse.kr(f*2, [0,0.1], 0.8);
});
)

Ndef(\n, { }); // to stop the sound
Ndef(\n).clear;

(
//proxy attributes can be strung together in a single code expression
Ndef(\n)
.fadeTime_(4)
.clock_(t)
.quant_(1)
.play;
)

/////////////////////////////
//ProxySpace

~a = 5;
~b = 7;

// using these tilde things which we call global variables and we just sort of take this for granted and rightfully. so because it's extremely convenient. it allows us to create a name create store a value in a persistent name that we can keep forever.We call these global variables, but they're not actually global. they are specific to a particular environment and when we launch supercollider we start it up for the first time, there is something called "the current environment". it's an instance of an environment that is automatically created for us and this tilde business is basically a syntax shortcut for putting a value in the current environment at the name uh designated by the thing that comes after the tilde


true
false
nil
thisProcess
currentEnvironment;
//this is a special a special keyword that refers to the current environment

//check reference: syntax shortcut
~x = 17;

\lunch.envirPut("pizza");

currentEnvironment;


~lunch

e = Environment.new; //make a new environment
e.push; // push the new environment as the current environment

currentEnvironment;

~k = 8;
~drink = "orange fanta";

currentEnvironment;

e;

e.pop; // show the old environment, and make it as the current one

currentEnvironment;

currentEnvironment.keys.do({arg key; currentEnvironment.removeAt(key)});

~lunch

currentEnvironment;
//ProxySpace is a special type of environment in which every tilde thing is a nodeproxy. so this eliminates the need of having to type out NodeProxy or Ndef we can just give things names and work with them directly

(
//create clock if one does not already exist
t = TempoClock.new(84/60).permanent_(true);
p = ProxySpace.new(s, clock:t);
p.quant_(4);
p.push;
) //inside a ProxySpace, every environment variable is a NodeProxy

currentEnvironment;


~sig;
~sig.play;

~sig = {PinkNoise.ar(0.1!2)};
~sig = nil;

~sig.fadeTime_(4);

~sig.clock; //because we gave the ProxySpace a clock all of the NodeProxy objects in this ProxySpace inherit that clock. so they're all on that clock value
~sig.quant;
~sig.quant_(0.5);

~sig2;
~sig2.quant;

p.clear;


//------

(
SynthDef.new(\filtsaw, {
	var sig, env;
	sig = VarSaw.ar(\freq.kr(100), Rand(0.0,1.0), 0.001);
	sig = RLPF.ar(sig, \cf.kr(500), \rq.kr(0.5));
	env = Env.perc(\atk.ir(0.002), \rel.ir(0.3)).ar(2);
	sig = sig * env;
	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.2));
	Out.ar(\out.ir(0), sig);
}).add;
)

(
x = Pbind(
	\instrument, \filtsaw,
	\dur, 0.25,  //when we play a pattern, if we play it on a particular clock this "dur" value is interpreted as a value in beats not seconds
	\midinote, Pseq([28,28,40,28,40],inf) + [0,0.1],
	\cf, (Pkey(\midinote).midicps * 8).min(20000),
	\rq, Pexprand(0.1,0.5,inf),
	\pan, Pwhite(-0.2,0.2,inf),
).play;
)

x.stop;

~pat.play;

~pat.clock.tempo;
~pat.quant;

~pat.fadeTime_(1);

//Pbind is also a valid source for a NodeProxy
//dur value is automatically treated as beats on ProxySpace's clock
//EventStreamPlayer is automatically quantized based on ProxySpace's global quant value

(
~pat = Pbind(
	\instrument, \filtsaw,
	\dur, Prand([0.25,0.5],inf),
	\midinote, Pseq([28,28,40,28,40],inf) + [0,0.2] + Prand([12,0],inf),
	\cf, (Pkey(\midinote).midicps * 8).min(20000),
	\rq, Pexprand(0.1,0.5,inf),
	\pan, Pwhite(-0.2,0.2,inf),
);
)

// change the values in real time

~pat = nil;

