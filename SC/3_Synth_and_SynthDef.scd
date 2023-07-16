//UGen Function -> Play message

a = {SinOsc.ar(440, 0, 0.5)}.play;
(
z = {
	arg freq = 440, amp = 0.5;
	var sig;
	sig  = SinOsc.ar(freq, 0, amp);
}.play;
)
//------------------------------
(
z = {
	arg freq = 440, amp = 1;  //frequency = freq, amplitude = amp
	var sig; // signal 信号   snd = sound
	sig = SinOsc.ar(freq) * amp;
}.play;
)

z.set(\freq, 330); // set 设定
z.set(\amp, 0.125);
z.set(\freq, 660, \amp,1);
z.set(\amp,0.125, \freq, 550);
z.free;

//-------------------------------

// as frequency modulator
(
{ SinOsc.ar(
	LFNoise0.ar(4, 400, 450),
	0, 0.2
)
}.play;
)


(
z = {
	arg noiseHz = 8; // 8 times per second
	var freq, amp, sig;
	freq = LFNoise0.ar(noiseHz).exprange(200, 1000);  // Low frequencey 低频
	amp = LFNoise1.ar(12).exprange(0.02, 1);
	sig = SinOsc.ar(freq) * amp;
}.play;
)

z.set(\noiseHz, 64);
z.set(\noiseHz, exprand(4, 64));
z.free;


/*
Function.play is often more convenient than SynthDef.play, particularly for short examples and quick testing. The latter does have some additional options, such as lagtimes for controls, etc. Where reuse and maximum flexibility are of greater importance, SynthDef and its various methods are usually the better choice.

Methods such as Function-play, etc. are simply conveniences which automatically create such a def
*/


SynthDef.new(\sineTest,{
	arg noiseHz = 8;
	var freq, amp, sig;
	freq = LFNoise0.ar(noiseHz).exprange(200, 1000); // exponatial 指数
	amp = LFNoise1.ar(12).exprange(0.02, 1);
	sig = SinOsc.ar(freq) * amp;


	Out.ar(0, sig);  // bus 总线： 0表示 左声道， 1表示右声道
}).add;

x = Synth.new(\sineTest, [\noiseHz, 32]);
x.set(\noiseHz, 12);
x.free;


//---------------------------
(
SynthDef.new(\sineTest,{
	arg noiseHz = 8;
	var freq0, amp0, sig0，freq1, amp1, sig1;
	freq0 = LFNoise0.ar(noiseHz).exprange(200, 1000);
	amp0 = LFNoise1.ar(12).exprange(0.02, 1);
	sig0 = SinOsc.ar(freq0) * amp0;
	Out.ar(0, sig);
	Out.ar(1, sig); // ?

}).add;
)

//------- 录音
{ SoundIn.ar(0) }.play;