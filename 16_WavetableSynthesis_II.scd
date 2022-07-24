s.options.sampleRate = 48000;

s.boot;
s.scope;
FreqScope.new;

//作业1. 用不同方法写波表，  2.用vosc写一个声音

// multiple wavetble synthesis

//smoothly transition form one wave table to another
//an oscillator has access to more than one wavetable


// we provide a floating point index between 0 & 1 and the oscillator will interpolate between these two tables according to the index. and if we use a line UGen or something similar to sweep from 0 to 1, we get a result where one wavetable morphs into another, this is what VOSC is designed to do


// generate two wavetable
(
~wt0 = Signal.sineFill(
	1024,
	1/(1..8),
	0!8
).asWavetable;

~wt1 = Signal.sineFill(
	1024,
	[1, 0, 1/2, 1, 1/4],
	[0, 0, pi, 0, pi]
).asWavetable;
)

~wt0.plot;
~wt1.plot;

(
~b0 = Buffer.loadCollection(s, ~wt0);  // load these two wavetable into buffer
~b1 = Buffer.loadCollection(s, ~wt1);
)

~b0.bufnum;
~b1.bufnum;

//like Osc, Vosc has an argument that tells it which buffer to use for wavetable information

// a quick sound funcion using VOsc

(
{
	var sig;
	sig = VOsc.ar(MouseX.kr(0, 1), 300, mul:0.2!2);  // mouseX with a range from 0 to 1, allowing us to sweep the mouse across the screen from left to right. causing wavetable 0 to morph (变化，变形) into wavetable 1
}.play;
)



//-----------

(
SynthDef.new(\vosc,{
	arg out = 0;
	var sig, bufpos;
	bufpos = MouseX.kr(0, 1);
	sig = VOsc.ar(bufpos, 300, mul:0.2!2);
	Out.ar(out, sig);
}).add;
)

Synth(\vosc);
s.freeAll;
buffer.freeAll
//1. all the buffers that VOsc uses have to be the same size. we can also confirm our wavetables of the same size by checking the number of frames in each buffer
~b1.numFrames;

// If accidentally mix and match wavetable size, then Vosc will fail silently. SC gives no feedback at all.

//2. it's not a really great idea to hardwire (硬接线) bufnums 0 and 1 into our synthdef

//3. Vosc assumes or requires that your wavetable indices are consecutive ascending numbers, in our case we allocated these two buffers back-to-back one right after the other, it won't be a problem.
//but if your buffers in a hapharzard (杂乱无章地) way, like if you scatter the process into smaller chunks across a larger project, you might inadvertently end up with non-consecutive wavetable buffers and Vosc won't be able to properly interpolate between them.

(
SynthDef.new(\vosc,{
	arg out = 0, buf = 0, numBufs = 2;  // buf = lowest bufnum
	var sig, bufpos;
	bufpos = buf + MouseX.kr(0, numBufs - 1); // caculate bufpos, this  keep the functionality the same, but it adds some valuable flexibility for which and how many wavetables we want to use
	sig = VOsc.ar(bufpos, 300, mul:0.2!2);
	Out.ar(out, sig);
}).add;
)

Synth(\vosc, [\buf, ~b0.bufnum, \numBufs, 2]); // the lowest bufnum, and the number of wavetables




// example for point 3
(
~b0 = Buffer.loadCollection(s, ~wt0);
Buffer.alloc(s, 2048); // load several empty buffers,  morphing from wavetable to silence
~b1 = Buffer.loadCollection(s, ~wt1);
)

(
SynthDef.new(\vosc,{
	arg out = 0, buf = 0, numBufs = 2;
	var sig, bufpos;
	bufpos = buf + MouseX.kr(0, numBufs - 1); // caculate bufpos, this  keep the functionality the same, but it adds some valuable flexibility for which and how many wavetables we want to use
	sig = VOsc.ar(bufpos, 300, mul:0.2!2);
	Out.ar(out, sig);
}).add;
)



//---------------------

(~wt = Array.fill(4, {
	var numSegs = rrand(4, 20);
	Env(
		[0]++
		(({rrand(0.0, 1.0)}!(numSegs - 1)) *[1, -1]).scramble++[0],
		{exprand(1, 20)}!numSegs,
		{rrand(-20, 20)}!numSegs
	).asSignal(1024).asWavetable;
});
)

~buf = Buffer.allocConsecutive(4, s, 2048); // a way to guarantee our wavetables will have consecutive indices
// the number of buffer we want, the server on which to create them, the number of frames in each one

~buf.class; // this returns an array that contains there four buffers
~buf[0];
~buf[1];
~buf[2];

// we just need to fill these buffers with our four wavetables by iterating over the array till buf.do passing in each buffer and an iteration counter and use loadCollection to fill each buffer with the corresponding wavetable data

(
~buf.do({
	arg buf, i;
	buf.loadCollection(~wt[i]);
});
)

~wt.do({arg n, i; n.plot(~buf[i].bufnum.asString)});  // put each bufnum in the title bar of its corresponding plot window
// didn't free the buffers from the previous example, so those bufnums are still technically in use


(
SynthDef.new(\vosc,{
	arg out = 0, buf = 0, numBufs = 2;
	var sig, bufpos;
	bufpos = buf + MouseX.kr(0, numBufs - 1);
	sig = VOsc.ar(bufpos.poll, 300, mul:0.2!2);
	Out.ar(out, sig);
}).add;
)

Synth(\vosc, [\buf, ~b0.bufnum, \numBufs, 4]); // play the synth making sure to specify the lowest index that we're using and the correct number of buffers


//---------------------


(
SynthDef.new(\vosc,{
	arg out = 0, buf = 0, numBufs = 2, freq = 300;
	var sig, bufpos;
	bufpos = buf + LFNoise1.kr(0.5).range(0, numBufs - 1); // use LFNoise1 to automate and also randomize the position of the wavetale index, so now our shape randomly morphs from one to another
	sig = VOsc.ar(bufpos, freq, mul:0.2!2);
	Out.ar(out, sig);
}).add;
)

Synth(\vosc, [\freq, 28.midicps, \buf, ~b0.bufnum, \numBufs, 4]);


//---- multichannel expansion
// add freq, detuneSig

(
SynthDef.new(\vosc,{
	arg out = 0, buf = 0, numBufs = 2, freq = 300;
	var sig, bufpos, detuneSig;
	detuneSig = LFNoise1.kr(0.2!8).bipolar(0.2).midiratio; // make 8 channel array of noise generators, each one ranging from negative to positive 0.2 semitones, so then Vosc becomes an array of eight unique VOscs
	bufpos = buf + LFNoise1.kr(0.5).range(0, numBufs - 1);
	sig = VOsc.ar(bufpos, freq*detuneSig, mul:0.2!2);
	sig = Splay.ar(sig); // spread the eight signals across a stereo file
	sig = LeakDC.ar(sig);
	Out.ar(out, sig);
}).add;
)

//midiratio: Convert an interval in semitones to a ratio

Synth(\vosc, [\freq, 28.midicps, \buf, ~buf[0].bufnum, \numBufs, 4]);




//add amp
(
SynthDef.new(\vosc,{
	arg out = 0, buf = 0, numBufs = 2, freq = 300, amp = 0.2;
	var sig, bufpos, detuneSig;
	detuneSig = LFNoise1.kr(0.2!8).bipolar(0.2).midiratio;
	bufpos = buf + LFNoise1.kr(0.5).range(0, numBufs - 1);
	sig = VOsc.ar(bufpos, freq*detuneSig);
	sig = Splay.ar(sig);
	sig = LeakDC.ar(sig) * amp;
	Out.ar(out, sig);
}).add;
)

Synth(\vosc, [\freq, 56.midicps, \buf, ~buf[0].bufnum, \numBufs, 4]);















































