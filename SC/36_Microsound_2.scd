s.options.sampleRate = 48000;
s.boot;


// Grains and Clouds
// any sound particle shorter than about 100 ms can be considered a grain and can be used for creating groups of sound particles.

// Such groups may be called streams or trains, if they comprise regular sequences, or clouds, if they are more varied.

// a grain = a waveform or an envelope

e = Env.sine.asSignal(400).as(Array); // create an envelope and a waveform signal as arrays.
w = Array.fill(400, {|i| (i * 2pi/40).sin});

g = e * w;
[e, w, g].flop.flat.plot("envelope, wave, grain", Rect(0, 0, 408, 600), numChannels:3);

// Env.sine is close to a Gaussian envelop, providing resonable approximations of soundn quanta as postulated by Gabor.


//creating many vairant of 1 kind of grain by varying waveform, frequency, grain duration, amplitude, and spatial position

(
SynthDef(\gabor0, { |out, freq = 440, sustain = 0.02, amp = 0.2, pan|
	var env = EnvGen.ar(Env.sine(sustain, amp), doneAction:2);
	var sound = SinOsc.ar(freq)*env;
	OffsetOut.ar(out, Pan2.ar(sound, pan))
}, \ir.dup(5)).add;
)
// OffsetOut to start the grain's synthesis process with single-sample accuracy


Synth(\gabor0); // test with synth
Synth(\gabor0, [\freq, 1000, \sustain, 0.005, \amp, 1, \pan, 0.5]);

(instrument:\gabor0).play; // test with event
(instrument:\gabor0, sustain: 0.001, freq: 2500, amp:1, pan:-0.5).play;

Synth.grain(\gabor0, [\freq, 2000, \sustain, 0.003]) // higher efficiency, as no NodeID is kept.   Synth.grain creates nodes without nodeIDs

s.sendMsg("s_new", \gabor0, -1, 0, 0, \freq, 2000, \sustain, 0.003); //even more efficient, as no synth object is created.    it does not create any language side Synth object, but directly messages the Server


//--------------------------------------
//making different envelope shapes

Env.sine.plot; //approx. gaussian

Env([0, 1, 1, 0], [0.25, 0.5, 0.25]* 0.1, \sin).test.plot;
// quasi-gaussian

Env([0, 1, 1, 0], [0.25, 0.5, 0.25]* 0.1, \lin).test.plot;
//3 stage line segments.

Env([0, 1, 1, 0], [0.25, 0.5, 0.25]* 0.1, \welch).test.plot;
//welch curve interpolation


Env([1, 0.001], [0.1], \exp).test.plot; // expoDec (exponential decay);

Env([0.001, 1], [0.1], \exp).test.plot; // revExpoDec (reverse expoetial decay);

Env.perc(0.01, 0.09).test.plot;

(
//a sinc function envelope
q = q ? (); //If the receiver is nil then answer an Object, check in Object Nil, replace q with ()
q.makeSinc = {|q, num = 1, size = 400|
	dup({|x| x = x.linlin(0, size-1, -pi, pi) * num; sin(x)/x}, size);
};
a = q.makeSinc(6);
a.plot(bounds: Rect(0, 0, 409, 200), minval: -1, maxval: 1);
)
// can be created with sampled mathematical functions or taken from recorded material and played with buffers.

//-----------------------------------------

(
// a gabor (approx.gaussian-shaped) grain
SynthDef(\gabor1, {|out, amp = 0.1, freq = 440, sustain = 0.01, pan|
	var snd = FSinOsc.ar(freq);
	var amp2 = amp*AmpComp.ir(freq.max(50)) * 0.5;
	var env = EnvGen.ar(Env.sine(sustain, amp2), doneAction:2);
	OffsetOut.ar(out, Pan2.ar(snd * env, pan));
}, \ir!5).add;

//wider, quasi-gaussian envelope, with a hold time in the middle.
SynthDef(\gabWide, {|out, amp = 0.1, freq = 440, sustain = 0.01, pan, width = 0.5|
	var holdT = sustain * width;
	var fadeT = 1 - width * sustain* 0.5;
	var snd = FSinOsc.ar(freq);
	var amp2 = amp * AmpComp.ir(freq.max(50)) * 0.5;
	var env = EnvGen.ar(Env([0, 1, 1, 0], [fadeT, holdT, fadeT], \sin),
		levelScale: amp2,
		doneAction:2);

	OffsetOut.ar(out, Pan2.ar(snd * env, pan));
}, \ir ! 6).add;

//a simple percussive envelope
SynthDef(\percSin, {|out, amp = 0.1, freq = 440, sustain = 0.01, pan|
	var snd = FSinOsc.ar(freq);
	var amp2 = amp * AmpComp.ir(freq.max(50)) * 0.5;
	var env = EnvGen.ar(
		Env.perc(0.1, 0.9, amp2),
		timeScale:sustain,
		doneAction:2);
	OffsetOut.ar(out, Pan2.ar(snd * env, pan));
}, \ir!5).add;

// a reversed percussive envelope

SynthDef(\percSinRev, {|out, amp = 0.1, freq = 440, sustain = 0.01, pan|
	var snd = FSinOsc.ar(freq);
	var amp2 = amp * AmpComp.ir(freq.max(50)) * 0.5;
	var env = EnvGen.ar(
		Env.perc(0.9, 0.1, amp2),
		timeScale:sustain,
		doneAction:2);
	OffsetOut.ar(out, Pan2.ar(snd * env, pan));
}, \ir!5).add;


//an exponential decay envelope
SynthDef(\expodec, {|out, amp = 0.1, freq = 440, sustain = 0.01, pan|
	var snd = FSinOsc.ar(freq);
	var amp2 = AmpComp.ir(freq.max(50)) * 0.5 *amp;
	var env = XLine.ar(amp2, amp2 * 0.001, sustain, doneAction:2);
	OffsetOut.ar(out, Pan2.ar(snd * env, pan));
}, \ir!5).add;


//a reversed exponential decay envelope
SynthDef(\rexpodec, {|out, amp = 0.1, freq = 440, sustain = 0.01, pan|
	var snd = FSinOsc.ar(freq);
	var amp2 = amp * AmpComp.ir(freq.max(50)) * 0.5;
	var env = XLine.ar(amp2 * 0.001, amp2, sustain, doneAction:2) * (AmpComp.ir(freq) * 0.5);
	OffsetOut.ar(out, Pan2.ar(snd * env, pan));
}, \ir!5).add;
)





//---------------------------------------------------
//changing grain duration, frequency, envelope
(
Pbindef(\grain0,
	\instrument, \gabor1, \freq, 500,
	\sustain, 0.01, \dur, 0.2
).play;
)

//change grainn durations
Pbindef(\grain0, \sustain, 0.1);
Pbindef(\grain0, \sustain, 0.03);
Pbindef(\grain0, \sustain, 0.01);
Pbindef(\grain0, \sustain, 0.003);
Pbindef(\grain0, \sustain, 0.001);
Pbindef(\grain0, \sustain, Pn(Pgeom(0.1, 0.9, 60)));
Pbindef(\grain0, \sustain, Pfunc({exprand(0.0003, 0.03)}));
Pbindef(\grain0, \sustain, 0.03);

// change grain waveform (sine) frequency
Pbindef(\grain0, \freq, 300);
Pbindef(\grain0, \freq, 1000);
Pbindef(\grain0, \freq, 3000);
Pbindef(\grain0, \freq, Pn(Pgeom(300, 1.125, 32)));
Pbindef(\grain0, \freq, Pfunc({exprand(300, 3000)}));
Pbindef(\grain0, \freq, 1000);

//change synthdef for different envelopes
Pbindef(\grain0, \instrument, \gabor1 );
Pbindef(\grain0, \instrument, \gabWide);
Pbindef(\grain0, \instrument, \percSin);
Pbindef(\grain0, \instrument, \percSinRev);
Pbindef(\grain0, \instrument, \expodec);
Pbindef(\grain0, \instrument, \rexpodec);
Pbindef(\grain0, \instrument, Prand([\gabWide, \percSin, \percSinRev], inf));





































