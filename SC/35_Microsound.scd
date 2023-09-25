// Dennis Gabor, Iannis Xenakis
// Microdsound (Roads, 2001a)
// Particle-based synthesis

// Gaussian distribution function 高斯函数


// micro time scale  eg. 100ms

// Herbert Brün: Sawdust (1976), G.M.Koenig:  SSP (1970s), Iannis Xenakis: Stochastic Synthesis(1971)


//Perception at the Micro Time scale
// puses repeating at less than about 16Hz will appear to most listeners as individual pulses, while pulses at 30 Hz fuse into continuous tones.

{ Impulse.ar(XLine.kr(12,48,6,doneAction:2))*0.1!2 }.play;// up
{ Impulse.ar(XLine.kr(48,12,6,doneAction:2))*0.1!2 }.play;// down

{ Impulse.ar(MouseX.kr(12,48,1))*0.1!2 }.play;// mouse-controlled


//temporal integration: very short grains seem softer than longer ones

Pbindef(\grain,
	\instrument, \gabor1, \freq,1000, \dur,1,
	\sustain, Pseq([0.001, 0.1], inf),
	\amp, Pseq([0.1, 0.1], inf)
).play;

//short grain 2x louder

Pbindef(\grain, \sustain, Pseq([0.001, 0.1], inf), \amp,Pseq([0.2, 0.1], inf));

//short grain 4x louder

Pbindef(\grain, \sustain, Pseq([0.001, 0.1], inf), \amp,Pseq([0.4, 0.1], inf));

//--------- Short grain durations, transition from pitched to colored clicks

(
// a gabor gain, gaussian-shaped envelope
SynthDef(\gabor, { |out, freq = 440, sustain = 1, pan, amp = 0.1, width = 0.25|
	var env = LFGauss.ar(sustain, width, loop: 0, doneAction:2);
	var son = FSinOsc.ar(freq, 0.5pi, env);
	OffsetOut.ar(out, Pan2.ar(son, pan, amp));
} ,\ir!6).add;

// or an approximation with a sine-shaped envelope
SynthDef(\gabor1, { |out, amp = 0.1, freq = 440, sustain = 0.01, pan|
	var snd = FSinOsc.ar(freq);
	var env = EnvGen.ar(Env.sine(sustain, amp), doneAction:2);
	OffsetOut.ar(out, Pan2.ar(snd* env, pan));
} ,\ir!5).add;
)

(
Pbindef(\grain,
	\instrument, \gabor, \freq, 1000,
	\dur, 0.5, \sustain,20/1000, \amp, 0.2
).play;
)

Pbindef(\grain, \sustain, 10/Pkey(\freq));
Pbindef(\grain, \sustain, 5/Pkey(\freq));
Pbindef(\grain, \sustain, 3/Pkey(\freq));
Pbindef(\grain, \sustain, 2/Pkey(\freq));
Pbindef(\grain, \sustain, 1/Pkey(\freq));

//successively shorter, end
Pbindef(\grain, \sustain, Pseq((10..1))/Pkey(\freq)).play;

//random drift of grain duration
Pbindef(\grain, \sustain, Pbrown(1, 10, 3)/Pkey(\freq), \dur, 0.1).play;




//-------------------------------- Perception of short silences
//on steady tones, short pauses seem like dark pulses; only longer ones seem like silences; and short interruptions on noisier signals may be inaudible

{EnvGen.ar(
		Env([0, 1, 1, 0, 0, 1, 1, 0], [0.01, 2, 0.001, 0.01, 0.001, 2, 0.01]),
	doneAction:2) ! 2}.plot(duration:10)

(
p = ProxySpace.push;

~source = {SinOsc.ar*0.1};
~silence = {|silDur = 0.01|
	EnvGen.ar(
		Env([0, 1, 1, 0, 0, 1, 1, 0], [0.01, 2, 0.001, silDur, 0.001, 2, 0.01]),
		doneAction:2) ! 2
};

~listen = ~source * ~silence;
~listen.play;
)

~silence.spawn([\silDur, 0.001]); //sounds like an added pulse
~silence.spawn([\silDur, 0.003]);
~silence.spawn([\silDur, 0.01]);
~silence.spawn([\silDur, 0.03]);

// try the same examples with noise:
~source = {WhiteNoise.ar * 0.1};

p.pop


//--------------------------------Order confusion with sounds in fast succession
(
// a simple percussive envelope

SynthDef(\percSin, {|out, amp = 0.1, freq = 440, sustain = 0.01, pan|
	var snd = FSinOsc.ar(freq);
	var env = EnvGen.ar(
		Env.perc(0.1, 0.9, amp), timeScale:sustain, doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(snd*env, pan));
},\ir!5).add;
)

(
Pbindef(\lo,
	\instrument, \percSin, \sustain, 0.05,
	\freq, 250, \amp, 0.2, \dur, 0.5, \lag, 0
).play;
Pbindef(\hi,
	\instrument, \percSin, \sustain, 0.05,
	\freq, 875, \amp, 0.1, \dur, 0.5, \lag, 0
).play;
)

//try different lag times between them
Pbindef(\hi, \lag, 0.1);
Pbindef(\hi, \lag, 0.03);
Pbindef(\hi, \lag, 0.01);
Pbindef(\hi, \lag, 0.003);

//hi too early or too late by a fixed time- which one is first;

Pbindef(\hi, \lag, ([-1, 1].choose*0.01).postln).play;
Pbindef(\hi, \lag, ([-1, 1].choose*0.02).postln);

//is it easier to hear when the sounds are panned apart?
Pbindef(\hi, \pan, 0.5);
Pbindef(\hi, \pan, 0);

Pbindef(\lo, \pan, -0.5);
Pbindef(\lo, \pan, 0);



//------- Multiple grains fuse into one composite
//in fast sequences of granular sounds, order is hard to discern, as the grains fuse in to 1 sound object. but when the order changes, the new composite does sound different
(
Pbindef(\grain4,
	\instrument, \percSin, \sustain, 0.03, \amp, 0.2,
	\freq, Pshuf([1000, 600, 350, 250]), //random every each time
	\dur, 0.005
).play;

//repeat grain cluster
Tdef(\grain, {loop{Pbindef(\grain4).play; 1.wait}}).play;
)

//fixed order
Pbindef(\grain4, \freq, Pseq([1000, 600, 350, 250].scramble))

//different order every time
Pbindef(\grain4, \freq, Pshuf([1000, 600, 350, 250]))
















