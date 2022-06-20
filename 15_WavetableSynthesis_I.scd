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






b = Buffer.alloc(s, 2048); //分配缓冲器 ， 大小是信号的两倍

(
~sig = Signal.sineFill(1024, [1], [0]);
~wt = ~sig.asWavetable;
b.loadCollection(~wt);
)

(
~sig = Signal.sineFill(1024, [1], [0]);
~wt = ~sig.asWavetable;
b.loadCollection(~sig);
)

(
~sig = Signal.sineFill(
	1024,
	[1, 1/4, 1/6, 1/2],
	[0!4]
);

~wt = ~sig.asWavetable;
b.loadCollection(~wt);
)

b.plot;
~sig.plot;

(
~amps = [1] ++ ({[0, exprand(0.05, 0.5)].choose}!31);
~sig = Signal.sineFill(
	1024,
	~amp,
	0!32
);

~wt = ~sig.asWavetable;
b.loadCollection(~wt);
)

b.sine3([1], [1], [0], asWavetable:true).plot;

b.sine3([1.25], [1], [0], asWavetable:false).plot;

b.sine3([1.25], [1], [0], asWavetable:true).plot;

{(Osc.ar(b, MouseX.kr(100, 1000, 1), mul: 0.2!2))}.play;

{SinOsc.ar(MouseX.kr(100, 1000, 1) * (1..32), 0, ~amp * 0.1).sum!2}.play;


b.sine3([1, 50], [1, 1], [0, 0], asWavetable:true).plot;
b.sine3([1, 50], [1, 1], [0, 0], asWavetable:false).plot;
{(Osc.ar(b, MouseX.kr(100, 10000, 1), mul: 0.2!2))}.play;




























































