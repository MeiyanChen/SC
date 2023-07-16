s.boot;

//slide from one value to the next over a period of time
// freq / amp

//lag滞后is a UGen. it's essentially a type of low-pass filter that causes a signal to interpolate between changes over a period of time. in the case of pitch, it creates a glissando effect.and in more general terms lag makes a signal behave sluggishly 慢吞吞地  like it's moving through molasses or something

(
SynthDef(\gliss, {
	arg freq = 440, gate = 1, amp = 0.3, out = 0;
	var sig, env;
	env = EnvGen.kr(Env.asr, gate, doneAction:2);
	sig = SinOsc.ar(freq)!2;
	sig = sig * amp;
	sig = sig * env;
	Out.ar(out, sig);
}).add;
)

x = Synth(\gliss);
x.set(\freq, 72.midicps);
x.set(\freq, 74.midicps);
x.set(\gate, 0);


//---------

(
SynthDef(\gliss, {
	arg freq = 440, gate = 1, amp = 0.3, out = 0;
	var sig, env;
	freq = Lag.kr(freq, 1); // pass it through a lag and provide the desired lag time in seconds and once the sound is running whenever that value changes it takes that much time to actually get there.
	//	freq = freq.lag(1); as a slightly shorter alternative we can use the convenience method .lag
	env = EnvGen.kr(Env.asr, gate, doneAction:2);
	sig = SinOsc.ar(freq)!2;
	sig = sig * amp;
	sig = sig * env;
	Out.ar(out, sig);
}).add;
)




(
SynthDef(\gliss, {
	arg freq = 440, freqlag = 1, gate = 1, amp = 0.3, out = 0;
	var sig, env;
	freq = freq.lag(freqlag); //* add a variable
	env = EnvGen.kr(Env.asr, gate, doneAction:2);
	sig = SinOsc.ar(freq)!2;
	sig = sig * amp;
	sig = sig * env;
	Out.ar(out, sig);
}).add;
)


x = Synth(\gliss);
x.set(\freq, 76.midicps, \freqlag, 0.25);
x.set(\freq, 71.midicps, \freqlag, 10);
x.set(\freq, 80.midicps, \freqlag, 0); //you can effectively bypass 避开 a lag by setting the lag time to 0. don't use negative numbers
x.set(\gate, 0);



//----------------
//lag gives us control over the duration of the interpolation. but it doesn't give any control over the shape of the interpolation curve, which in the case of lag is always exponential. and it's for this reason that i usually prefer varlag,  which has a similar convenience method in addition to a lag time,  varlag accepts a curve value and the behavior here is exactly like curve values for envelopes


(
SynthDef(\gliss, {
	arg freq = 440, freqlag = 1, freqcrv = (-5), gate = 1, amp = 0.3, out = 0;
	var sig, env;
	freq = freq.varlag(freqlag, freqcrv);
	env = EnvGen.kr(Env.asr, gate, doneAction:2);
	sig = SinOsc.ar(freq)!2;
	sig = sig * amp;
	sig = sig * env;
	Out.ar(out, sig);
}).add;
)

//so 0 is linear positive values, bend the shape so that the value changes slowly at first and then quickly towards the end.
// negative values bend in the opposite way and as this value gets further away from zero the shape of the curve becomes more extreme

x = Synth(\gliss);
x.set(\freq, 220, \freqlag, 2, \freqcrv, 0);
x.set(\freq, 440, \freqlag, 2, \freqcrv, 15); // 先慢后快
x.set(\freq, 220, \freqlag, 2, \freqcrv, -15);//先快后慢
x.set(\gate, 0);

//so here's our tone going down an octave over two seconds linearly going up an octave with a positive curve and down an octave once more with a negative curve



//when applied to pitch negative curves tend to be more useful. because when a value changes,  a negative curve moves it close to its target quickly and then levels off,  which is kind of the natural and most common way to perform a glissando.
//whereas positive curves cause the value to stay mostly where it is until the very end of the lag time.  so there's kind of this awkward delay.


//------------------------
//lag is not just useful for frequency can be applied to just about anything

//lag the amplitude, creating a sort of dynamic envelope that can be controlled stage by stage逐步地,  using set messages.


(
SynthDef(\gliss, {
	arg freq = 440, freqlag = 1, freqcrv = 0, amplag = 0.3, ampcrv = 0, amp = 0, out = 0;
	var sig;
	freq = freq.varlag(freqlag, freqcrv);
	sig = SinOsc.ar(freq)!2;
	sig = sig * amp.varlag(amplag, ampcrv);
	Out.ar(out, sig);
}).add;
)


x = Synth(\gliss, [\amp, 0]);
x.set(\amp, 0.3, \amplag, 1, \ampcrv, -2);
x.set(\amp, 0, \amplag, 3, \ampcrv, -10);
x.set(\gate, 0);



//--------------

// another use for lag if you have an external physical controller, like a motion sensor or something.  that kind of data tends to be jumpy and typically you don't want to plug that straight into your synthesis algorithm because it makes your sound all wobbly and unstable

//lag is very handy here, capable of smoothing out that data once it's mapped onto some synthetic argument, softening all the hard edges and becoming much friendlier for musical applications


//now quick note about var lag though it is useful and flexible.  it can and likely will exhibit weird behavior if applied to an audio rate signal as discussed in this warning, here at the top of the help file
//but lag has a few other siblings, lag2and lag3 are shortcuts for double and triple nested lags. so to wrap up here's one more example to help visualize these behaviors


VarLag.kr

(
{
	var sig;
	sig = LFNoise0.kr(50); //sig here is a sample and hold noise generator. it's basically a random staircase shape producing 50 values per second
	[
		sig, //the original noise
		sig.lag(0.01),//noise passed through a lag
		sig.lag2(0.01),
		sig.lag3(0.01),
		sig.lag3(0.01).lag3(0.01)  //two lag2 in series which would be the equivalent of lag six, each with a lag time of 0.01 seconds
	];
}.plot(0.5, bounds:Rect(100, 200, 1700, 7500)); // plot half a second of five different signals.
)


//all these signals get progressively smoother, as we lag them more aggressively.


















