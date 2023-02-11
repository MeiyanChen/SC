/*
It is based on the same principle as sampling. However, the samples are split into small pieces of around 1 to 100 ms in duration. These small pieces are called grains. Multiple grains may be layered on top of each other, and may play at different speeds, phases, volume, and frequency, among other

https://en.wikipedia.org/wiki/Granular_synthesis

parameters.produce rhythmic patterns, complex drones, pitch shifting, time stretching effects...

  documentation: browse -> UGens -> Generators -> Granular


 GrainFM, GrainSin : synthesize an audio signal and then granulate it
 Grainin :  granulate an arbitrary audio signal coming from a microphone, an internal audio bus or the output of another UGen
GrainBuf, TGrains, Warp1: operate on an audio signal stored in a buffer


check composer: Iannis Xenakis,  Analogique A-B for string orchestra and tape (1959)
http://www.granularsynthesis.com/hthesis/xenakis.html
*/

//1. GrainBuf
s.options.sampleRate = 48000;
s.boot;


(
s.meter;
s.plotTree;
s.scope;
FreqScope.new;
)

//b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff");

//b = Buffer.read(s, "/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/zifuzhimingpart.wav"); // 可用任意音频，如音频格式不符，可用audacity转换为wav格式 ，可尝试正常人声


b = Buffer.readChannel(s, "/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Supercollider/zifuzhimingpart.wav", channels:[0]);


b.play;

b.numChannels; //查看音频是否是单声道
b.free;


//-----------------------------

// triger example 1: Impulse    with grains produced at a fixed time interval using impulse we can call this periodic 周期性的or synchronous 同步的 granular synthesis and around 20 grains per second or so the individual grains start to fuse together and we start perceiving a unified sense of pitch instead of the individual grains themselves using mouse x allows us to focus on that threshold more easily (example 1.2)

//Impulse has a frequency argument and outputs a periodic stream of pulses at that frequency

//example 1.1
(
{
	var sig;
	sig = GrainBuf.ar(
		2, // the number of channels that you want GrainBuf to output, default is 1 代表单声道
		Impulse.ar(10),    // whenever this value under goes a non-positive to positive transition, that GrainBuf's cue to generate a grain , try 12, 20, 30, 40
		0.09, // duration of individual grains measured in seconds
		b, // num of the buffer containing the audio that we want to granulate， mono （same as Tgrain, warp1）
		1, // ratio corresponding to the playback speed of each grain  , this behaves like the rate argument in PlayBuf,   1 is no changing pitch, two is an actave up, 0.5 is an octave down
		0.5, // playback position, the location in the buffer where each grain will start, 0 is the begining of the file, 1 is the end,   0.2 = 1/5
		2, // interpolation (插值) which determins the type of sample interpolation if there's a change in playback speed， default is linear
		0, // if number of channels is 1, the grainbuf ignores this argument, is number of channel is 2, then pan argument is interpreted as it is with Pan2
		-1, // amplitude envelope, appied in each grain
		512 // the maximum number of overlapping grains, it can be dynamically changed as the sound is running
	);
}.play
)


{Impulse.ar(10)}.play  //这里说的频率，与音高无关，与次数有关 。 producing 10 grains per second , that's kind of slow, perceive the grains as individual events.

Signal.hanningWindow(1024).plot; // default amplitude envelope, argument as -1, helps avoid clicks and discontinuities in the output signal from grain buff



// 线性插值：线性插值 https://zh.wikipedia.org/wiki/%E7%BA%BF%E6%80%A7%E6%8F%92%E5%80%BC

// we get a stream 10 identical grains per second each one 90 milliseconds long
//如果执行代码后没声，有两种可能， 一种是所用音频开头的静音时间过长， 可尝试改变 pos数据， 第二种是因为载入的是双声道音频。
//if you try to granulate a multi-channel buffer, grainBuf will fail silently, no errors, no warning,

b = Buffer.readChannel(s, "/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/zifuzhimingpart.wav", channels:[0]); // 0 only read the left channel,  no neead mixing


b.duration/5   // 确定回放位置




//example 1.2
(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(MouseX.kr(1, 200, 1).poll),
		0.09,
		b,
		1,
		0.2,
		2,
		0,
		-1,
		512
	);
}.play
)


//-----------------------------------
// triger example 2: Dust
// Dust outputs pulses at random intervals but maintains a relatively constant density of pulses per second


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar(MouseX.kr(1, 200, 1).poll), //swap impulse for dust and now we're doing asynchronous 不同步的 granular synthesis
		0.09,
		b,
		1,
		0.2,
		2,
		0,
		-1,
		512
	);
}.play
)

//we're still controlling density with the mouse but ultimately the grains are randomly generated so they never fuse together into a coherent sense of pitch instead we just get a big noisy grain cloud that sounds kind of like making popcorn


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar(MouseX.kr(1, 200, 1).poll),
		0.09,
		b,
		1,
		0.2,
		2,
		0,
		-1,
		512
	);
}.play
)

//--------------------------back ot example 1 impulse, grain duration

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(10),
		1.2,  // 0.13, 0.2, 0.5,  1, 2   if we increase the grain duration little by little. then we'll be able to hear more and more of the phase, and it's very easy to notice that it gets louder the rate at which grains are generated stays the same but the grains are getting longer which means there's more grain overlap and when sounds overlap like this their amplitudes get summed together.
		b,
		1,
		0.2,
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5; // so in some cases we're likely to see higher peaks on the meters and possibly even clipping if we're not careful so with high grain densities or long grains, you might want to compensate for the increase in amplitude by simply scaling the output

}.play
)


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(4),   //if we keep the grains long but lower the trigger frequency we can get a sort of trans-inducing loop 结合感应式的循环.  try 2.2
		2,
		b,
		1,
		0.2,
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;

}.play
)

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(0.5),   //if the frequency of the triggers and the grain duration are inverse values  逆值  then each grain begins exactly when the previous one ends. you can notice that with long sparse grains 稀疏的 it becomes a lot easier to actually hear the bell curve shape of that hanning envelope
		2,
		b,
		1,
		0.2,
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;

}.play
)


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(10),
		0.0002, // shortening the grains ,  0.01, 0.005, 0.002, 0.001, 0.0002   so when the grains get really small they basically become little clicks each one maybe a dozen samples long and the nature of the original sound they came from is totally concealed
		b,
		1,
		0.2,
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;

}.play
)


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(60),    //we can make buzzy tones by providing a trigger rate that's fast enough
		0.0002,
		b,
		1,
		0.2, //0.23
		2,
		0,
		-1,
		512
	);
}.play
)


(
{
	var sig;
	sig = GrainBuf.ar(
		1, //we also need to make sure to change this back to a one channel grain buff that can then be expanded to two
		Impulse.ar([60, 60.5]),    // we could make a stereo beating effect using multi-channel expansion and two slightly different frequencies.  here's something interesting by changing the grain size ever so subtly we allow a slightly different chunk of audio into the grain and so we're slightly changing the shape of this 60 hertz fundamental cycle and when the waveform shape changes so does the timbre of the resulting tone
		0.001, // 0.001, 0.002, 0.005, 0.01, 0.02
		b,
		1,
		0.2, //0.23
		2,
		0,
		-1,
		512
	);
}.play
)



(
{
	var sig;
	sig = GrainBuf.ar(
		1,
		Impulse.ar([60, 60.5]),
		MouseX.kr(0.0002, 0.1, 1).poll, //let's use mousex again and also bring up a real-time spectrum analyzer alongside the scope
		b,
		1,
		0.23,
		2,
		0,
		-1,
		512
	);
}.play
)

(
{
	var sig;
	sig = GrainBuf.ar(
		1,
		Impulse.ar([60, 60.5]),
	    LFNoise1.kr(0.3!2).exprange(0.0002, 0.1),  //instead of mousex we could automate this parameter with a noise generator allowing the grain duration to kind of move around on its own using multi-channel expansion here as well so that the grain duration is unique in each channel
		b,
		1,
		0.23,
		2,
		0,
		-1,
		512
	);
	sig = Splay.ar(sig);
}.play
)

///XXXXXXXXXXXXXXXXXXXX
(
{
	var sig;
	sig = GrainBuf.ar(
		1,
		Impulse.ar({ExpRand(60, 60.5)}!12), //instead of two we'll make 12 slightly different grain buffs,  each with a unique grain trigger and unique grain duration
		LFNoise1.kr(0.3!12).exprange(0.0002, 0.1),
		b,
		1,
		0.23,
		2,
		0,
		-1,
		512
	);
	sig = Splay.ar(sig); // and spread them out across the stereo field using splay
}.play
)


(
{
	var sig;
	sig = GrainBuf.ar(
		1,
		Dust.ar({ExpRand(60, 60.5)}!12),  //that's nice now like before if we swap impulse for dust our sense of pitch goes right out the window because the grains are no longer generated at a regular interval
		LFNoise1.kr(0.3!2).exprange(0.0002, 0.1),
		b,
		1,
		0.23,
		2,
		0,
		-1,
		512
	);
	sig = Splay.ar(sig);
}.play
)


(
{
	var sig;
	sig = GrainBuf.ar(
		1,
		Dust.ar(20!2), // let's go back to that simpler stereo configuration with short grains that are more sparse, we're back to our crackly popcorn bits but with a little more variety in the sound quality,because the grain duration is changing
		LFNoise1.kr(10).exprange(0.0002, 0.1),
		b,
		1,
	 0.23,
		2,
		0,
		-1,
		512
	);
	sig = Splay.ar(sig);
}.play
)

//-----------------------------------------------
(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(10),  //whenever we get a trigger here grainbuf basically takes a little snapshot of this value wherever it happens to be at that moment that's the location in the buffer where it grabs the next grain so this is going to sound like some real
		0.09,
		b,
		1,
		LFNoise1.kr(500).range(0, 1), // make start position random.  in this case we're generating 10 grains per second but this  LFNoise is zipping around much faster 500 random values per second so how this works is basically
		2,
		0,
		-1,
		512
	);
}.play
)


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(10),
		0.09,
		b,
		1,
		LFNoise1.kr(0.1).range(0, 1), // we could drop this all the way down to 10 the same value as the grain trigger frequency and we'll get very similar results but with a much lower frequency for this LFNoise1. Try 0.1 ->because this is a linearly interpolating noise generator.  we'll be able to actually hear the grain pointers sort of slowly sliding around the file which is kind of a cool effect
		2,
		0,
		-1,
		512
	);

}.play
)


//-------------------------

// we can very freely adjust the synchronicity density and grain duration for noticeably different types of effects so this particular configuration with longer asynchronous grains

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar(40),
		0.5,
		b,
		1,
		LFNoise1.kr(0.1).range(0, 1),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;
}.play
)


//for another variation we can make the grains much shorter and bring the frequency of the pointer randomness back up to 500.

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar(40),
		1/20, //0.001 , 0.0005, 1/20, 1/10, 1/5, 1/2
		b,
		1,
		LFNoise1.ar(500).range(0, 1),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;
}.play
)



//------------------------- 通过调整回放位置，改变声音
//let's say we don't want randomness let's say we want the grain pointer to move through the file from beginning to end so for this we could use a line that goes from 0 to 1 and the amount of time it takes to get there is determined by the duration of the buffer that we're granulating so we can use buff door and when we get to the end let's say we're done listening so doneAction 2.

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(40),
		0.01,
		b,
		1,
		Line.ar(0, 1, BufDur.ir(b), doneAction:2),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;
}.play
)



//---------------
// let's gradually shrink the size of the grains and see what happens. When the grain duration was 0.001,  the grains were big enough that our brains were able to get enough information to translate the sound into words. But small enough that they also have this clicky buzzy flavor. but with these extremely short grains that crispy buzzy flavor is the overwhelming quality and we can no longer really hear the content of the original file

//now with longer grains we lose the buzziness and start reconstructing the original audio file. In this case the ideal grain duration for a perfect file reconstruction is twice the reciprocal倒数 of the grain generation rate which in this case is 2 times 1/40 which is 1/20. this means we get a very precise crossfade between adjacent grains where each grain reaches its peak exactly at the moment that the previous grain fades out
// if we increase the grain duration beyond this value of 1 over 20 nothing interesting is going to happen it's just going to get louder because we'll have more grain overlap and all the grains are perfectly in phase with each other.

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(40),
		1/20, // try 1/3, 1/4.... 0.0001, 0.0005,        2*  1/40 = 1/20
		b,
		1,
		Line.ar(0, 1, BufDur.ir(b), doneAction:2) ,
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;
}.play
)



//-----------------------
//let's say we don't want too much structure in order instead of a perfectly straight line from zero to one, maybe we want this line to you know jiggle around a little bit as it makes that trip but maintain that overall trajectory from zero to one to do this all we have to do is add a little bit of noise to the line like we did before but for the sake of consistency i think it would make a little more sense, if we express these values in samples and convert to a normalized range between 0 and 1 as the very last step.
// so our line is now going to represent a sample pointer from 0 to the last sample in the buffer, which has an index of the number of samples in the buffer minus one, and the duration of the line stays the same.
// then we're going to add a fast moving noise generator with an output range of plus or minus a thousand samples or here if you prefer you can specify a value in seconds and then multiply that by the sample rate to convert to samples.  last because grain buff expects this value to be between 0 and 1.  we take the whole thing and divide by the number of samples in the buffer.

//what's going on here is imagine yourself trying to draw a perfect circle with pencil and paper, it's obviously going to look like a circle but it won't be a perfect circle in this analogy the noise generator here basically represents the amount of human imperfection in the drawing and so if we increase this error little by little,  eventually the noise completely overwhelms the line

// so with a deviation of a half second in either direction that's like trying to draw a perfect circle in the middle of an earthquake.
 BufSamples.ir(b)

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(40),
		1/20,
		b,
		1,
		(
		        Line.ar(0, BufSamples.ir(b)-1, BufDur.ir(b), doneAction:2)
				+ LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir) // bipolor 正数和负数  或 + LFNoise1.ar(100).bipolar(1000)     try 0.05, 0.13, 0.5
		)/ BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;
}.play
)


//----------------
//now a cool variation on this idea is to change the duration of the line and indirectly this affects the speed at which the pointer moves through the buffer from beginning to end.
//So for example times four means it takes four times as long to get to the end


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(40),
		1/20,
		b,
		1,
		(
		        Line.ar(0, BufSamples.ir(b)-1, BufDur.ir(b) * 4, doneAction:2)  //*
				+ LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)
		)/ BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;
}.play
)


//we can also make the grain pointer move backwards by swapping the start and end values

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(40),
		1/20,
		b,
		1,
		(
		        Line.ar(BufSamples.ir(b)-1, 0, BufDur.ir(b) *4, doneAction:2)  //*
				+ LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)
		)/ BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;
}.play
)



(
SynthDef(\grain, {
	var sig, pan, out;
	arg freq = 40,cs = 1, speed = 1,
	sig = GrainBuf.ar(
		2,
		Impulse.ar(freq),
		1/20,
		b,
		1,
		(
		        Line.ar(BufSamples.ir(b)-1, 0, BufDur.ir(b) *4, doneAction:2)  //*
				+ LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)
		)/ BufSamples.ir(b),
		2,
		0,
		-1,
		512
    )
	pan = sig * xxxx
	Out
}).add;
)


Synth

Pbind

//--------------------------
//let's say we want to go from beginning to end not once but over and over again well we're basically talking about sample looping, and we can't use line for this because line doesn't loop but there are a few Ugens that can do this relatively easily such as LFSaw, Sweep and Phaser and for completeness

//LFSaw generates a pure sawtooth shape. it's just literally a repeating diagonal line from low to high it's an oscillator. so it expects a frequency in hertz so to achieve normal pointer speed. we need the duration of one cycle of lfsaw to be equal to the duration of the buffer, and because frequency and period have an inverse relationship.  we set the frequency to be 1 divided by buffer duration. and since we're thinking in terms of samples the range of LFSaw should be from 0 to the number of samples -1.

b.play;


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(40),
		1/20,
		b,
		1,
		(
			LFSaw.ar(1/BufDur.ir(b)).range(0, BufSamples.ir(b)-1)
			+ LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)
		) / BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;
}.play
)

{LFSaw.ar(10)}.plot(0.2)
{LFSaw.ar(10, 1)}.plot(0.2)


//notice that it doesn't actually start at the beginning and that is because the default initial phase of LFSaw is zero, which causes the sawtooth to start at the midpoint of its diagonal segment. and that corresponds to the middle of the audio file, so to fix that we provide a phase value of one which offsets the phase of LFSaw, so that it starts at the bottom.

//from here we can use simple multiplication to scale the frequency as desired in order to move the pointer faster or slower
(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(40),
		1/20,
		b,
		1,
		(            //*             *
			LFSaw.ar(0.5/BufDur.ir(b), 1).range(0, BufSamples.ir(b)-1)  //*  try 2/BufDur,  0.5/BufDur,
			+ LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)
		) / BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;
}.play
)

//------- -------------------
//Sweep is a ramp 斜坡 that starts at zero and by default counts the number of seconds that have gone by, since the last time it received a trigger.
//so the idea is to re-trigger sweep, every time a buffer duration's worth of time has elapsed we can do this with impulse running at a frequency of 1 divided by the buffer duration just like we did with lfsaw the default rate of sweep is one but the technically correct thing to do here is multiply that by bufRateScale.
//just in case the sample rate of the original audio file is different from the current sample rate of the audio server.
// last because sweep is counting seconds and we're thinking in terms of samples,  we need to multiply sweep by the sampling rate.
// from here we can continue scaling the pointer speed as desired by changing this number

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(40),
		1/20,
		b,
		1,
		( //                                      try 0.2, 3,
			Sweep.ar(Impulse.ar(1/BufDur.ir(b)), 1* BufRateScale.ir(b)) // 测量单位为秒
			* SampleRate.ir
			+ LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)
		) / BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;
}.play
)


//------------------------
//Phasor is kind of like LFSaw in that it's a repeating linear ramp from a to b. the first argument is the reset trigger which i'm just going to put a 0 here and ignore it
//Phasor automatically wraps back to the start when it gets to the end so this is only useful if we want to manually re-trigger phasor ourselves which we're not gonna do
//next is rate and this is a per sample increment 增长, by default this is 1 which means phasor is basically counting the number of audio samples that have gone by, because we're thinking in terms of samples i'm going to leave this at 1. but again it's appropriate to multiply this by buff rate scale just in case we have a sample rate mismatch
//after this phaser needs start and end values so we start at 0 and at number of samples -1
//the last argument for phaser is reset position this is not relevant in this particular case, because we're never going to reset phaser ourselves so i'm just going to ignore it

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(40),
	    1/20,
		b,
		1,
		(//              * try 4, 0.1   this value here is the one we want to change to make the grain pointer move faster or slower
			Phasor.ar(0, 1* BufRateScale.ir(b), 0, BufSamples.ir(b)-1)
		   + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)
	    ) / BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;
}.play
)















