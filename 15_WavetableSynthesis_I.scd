s.options.sampleRate = 48000;

/*    https://www.music.mcgill.ca/~gary/307/week4/wavetables.html

Wavetable synthesis involves the use of an ordered collection of values called a wavetable and it can contain virtually any shape as long as it represents a sample of a valid time domain function.
the size of a wavetable is usually a pow of 2
in the simplest application of wavetable synthesis the wave table is treated as a single cycle of periodic wave and we use a wavetable oscillator to read through these values at a particular frequency.

1. Osc
the only differences is that SinOsc always uses a built-in sine wavetable whereas OSC has an additional argument that allows us to specify a custom wavetable stored in a buffer

Variations:

2. COsc
3. VOsc
4. Shaper: a wave shaping Ugen that uses a wave table as a trasfer function in order to alter the shape of an input signal


Signal:  is not a server-side object and doesnt't directly interface with audio.  it's a language side object. it's an ordered collection sort of like an array but only contain floats. it's useful representing sampled audio signals in an offline context away from the audio server.
 Signal is particularly handy if you wnat to build a wavetable using sums of harmonically related sine waves using the sineFill method.

In order to make sound with osc is generate a wavetable and load it into a buffer on the server.

*/

s.boot;
s.scope;
FreqScope.new;

//create a wavetable and save it in the buffer

~sig = Signal.sineFill(1024, [1], [0]);

(
~sig = Signal.sineFill(1024, [1], [0]);
~sig.plot;
)

(                            // full amplitude as 1, initial phase offset of 0 radians
~sig = Signal.sineFill(1024, [1], [0]); // size: pow of 2 (2的n次方), if it is smaller than 128, the distortion from having a low-resolution table is obvious. if it's go higher than maybe 8192, there is a point of diminishing returns where you need bigger and bigger buffers to hold the wavetable, but it's not improving sound quality in a noticeable way.
~sig.plot("signal");
~wt = ~sig.asWavetable; // convert a signal to wavetale format 波表格式
~wt.plot("wavetable");
)

// SinOsc uses a table with size 8192

// wavetable format
//almost every wave table UGen requires a buffer that's been filled according wavetable format
//but in this signal object, it's not in wavetable format. it's just a plain regular collection that represents one cycle of a sine wave

//the reason two plot looks the same?
//Look Up Implementations -> plot -> wavetable (shown as signal form)

~sig.size;
~wt.size;

//wavetable is twice as big.

(
~sig = Signal.sineFill(1024, [1], [0]);
~sig.plot("signal");
~wt = ~sig.asWavetable;
~wt.collect({arg n; n}).plot("wavetable"); // iterate over the wavetable, converting the wavetable into a plain old array
)

(
~sig = Signal.sineFill(128, [1], [0]);
~sig.plot("signal");
~wt = ~sig.asWavetable;
~wt.collect({arg n; n}).plot("wavetable");
)

// if we stretch it out, the changes stops in wavetable, it's how the wavetable really looks like.
// hit M key to view it as points, shrink it until it fewer than 256 pixels, no longer have enough pixels to represent the full table,  signal plot doesn't have this change.

// this phenonmenon happens to sound. if we sample a frequency that's too high for the sampling rate, we get aliasing (https://en.wikipedia.org/wiki/Aliasing) or fold over

// wavetable isn't just a format. it's acutally a class
// check reference:  Wavetable -> Advanced notes: wavetbale format

// a signal contains the raw values, wavetable takes the first adjacent pair and does these two calculations. then it shifts over by one value and does these calculations again with the next pair.
// this explains why wavetable format is twice as big as signal, because there are two calculations for each value, it also explains the zig-zag pattern

// check reference: Shaper -> Wavetable format is a special representation to make linear interpolation faster   (插值， 线性插值 https://zh.wikipedia.org/wiki/%E6%8F%92%E5%80%BC)  可以代替音频 服务器进行计算



//(Approach 1)
//sound example 1  -------------------------------------------------------------------------------------------------------------

b = Buffer.alloc(s, 2048); //分配缓冲器 ， 大小是信号的两倍 only evaluate it once,

(
~sig = Signal.sineFill(1024, [1], [0]);
~wt = ~sig.asWavetable;
b.loadCollection(~wt); // fill the allocated buffer using the wavetable, this way we can easily change the wavetable shape by reruning this clump to overwrite the contents of the buffer. But not actually reallocating an entirely new buffer which would be unnecessary
)

b.plot;

{(Osc.ar(b, MouseX.kr(100, 1000, 1), mul: 0.2!2))}.play; // low down the amp, and use two channel signal



//sound example 2--------------------------------------
// what happens if you don't convert to wavetable format
(
~sig = Signal.sineFill(2048, [1], [0]);
~wt = ~sig.asWavetable;
b.loadCollection(~sig);
)


{(Osc.ar(b, MouseX.kr(100, 1000, 1), mul: 0.2!2))}.play;



[0!4]

//sound example 3----------------------------------------

(
~sig = Signal.sineFill(
	1024,
	[1, 1/4, 1/6, 1/2], //泛音音量
	0!4
);
~wt = ~sig.asWavetable;
b.loadCollection(~wt);
)

b.plot;
~sig.plot;

{(Osc.ar(b, MouseX.kr(100, 1000, 1), mul: 0.2!2))}.play;



//sound example 4-------------------------------------------
// additive synthesis

//~amps = [1] ++ ({[0, exprand(0.05, 0.5)].choose}!31);



(
~amps = [1] ++ ({[0, exprand(0.05, 0.5)].choose}!31); // it start with the fundamental at full amplitude and then concatenate 连接 amplitudes for another 31 harmonices, for each overtones, we make a choice. either we skip the harmonic by giving it a 0 or pick a random amplitude between 0.05 and 0.5

~sig = Signal.sineFill(
	1024,
	~amp,
	0!32
);
~wt = ~sig.asWavetable;
b.loadCollection(~wt);
)

{(Osc.ar(b, MouseX.kr(100, 1000, 1), mul: 0.2!2))}.play;

// 同一效果：
{SinOsc.ar(MouseX.kr(100, 1000, 1)*(1..32), 0, ~amp * 0.1).sum!2}.play;
//we need a UGen for each partial, whereas with Osc, we prefill a wave table and we only need one oscillator to produce the full spectrum, so it's more efficient


//---------------------------------------------------------------------------------------------------------
// (Approach 2)
//除了signal 之外其他创造 wavetable的方法： Buffer -> sine1, sine2, sine 3
// they are based on sums of sinewaves but sine2 and sine 3 have a distinct advantage over signal signFill. Because they allow you to specifiy frequencies of the partials directly and you are not limited to integer multiples of a fundamental

b.sine3([1], [1], [0]).plot; // fundamental, full amplitude, phase of 0 radians = pure sinewave

b.sine3([1], [1], [0], asWavetable:false).plot;  // reference: Osc -> wavetable flag, to see single period wavetable

b.sine3([1], [1], [0], asWavetable:true);
{(Osc.ar(b, MouseX.kr(100, 1000, 1), mul: 0.2!2))}.play; // sound test

b.sine3([1.25], [1], [0], asWavetable:false).plot; // this mean we fill the buffer with 1 and 1/4 cycle of a sine wave. Occ gonna cycle through this shape and when it gets to the end and wraps back to the begining for the next cycle. there is a big discontinuity because it has to jump instantaneously from 1 to 0

b.sine3([1.25], [1], [0], asWavetable:true); // it sounds more like a sawtooth wave because the big vertical slice we've put into it and the spectrum looks like a sawtooth spectrum as well. with basically all the partials present and decreasing amplitude
{(Osc.ar(b, MouseX.kr(100, 10000, 1), mul: 0.2!2))}.play;// sound test

//this is generally what happens of you oscillate using a discontinous wave table.
//when you have a discontinuous waveform like this, the signal is going to alias pretty hard, especially at higher frequencies and you can hear the aliasing clearly if we increase the upper boundary of MouseX .






// Aliasing is something to watch out for with wavetable synthesis in general. even if we don't have a wavetable with discontinuities.

b.sine3([1, 50], [1, 1], [0, 0], asWavetable:false).plot; // the wavetable that contains the fundamental and the 50th harmonic at equal amplitudes and phases.

b.sine3([1, 50], [1, 1], [0, 0], asWavetable:true);
{(Osc.ar(b, MouseX.kr(100, 10000, 1), mul: 0.2!2))}.play; // sound test

// but this 50th harmonics bonks thing cuz the mic was written so soon and then fold all over the place.
// we can ignore it, or incorporates some low-pass filtering into your synthesis to try to soften the high frequency before they alias, although this is not gonna make the problem magically disappear
// or consider doing all your synthesis at a higher sampling rate, therefor raises the threshod at which aliasing occurs.


// more example  1 --------------------
(
b.sine3(
	({exprand(0.75, 40)}!16).sort, //16 random partials between harmonic number 0.75 and 40, sorted from low to high
	({exprand(0.05, 0.9)}!16).sort.reverse, // 16 random amplitude sorted from high to low
	{rrand(0, 2pi)}!16, //  16 random phases
	asWavetable:false
).plot;
)

(
b.sine3(
	({exprand(0.75, 40)}!16).sort,
	({exprand(0.05, 0.9)}!16).sort.reverse,
	{rrand(0, 2pi)}!16,
	asWavetable:true
);
)  // the buffer can be modified while the server is running even if Ugens are actively using them, which is the case here, so as a nice perk we can dynamically change the wave shape by reruning sine3 code


{(Osc.ar(b, MouseX.kr(100, 10000, 1), mul: 0.2!2))}.play;

{(Osc.ar(b, MouseX.kr(100, 10000, 1) * [1, 2.01 ], mul: 0.2!2))}.play;
// having the right channel one octave higher and silightly detuned






//(Approach 3)---------------------------------------------------------------------
/*Using Env Class
Env is a language side specification for a segmented envelop shape.
Consider it as an abstract shape
*/

b = Buffer.alloc(s, 2048);

Env([0, 0.6, -0.9, 0.3, 0], [4, 3, 2, 1], \lin).plot;
// only have to worry about relative proportions of the durations rather than the actual values themselves
// straight lines angles and sharp corners tending to produce a wide spectrum
//smooth curvy continuous shapes tend to produce fewer and quieter and high harmonics

// ENV -> Signal -> Wavetable format -> Buffer


// example 1 ---------
(
var env, sig, wt;
env = Env([0, 0.6, -0.9, 0.3, 0], [4, 3, 2, 1], \lin);
sig = env.asSignal(1024);
wt = sig.asWavetable;
b.loadCollection(wt);
)

b.plot;

{(Osc.ar(b, MouseX.kr(100, 10000, 1) * [1, 2.01 ], mul: 0.2!2))}.play;



//example 2 -----------

(
var env, sig, wt;
env = Env([0, 0.6, -0.9, 0.3, 0], [4, 3, 2, 1], \sine); //soften the conners using sinusoidal interpolation instead
sig = env.asSignal(1024);
wt = sig.asWavetable;
b.loadCollection(wt);
)

b.plot;

{(Osc.ar(b, MouseX.kr(100, 10000, 1) * [1, 2.01 ], mul: 0.2!2))}.play;



// example 3---------

(
var env, sig, wt;
env = Env([0, 0.6, -0.9, 0.3, 0], [4, 3, 2, 1], {rrand(-20, 20)}!4); // an array of random numbers
sig = env.asSignal(1024);
wt = sig.asWavetable;
b.loadCollection(wt);
)

b.plot;

{(Osc.ar(b, MouseX.kr(100, 10000, 1) * [1, 2.01 ], mul: 0.2!2))}.play;


//example 4------------
//randommize the whole thing
(
var env, sig, wt, numSegs; // number of envelopes segments
numSegs = rrand(4, 20);
env = Env(
	{rrand(-1.0, 1.0)}!(numSegs + 1), // 20 envelope points canbe anything from -1 to 1
	{exprand(1, 20)}!numSegs, // random duration
	{rrand(-20, 20)}!numSegs  // random curves
);
sig = env.asSignal(1024);
wt = sig.asWavetable;
b.loadCollection(wt);
sig.plot;
)

{(Osc.ar(b, MouseX.kr(100, 10000, 1) * [1, 2.01 ], mul: 0.2!2))}.play;
//one likely possible danger here that it's the envelope points will come out all positive or all negative in which case the wave shape will be entirely above or below zero and this meaning s we'd be introducing some considerable DC offset into the signal, basically pusing it away from the horizontal axis and loudspeakers don't like reproducing there kinds of signals. it's not really good or healthy for them.

// getting heads 20 times in a row which is not very probable, but only for 4 times, this outcome is considerably more likely.
//So an improvement here is to limit the range of envelope points from 0 to 1 and then multiply the resulting array by the array [1, -1]

({rrand(0.0, 1.0)}!10) *[1, -1];
// in SC this type of array multiplication is defined such that corresponding values are multiplied together and the smaller array will repeat itself as many times as necessary to interact with every value in larger array. in other words, all the numbers in the random array with even indices stay positive and with odd indices become negative 随机数组中所有偶数索引的数字保持正数，奇数索引的数字成为负数。
// this bassically guarantees that we get a waveform that's reasonably well centered around zero. we can scramble the result so it's not always alternating positive, negative, positive, negative ...


[0, 1, 2, 3, 4, 5, 6, 7, 8, 9] *[1, -1];

(({rrand(0.0, 1.0)}!10) *[1, -1]).scramble;

Synth
// example 5-------------

(
var env, sig, wt, numSegs;
numSegs = rrand(4, 20);
env = Env(
	(({rrand(0.0, 1.0)}!(numSegs + 1)) *[1, -1]).scramble,
	{exprand(1, 20)}!numSegs,
	{rrand(-20, 20)}!numSegs
);
sig = env.asSignal(1024);
wt = sig.asWavetable;
b.loadCollection(wt);
sig.plot;
)

{(Osc.ar(b, MouseX.kr(100, 10000, 1) * [1, 2.01 ], mul: 0.2!2))}.play;


// sig = LeakDC.ar(sig); // perventing leaning really hearvily into positive or negative territory
// a filter that removes DC offset and centers the wave form around zero
// very handy with experimental wavetable

//DC offset  直流偏移 (https://en.wikipedia.org/wiki/DC_bias)
//is an imbalance that sometimes occurs in A/D converters. When working with audio it is desirable to have only the audio program material passed through the signal path. Almost by definition audio, being a periodic waveform, is an AC (Alternating Current) signal. DC (direct current) is of the non alternating or periodic variety and thus has no constructive purpose as part of an audio signal. It is merely a constant voltage that is present which can eat up headroom and cause clicks and pops during editing.




// (Approach 4)----------------------------------------------------------------------------------------
//Signal.waveFill
//it's a method that iterates over a signal and we provide a function to algorithmically 算法 fill that signal with new values. Because waveFill is an instance method, this means we have to create a new signal instance first.

// example 1----
(
var sig, wt;
sig = Signal.newClear(1024); // start with an empty signal
sig.waveFill({
	arg x, old, i; // pass in three argument.
	//x = a value along an interval, which by default is from 0 to 1. so on the first iterative pass X is 0, halfway through it's 0.5 and when we get tp index 1023, X is just 1,  it's equal to 1023 divided by 1024, so it's just a normalized value that you can use in your algorithm
	//old = is the current value in the signal and because this is a new empty singal this will be 0 on every iterative pass but this can be useful if you want to apply multiple waveFill operations to a signal in sequence one after the other and pass the output values back in for more processing.
	//i = is an index, so this is simple an iteration counter 0 to 1023
	sin(x); // make a sine wave
}, 0 ,2pi); // we also have the option of supplying a min and a max afer the function to change the interval for the first argument so now it'll range from 0 to 2pi instead of 0 to 1

wt = sig.asWavetable;
b.loadCollection(wt);
sig.plot;
)


// example 2----

(
var sig, wt;
sig = Signal.newClear(1024);
sig.waveFill({
	arg x, old, i;
	var out;
	out = sin(x.pow(1.5)); //幂，乘方  this makes the frequency of the sine wave increase as x increases
	out = out * 1.5;
	out = out.fold(-1, 1); // we don't want wavetable values to go beyond -1 or 1, so we can fold these values back into the desired range
	out = out.cubed;
}, 0 ,2pi);

wt = sig.asWavetable;
b.loadCollection(wt);
//sig.plot;
)

b.plot;

{(Osc.ar(b, MouseX.kr(100, 10000, 1) * [1, 2.01 ], mul: 0.2!2))}.play;









//way to create wavetable

Signal.sineFill
b.sine1/2/3
Env().asSingal
Signal.waveFill












































