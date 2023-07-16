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







//--------------------------------------------------------------------------------------------------------
//Wave shaping
//Wave shaping involves
//an input signal (it can be a sinewave, sawtoothwave...),
/*a transfer function
   (it doesn't represent amplitude as a function of time instead it represents an input-output graph with both axes on a normalized amplitude scale between -1 and 1,
    amplitude values from the input signal are fed into the transfer function and the values that come out of this transfer function are used to construct our output signal
*/
//an output signal


 //____1
/*input signal -> sinewave
transfer function -> Line y = x ( x is the input, y is the output)
this mean every values we put into the transfer function comes out unchanged, it makes sense to call this the identity transfer function, it is a special case that has no effect on the input.
like multiplying by 1 or adding 0
*/

//____2
/* line y = x/2
in this case everything that goes through the transfer function is reduced by half this has the effect of uniformly scaling down the amplitude of the input signal.
*/

//____3
/*
Line y = -x
in this case every value is essentailly multiplied by -1 and this has the effect of inverting the input signal
*/

//____4
/*
near X equals 0, the slope is very steep, but it levels off near x equals +1 and -1.
this means low amplitude values in the input signal tend to get boosted away from 0 more rapidly,
and medium to high amplitude values will plateau(在一段时间的发展之后）趋于平稳, in more casual terms our sinewave gets squished and starts to resemble a square wav
*/

//____5
/*
a transfer function very loosely resembles the Line y equals x, but wiggles around it. then we can expect the shape of our input signal to take on these wiglle characteristics
*/

//____6
/*
a single cycle of a more complex periodic wave being shaped by that same wiggly transger function and this is the wave form that we get in this particular case
*/


//Shaper-----------------------------------------------------------------------------------------------------------
//shaper only needs the transfer function buffer and an audio signal input

~tf = Env([-0.8, 0, 0.8],[1, 1], [8, -8]).plot;

(
//use with VOsc, Osc, etc
~tf = Env([-0.8, 0, 0.8],[1, 1], [8, -8]).asSignal(1024);  // size of power of 2
~tf = ~tf.asWavetable; // convert from signal to wavetable format
)
~tf.size; // doubling the size of signal, because the wavetable conversion process calculates and interleaves additional values into the table in order to make linear interpolition more efficient on the audio server
// when we use VOsc or Osc, we think of the wavetable as being an inherently cyclic thing where the end is conceptually connected to the begining, because in these cases the wavetable is literally being used as one cycle of a periodic wave. so when we use asWavetable, the last interpolation calculation is made using the last point and the first point, basically the process wraps around to the beginning in order to finish the job.



(
//use with Shaper (with waveshaping example 4)
~tf = Env([-0.8, 0, 0.8],[1, 1], [8, -8]).asSignal(1025); // transfer function
~tf = ~tf.asWavetableNoWrap;
)

//when we're using a wavetable with Shaper, we don't conceptualize the wavetable as being inherently cyclic instead we see it as a singular transfer function with a begining,  a middle and an end.
// so it doesn't make sense to do the final interpolation calculation using the last and first value, becasue these two values don't necessarily have anything to do with each other.

// In order to do the final calculation correctly we make the size of the signal a power of two + 1 --------------重要条件
//essentially tagging one extra value on to the end for the very last calculation and we use the method asWavetableNoWrap.  the size of the resulting wavetabkle in this case is still power of two, which is a requirement for using wavetable UGens

//check source file -> Signal -> asWavetableNoWrap (定义)



(
~tf = Env([-0.8, 0, 0.8],[1, 1], [8, -8]).asSignal(1025);
~tf = ~tf.asWavetableNoWrap;
~tfBuf = Buffer.loadCollection(s, ~tf); // fill a buffer with this transfer function
)

{Shaper.ar(~tfBuf, SinOsc.ar(400)) * 0.2!2}.play; // feed it into shaper along with a sinewave input signal



//-----------

(
~tf = Env([-1, 1], [1], [0]).plot.asSignal(1025); // start with identity transfer function
~tf = ~tf + (         // adding starting signal to another signal of the same size
	Signal.sineFill(
		1025,
		(0!3) ++ [0, 0, 0, 1, 1, 1].scramble, // skip the first three partials (泛音) by silencing them, and then randomly pick three partials from partials four through nine
		{rrand(0, 2pi)}!9  // randomized the phases
	).plot;
);
~tfBuf = Buffer.loadCollection(s, ~tf);
)
{Shaper.ar(~tfBuf, SinOsc.ar(400)) * 0.2!2}.play;

// Signal.sineFill always normalizes to full amplitude


//--------------------- scaled-down version
//divide this Signal.sineFill by 4 before adding it, and then normalize the sum of these two signals
(
~tf = Env([-1, 1], [1], [0]).asSignal(1025);
~tf = ~tf + (
	Signal.sineFill(
		1025,
		(0!3) ++ [0, 0, 0, 1, 1, 1].scramble,
		{rrand(0, 2pi)}!9
	)/4;
);
~tf = ~tf.normalize;
~tf.plot;
~tfBuf.loadCollection(~tf.asWavetableNoWrap); // convert two wavetable
)
//~tfBuf = Buffer.loadCollection(s, ~tf);


~tfBuf.plot;


(
{
	var sig, input;
	input = SinOsc.ar(120);
	sig = Shaper.ar(~tfBuf, input);
	sig = sig * 0.3!2;
}.play
)


/* imagine that we fade in the amplitude of the input signal over a period of time as it goes through the transfer function, what is the output signal do.
initially you might expect to see a boring predictable and corresponding simple amplitude fade in with the outpout signal, but that's not what happens.
instead, what happens is as input amplitude increases, the shape and spectrum of the output signal evolve in a very interesting way,
this happens as input amplitude increases we end up using a larger and lager subsection of the transfer function, and each of these transfer function slices is unique.
and evetually, when the input signal is at full amplitude, it traverses 横贯，穿过 the entire transfer function.
*/


(
{
	var sig, input;
	input = SinOsc.ar(120) * Line.kr(0, 1, 7); //use a line UGen that goes from 0 to 1 over some period of time and multiply it by the input signal before it gets fed into shaper
	sig = Shaper.ar(~tfBuf, input);
	sig = sig * 0.3!2;
}.play
)


(
{
	var sig, input;
	input = SinOsc.ar(120) * LFNoise1.kr(0.5).range(0.1, 1); // the outsignal is constantly morphing from one shape to another
	sig = Shaper.ar(~tfBuf, input);
	sig = sig * 0.3!2;
}.play
)


// input signal don't have to be sinewave

(
{
	var sig, input;
	input = LFSaw.ar({120 * Rand(-0.1, 0.1).midiratio}!8); // make 8 sinewaves , all slightly detuned
	input = input * LFNoise1.kr(0.5!8).range(0.1, 1); // multiply them by eight unique noise generators
	sig = Shaper.ar(~tfBuf, input);
	sig = Splay.ar(sig) * 0.3;
}.play;
)



// different way to conceptualize wave shaping as signal operation
(
{
	var sig, input;
	input = LFSaw.ar(250);
	sig = Shaper.ar(~tfBuf, input);
	sig = Splay.ar(sig) * 0.3!2;
}.play;
)

{LFTri.ar(250)}.plot(0.01);
{LFTri.ar(250).lincurve(-1, 1, -1)}.plot(0.01);
{LFTri.ar(250).lincurve(-1, 1, -1,1)}.plot(0.01);
{LFTri.ar(250).lincurve(-1, 1, -1,1, -3)}.plot(0.01);

(
{
	var sig, input;
	input = LFTri.ar(250).lincurve(-1, 1, -1,1, -8);
	sig = Shaper.ar(~tfBuf, input);
	sig = Splay.ar(sig) * 0.3!2;
}.play;
)


(
{
	var sig, input, curve;
	curve = LFNoise1.kr(0.5).bipolar(4);
	input = LFTri.ar(250).lincurve(-1, 1, -1,1, -8);
	sig = Shaper.ar(~tfBuf, input);
	sig = Splay.ar(sig) * 0.3!2;
}.play;
)



(
{
	var sig, input, curve;
	curve = LFNoise1.kr(0.5!8).bipolar(4);
	input = LFTri.ar(250).lincurve(-1, 1, -1,1, curve);
	sig = Shaper.ar(~tfBuf, input);
	sig = sig * 0.3!2;
}.play;
)



(
{
	var sig, input, curve;
	curve = LFNoise1.kr(0.5!8).bipolar(4);
	input = LFTri.ar({250 * Rand(-0.1, 0.1).midiratio}!8);
	input = input.lincurve(-1, 1, -1,1, curve);
	sig = Shaper.ar(~tfBuf, input);
	sig = Splay.ar(sig) * 0.3;
	sig = LeakDC.ar(sig);
}.play;
)



//--------------------------------------------------------------------------
(
~tf = Signal.newClear(1025).waveFill({
	arg x, old,i;
	sin(x)
	}, -pi/2, pi/2);

~tf = ~tf.waveFill({
	arg x, old,i;
	old * ((cos(x*0.8) / 4) + 0.3);
	}, 0, 50pi).normalize;

~tf.plot;
~tfBuf.loadCollection(~tf.asWavetableNoWrap);
)

{LFTri.ar(250).lincurve(-1, 1, -1, 1, -3)}.plot(0.01);

(
SynthDef.new(\shaper,{
	arg buf = 0, freq = 250, amp = 0.2, out = 0, atk = 1, sus = 0, rel = 5, curvemax = 1;
	var sig, input, curve, env;
	env = EnvGate.kr(
		Env.linen(atk, sus, rel, 1, [1, 0, -1]),
		doneAction:2
	);

	curve = LFNoise1.kr(0.5!8).bipolar(curvemax);
	input = LFTri.ar({freq * Rand(-0.1, 0.1).midiratio}!8);
	input = input.lincurve(-1, 1, -1,1, curve);
	sig = Shaper.ar(buf, input);
	sig = Splay.ar(sig) * amp * env;
	sig = LeakDC.ar(sig);
	Out.ar(out, sig);
}).add;
)



(
({rrand(40, 90)}!4).do({
	arg n;
	Synth(\shaper,[
		\buf, ~tfBuf,
		\freq, n.nearestInScale([0.7, 9, 10]).postln.midicps,
		\amp, n.lincurve(40, 90, 0.3, 0.1, -2),
		\curvemax, 0
	]);
});
)


































































































































