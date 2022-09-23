/* produce rhythmic patterns, complex drones, pitch shifting, time stretching effects...

  documentation: browse -> UGens -> Generators -> Granular


 GrainFM, GrainSin : synthesize an audio signal and then granulate it
 Grainin :  granulate an arbitrary audio signal coming from a microphone, an internal audio bus or the output of another UGen
GrainBuf, TGrains, Warp1: operate on an audio signal stored in a buffer


check composer: Iannis Xenakis,  Analogique A-B for string orchestra and tape (1959)
http://www.granularsynthesis.com/hthesis/xenakis.html
*/

//1. GrainBuf
s.boot;
s.options.sampleRate = 48000;

(
s.meter;
s.plotTree;
s.scope;
)

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff");// 可用任意音频，如音频格式不符，可用audacity转换为wav格式 ，可尝试正常人声

b = Buffer.read(s, "/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/zifuzhimingpart.wav");
b.play;





b.numChannels; //查看音频是否是单声道
b.free;

// triger example 1: Impulse
//Impulse has a frequency argument and outputs a periodic stream of pulses at that frequency
(
{
	var sig;
	sig = GrainBuf.ar(
		2, // the number of channels that you want GrainBuf to output, default is 1 代表单声道
		Impulse.ar(10),    // whenever this value under goes a non-positive to positive transition, that GrainBuf's cue to generate a grain
		0.09, // duration of individual grains measured in seconds
		b, // num of the buffer containing the audio that we want to granulate， mono （same as Tgrain, warp1）
		1, // ratio corresponding to the playback speed of each grain  , htis behaves like the rate argument in PlayBuf,   1 is no changing pitch, two is an actave up, 0.5 is an octave down
		0.5, // playback position, the location in the buffer where each grain will start, 0 is the begining of the file, 1 is the end,   0.2 = 1/5
		2, // interpolation (插值) which determins the type of sample interpolation if there's a change in playback speed， default is linear
		0, // if number of channels is 1, the grainbuf ignores this argument, is number of channel is 2, then pan argument is interpreted as it is with Pan2
		-1, // amplitude envelope, appied in each grain
		512 // the maximum number of overlapping grains, it can be dynamically changed as the sound is running
	);
}.play
)


{Impulse.ar(10)}.play

Signal.hanningWindow(1024).plot; // default amplitude envelope, argument as -1, helps avoid clicks and discontinuities in the output signal from grain buff



// 线性插值：线性插值 https://zh.wikipedia.org/wiki/%E7%BA%BF%E6%80%A7%E6%8F%92%E5%80%BC

// we get a stream 10 identical grains per second each one 90 milliseconds long
//如果执行代码后没声，有两种可能， 一种是所用音频开头的静音时间过长， 可尝试改变 pos数据， 第二种是因为载入的是双声道音频。
//if you try to granulate a multi-channel buffer, grainBuf will fail silently, no errors, no warning,

b = Buffer.readChannel(s, "/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/zifuzhimingpart.wav", channels:[0]); // 0 only read the left channel,  no neead mixing


// triger example 2: Dust
// Dust outputs pulses at random intervals but maintains a relatively constant density of pulses per second
// this would give us a cluster of approximately 10 grains per second

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



(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar(MouseX.kr(1, 200, 1).poll),
		0.13,  // 1, 2
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



(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(2.2),   // 60
		0.09,  // 0.0002
		b,
		1,
		0.2,
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5
}.play
)

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar([60, 60, 5]),    //2.2
		0.09,
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
		2,
		Impulse.ar([60, 60, 5]),    //2.2
		MouseX.kr(0.0002, 0.1, 1).poll,
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
		2,
		Impulse.ar([60, 60, 5]),    //2.2
		LFNoise1.kr(0.3).exprange,  // LFNoise1.kr(0.3!2).exprange(0.0002, 0.1),
		b,
		1,
		0.2, //0.23
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
		Dust.ar({ExpRand[60, 60, 5]}!12),
		LFNoise1.kr(0.3!2).exprange(0.0002, 0.1),
		b,
		1,
		0.2, //0.23
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
		Dust.ar({ExpRand[60, 60, 5]}!12),
		LFNoise1.kr(10).exprange(0.0002, 0.1),
		b,
		1,
		0.2, //0.23
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
		2,
		Impulse.ar(10),    //2.2
		0.09,
		b,
		1,
		LFNoise1.kr(0.1).range(0, 1), //0.23
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
		Dust.ar(40),    //2.2
		0.09, // 0.5
		b,
		1,
		LFNoise1.kr(0.1).range(0, 1), //0.23
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
		Dust.ar(40),    //2.2
		0.09, // 0.5 ,  0.001 , 0.0005, 1/20, 1/10, 1/5, 1/20
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



(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar(40),    //2.2
		0.09, // 0.5 ,  0.001 , 0.0005, 1/20, 1/10, 1/5, 1/20
		b,
		1,
		Line.ar(0, 1, BufDur.ir(b)-1, BufDur.ir(b), doneAction:2) + LFNoise1.ar(100).bipolar(1000),
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
		Dust.ar(40),    //2.2
		0.09, // 0.5 ,  0.001 , 0.0005, 1/20, 1/10, 1/5, 1/20
		b,
		1,
		Line.ar(0, BufSamples.ir(b)-1, BufDur.ir(b), doneAction:2) + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir),
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
		Dust.ar(40),    //2.2
		0.09, // 0.5 ,  0.001 , 0.0005, 1/20, 1/10, 1/5, 1/20
		b,
		1,
		(Line.ar(0, BufSamples.ir(b)-1, BufDur.ir(b), doneAction:2) + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)) / BufSamples.ir(b),
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
		Dust.ar(40),    //2.2
		0.09, // 0.5 ,  0.001 , 0.0005, 1/20, 1/10, 1/5, 1/20
		b,
		1,
		(LFSaw.ar(1/BufDur.ir(b)).range(0, BufSamples.ir(b)-1) + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)) / BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;
}.play
)

{LFSaw.ar(10, 1)}.plot(0.2)



(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar(40),    //2.2
		0.09, // 0.5 ,  0.001 , 0.0005, 1/20, 1/10, 1/5, 1/20
		b,
		1,
		(Sweep.ar(Impulse.ar(1/BufDur.ir(b)), 0.2* BufRateScale.ir(b)) * SampleRate.ir + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)) / BufSamples.ir(b),
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
		Impulse.ar(40),    //2.2
	    1/20,
		b,
		1,
		(Phasor.ar(0, 4* BufRateScale.ir(b)), 0, BufSamples.ir(b)-1) + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)) / BufSamples.ir(b),
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
		Impulse.ar(40),
	    1/20, //0.2
		b,
	    -1.midiratio,
		(Phasor.ar(0, 1* BufRateScale.ir(b)), 0, BufSamples.ir(b)-1) + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)) / BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.5;
}.play
)






































