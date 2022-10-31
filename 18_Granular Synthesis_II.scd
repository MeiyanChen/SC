ServerOptions.devices;

(
s.options.inDevice_("Built-in Microph");
s.options.outDevice_("Built-in Output");
s.boot;
s.meter;
)

//uses a comb filter to apply a feedback delay to the mic signal


(
x = {
	var sig;
	sig = SoundIn.ar(0!2);
	sig = sig + CombN.ar(sig, decaytime:1, mul:0.5);
}.play;
)

x.free;

// grainIn
//the main thing it does is apply little grain windows to an input signal allowing those parts to be heard.

(
x = {
	var sig;
	sig = SoundIn.ar(0!2);
	sig = GrainIn.ar(1, Dust.ar(20), 0.08, sig); //with approximately 20 grains per second each 0.08 seconds long
}.play;
)


//// grain in by itself is essentially kind of a glorified envelope generator for example if we swap grainIn for EnvGen specify a sinusoidal shape point oh eight seconds long and we trigger the envelope in the same way we get almost exactly the same sound pretty much indistinguishable from first example.  so it's not the grain in is totally useless you could certainly combine it with other signal processors like delays and filters maybe some iteration or multi-channel expansion
(
x = {
	var sig;
	sig = SoundIn.ar(0!2);
	sig = sig * EnvGen.ar(Env.sine(0.08), Dust.ar(20));
}.play;
)


/*
first we allocate an empty one channel buffer just a block of
memory where we can read and write audio samples. let's say five seconds long, and then in terms of signal processing we'll have four discrete parts:

1. a synthdef that uses soundin to read a signal from audio hardware and writes it to a bus, so that other processes can access it
2. a synthdef that generates a periodic ramp 斜面，  and writes that signal to a different bus ， conceptually the output range corresponds to the size of the buffer with the duration of one complete cycle being equal to buffer duration
3. a synthdef that reads the mic signal and ramp signal from those two buses and records the microphone signal
into the buffer using the ramp as a sample index,  because the ramp sign periodically repeats this means that when we reach the end of the buffer we automatically jump back to the beginning and overwrite old samples with new
samples
4. a synthdef that uses grainbuf to generate grains from the contents of the buffer. for the grain start position we use the same ramp signal , but we subtract 减去 some amount from that signal use a modulo operation to wrap the result within the appropriate range,  and in effect we get a grain start pointer that tags along behind the record pointer sort of endlessly chasing it around.

modulo operation: https://zh.wikipedia.org/wiki/%E6%A8%A1%E9%99%A4

there's a few interesting variations on this idea for one thing we could add a little randomness to the grain pointer so that it skitters around as it moves and this will have the effect of jumbling syllables and generally making the

recording less intelligible

and another variation just because we only have one grain buff synthdef doesn't mean we're only allowed to make one synth for example we could make 5 synth, so that we have 5 grain pointers all generating grains independently all following behind the record pointer

now you might be wondering why bother anchoring the grain pointer to the record pointer at all,  can't we just pull grains from anywhere in the buffer,
well technically yes, you can.  but this brings us to the main pitfall of this approach

at any point in time there's almost guaranteed to be a discontent in the buffer at the record head right between the oldest and newest recorded sample
and if we ignore this discontinuity or don't properly factor
it into our algorithm , for example if we generate a grain that is longer than the distance between these two pointers then that grain will include the discontinuity and we're likely to hear a big ugly click and generally we try to avoid this because it sounds bad

and just in case you don't quite know what I'm talking about when I say big ugly click



here's an example of what a grain might sound like if you fall into this trap and I'm gonna intentionally make this click sound fairly egregious
it's not good so
generally this is why we tether the grain pointer to the record pointer basically so that we have a strong guarantee that grains won't spill over and collide with this discontinuity
*/




//first allocate an empty buffer, this duration is mostly arbitrary you could make it smaller although Mike a little claustrophobic around one second or so but larger is certainly fine,  so 30 60 seconds especially if you want to capture a recording of stuff that happens over a relatively long period of time  third is the number of buffer channels we want one one is also the default so technically we don't need it but I'm gonna leave it here for clarity

b = Buffer.alloc(s, s.sampleRate*5, 1);


//next we need two one channel audio busses one of the mic, one for the pointer and again one is the default for a number of channels but I'm gonna type it in anyway

(
~micBus = Bus.audio(s, 1);
~ptrBus = Bus.audio(s, 1);
)


(
//reads a signal from a hardware input bus with an amplitude control just in case we want to mute or adjust the level and out it goes onto a bus
SynthDef.new(\mic, {
	arg in = 0, out = 0, amp = 1;
	var sig;
	sig = SoundIn.ar(in) * amp;
	Out.ar(out, sig);
}).add;


//use phaser to generate a repeating ramp to index into the buffer, the end value is defined as the rap point which means the ramp it generates goes up to that value but is never actually equal  to that value so for the end value we need bufframes not bufframes -1

SynthDef.new(\ptr, {
	arg out = 0, buf = 0;
	var sig;
	sig = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
	Out.ar(out, sig);
}).add;

//reading the mic signal, reading the ramp signal, and recording into the buffer
SynthDef.new(\rec, {
	arg ptrIn = 0, micIn = 0, buf = 0;
	var ptr, sig;
	ptr = In.ar(ptrIn, 1); //pointer,
	sig = In.ar(micIn, 1); //live sound
	BufWr.ar(sig, buf, ptr); //buf right to record sig into buf using pointer as the sample index
}).add;
)



SynthDef.new(\gran, {
	arg amp = 0.5, out = 0, atk = 1, rel = 1, gate = 1, sync = 1, dens = 40, baseDur = 0.05, durRand = 1, rate = 1, rateRand = 1, pan = 0, panRand = 0, grainEnv = (-1);

	var sig, env, densCtrl, durCtrl, rateCtrl, panCtrl;
 //we have an envelope for overall amplitude a basic attack sustained-release shape that can be held open with a gate basically this just gives us an easy way to turn granulator x' on and off with a nice fade in and fade out

//grain density control exactly the same as it was in the last video

//grain duration control also exactly the same except I changed this argument name from door to bassdoor

//rate control here I've decided to multiply by a noise generator so that the overall playback rate can be randomized within a range

//and pan control with a bass pan value and a random amount of spread

	env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction:2);
	densCtrl = Select.ar(sync, [Dust.ar(dens), Impulse.ar(dens)]);
	durCtrl = baseDur*LFNoise1.ar(100).exprange(1/durRand, durRand);
	rateCtrl = rate*LFNoise1.ar(100).exprange(1/rateRand, rateRand);
	panCtrl = pan + LFNoise1.kr(100).bipolar(panRand);

	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;



SynthDef.new(\gran, {
	arg amp = 0.5,buf = 0, out = 0,
	    atk = 1, rel = 1, gate = 1,
	    sync = 1, dens = 40,
	    baseDur = 0.05, durRand = 1,
	    rate = 1, rateRand = 1,
	    pan = 0, panRand = 0,
	    grainEnv = (-1), ptrBus = 0, ptrSampleDelay = 20000;

	var sig, env, densCtrl, durCtrl, rateCtrl, panCtrl, ptr;

	env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction:2);
	densCtrl = Select.ar(sync, [Dust.ar(dens), Impulse.ar(dens)]);
	durCtrl = baseDur*LFNoise1.ar(100).exprange(1/durRand, durRand);
	rateCtrl = rate*LFNoise1.ar(100).exprange(1/rateRand, rateRand);
	panCtrl = pan + LFNoise1.kr(100).bipolar(panRand);

	/*focused on the grain pointer how it interacts with other parameters and just generally making sure that our grains don't have clicks

to start we need to read in the pointer signal so we are adding a new pointer variable and pointer bus along with it

as we saw in the visual demo the grain pointer lags behind the record pointer by some amount

so let's declare an argument to represent that value for a sensible default I'll arbitrarily say 20,000 samples
but we can change this at instantiation time if we want
and at a very basic level what we want to do is subtract this delay from the sample pointer so that would look like this and then because grain buff expects a normalized pointer between 0 and 1 , divide this value by the number of frames in the buffer
but there's an issue we need to consider here let's imagine a specific moment in time when the pointer signal is at 0 or just slightly above if the pointer delay is 20,000 samples or some other larger number,  then the end result is a negative pointer value but grain buff expects something between 0 and 1

so probably a good idea to wrap this value between 0 and 1 which we can do with pointer dot wrap 0 comma 1
or alternatively we can take the pointer value modulo 1 which has the same effect this being said it seems grain buff actually does this modulo operation internally
	*/

	ptr = In.ar(ptrBus, 1);
	ptr = ptr - ptrSampleDelay;
	ptr  = ptr/BufFrames.kr(buf);
	ptr = ptr % 1;

	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;


z = Buffer.read(s, );
z.play;

{GrainBuf.ar(2, Impulse.ar(2.5), 0.5, z, 1, -5.4)}.play;





SynthDef.new(\gran, {
	arg amp = 0.5,buf = 0, out = 0,
	    atk = 1, rel = 1, gate = 1,
	    sync = 1, dens = 40,
	    baseDur = 0.05, durRand = 1,
	    rate = 1, rateRand = 1,
	    pan = 0, panRand = 0,
	    grainEnv = (-1), ptrBus = 0, ptrSampleDelay = 20000;
	    ptrRandSamples = 5000, minPtrDelay = 1000;

	var sig, env, densCtrl, durCtrl, rateCtrl, panCtrl, ptr, ptrRand, totalDelay;

	env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction:2);
	densCtrl = Select.ar(sync, [Dust.ar(dens), Impulse.ar(dens)]);
	durCtrl = baseDur*LFNoise1.ar(100).exprange(1/durRand, durRand);
	rateCtrl = rate*LFNoise1.ar(100).exprange(1/rateRand, rateRand);
	panCtrl = pan + LFNoise1.kr(100).bipolar(panRand);

	/*the grain position is 0.6 and as long as we change this value in increments of 1  even going into negative values the results are identical

so I'm pretty confident that putting a modulo operation in the synth def is technically not necessary

now if we want to implement that random skittering pointer effect will need a noise generator, which I'll call pointer Rand
and I'm gonna give this a default range of 5,000 samples
because there are now two things affecting grain pointer position
I think it would be convenient to create a variable that represents the total number of samples, we're going to subtract from the incoming pointer so the total number of samples we subtract is equal to the base sample delay amount minus the point of randomness

and then down here we're going to subtract the total delay from the pointer

now here there's another possible issue: there's nothing in place to prevent the user from specifying a small base pointer delay and a large amount of randomness in which case total delay would often push the grain pointer forward in such a way that we'd very likely be capturing the buffer discontinuity in the grains and that's what we're trying to avoid so it'd be a really good idea to implement some sort of safety mechanism that forces total delay to be greater than some established minimum
and a very easy way to do this is to use max which compares two values and takes whichever is greater
	*/

	ptrRand = LFNoise1.kr(100).bipolar(ptrRandSamples);
	totalDelay = ptrSampleDelay - ptrRand;
	// totalDelay = max(ptrSampleDelay - ptrRand, minPtrDelay);

	ptr = In.ar(ptrBus, 1);
	ptr = ptr - ptrSampleDelay;
	ptr  = ptr/BufFrames.kr(buf);

	maxGrainDur = totalDelay / SampleRate.ir;
	durCtrl = min(durCtrl, maxGrainDur);

	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;





SynthDef.new(\gran, {
	arg amp = 0.5,buf = 0, out = 0,
	    atk = 1, rel = 1, gate = 1,
	    sync = 1, dens = 40,
	    baseDur = 0.05, durRand = 1,
	    rate = 1, rateRand = 1,
	    pan = 0, panRand = 0,
	    grainEnv = (-1), ptrBus = 0, ptrSampleDelay = 20000;
	    ptrRandSamples = 5000, minPtrDelay = 1000;

	var sig, env, densCtrl, durCtrl, rateCtrl, panCtrl, ptr, ptrRand, totalDelay;

	env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction:2);
	densCtrl = Select.ar(sync, [Dust.ar(dens), Impulse.ar(dens)]);
	durCtrl = baseDur*LFNoise1.ar(100).exprange(1/durRand, durRand);
	rateCtrl = rate*LFNoise1.ar(100).exprange(1/rateRand, rateRand);
	panCtrl = pan + LFNoise1.kr(100).bipolar(panRand);

	ptrRand = LFNoise1.kr(100).bipolar(ptrRandSamples);
	totalDelay = ptrSampleDelay - ptrRand;
	// totalDelay = max(ptrSampleDelay - ptrRand, minPtrDelay);

	ptr = In,ar(ptrBus, 1);
	ptr = ptr - ptrSampleDelay;
	ptr  = ptr/BufFrames.kr(buf);

	maxGrainDur = (totalDelay / rateCtrl)/ SampleRate.ir;
	durCtrl = min(durCtrl, maxGrainDur);

	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;


sig = GrainBuf.ar(
		2,
		densCtrl,
		durCtrl,
		buf,
		rateCtrl,
		ptr,
		2,
		panCtrl,
		grainEnv
	);

	sig = sig * env * amp;

	Out.ar(out, sig);
}).add;


s.plotTree;



(
~micGrp = Group.new;
~ptrGrp = Group.after(~micGrp);
~recGrp = Group.after(~ptrGrp);
~granGrp = Group.after(~recGrp);
)


(
Synth(\mic, [\in,0, \out,~micBus], ~micGrp);
Synth(\ptr, [\buf, b, \out,~ptrBus], ~ptrGrp);
Synth(\rec, [\ptrIn, ~ptrBus, \micIn, ~micBus, \buf, b], ~recGrp);
~g = Synth(\gran, [
	\amp, 0.5,
	\buf, 0, //b
	\out, 0,
	\atk, 1,
	\rel, 1,
	\gate, 1,
	\sync, 1,
	\dens, 40,
	\baseDur, 0.05,
	\durRand, 1,
	\rate, 1,
	\rateRan, 1,
	\pan, 0,
	\panRand, 0,
	\grainEnv, -1,
	\ptrBus, 0,
	\ptrSampleDelay, 20000, // s.sampleRate/3,
	\ptrRandSamples, 5000, //0, s.sampleRate/6,
	\minPtrDelay, 1000,
], ~granGrp);
)




(
Synth(\mic, [\in,0, \out, ~micBus], ~micGrp);
Synth(\ptr, [\buf, b, \out, ~ptrBus], ~ptrGrp);
Synth(\rec, [\ptrIn, ~ptrBus, \micIn, ~micBus, \buf, b], ~recGrp);
)
(
b.zero;
~g = Synth(\gran, [
	\amp, 0.5,
	\buf, 0, //b
	\out, 0,
	\atk, 1,
	\rel, 1,
	\gate, 1,
	\sync, 1,
	\dens, 40,
	\baseDur, 0.05,
	\durRand, 1,
	\rate, 1,
	\rateRan, 1,
	\pan, 0,
	\panRand, 0,
	\grainEnv, -1,
	\ptrBus, 0,
	\ptrSampleDelay, 20000, // s.sampleRate/3,
	\ptrRandSamples, 5000, //0, s.sampleRate/6,
	\minPtrDelay, 1000,
], ~granGrp);
)


(
b.zero;
~g = Synth(\gran, [
	\amp, 0.5,
	\buf, 0, //b
	\out, 0,
	\atk, 1,
	\rel, 1,
	\gate, 1,
	\sync, 1,
	\dens, 40,
	\baseDur, 0.05,
	\durRand, 1,
	\rate, 1,
	\rateRan, 2.midiratio,
	\pan, 0,
	\panRand, 0.5,
	\grainEnv, -1,
	\ptrBus, ~ptrBus,
	\ptrSampleDelay, s.sampleRate/3,
	\ptrRandSamples, s.sampleRate/6,
	\minPtrDelay, 1000,
], ~granGrp);
)

~g.set(\gate, 0);



(
b.zero;
~g = 5.collect({
	arg n;
	Synth(\gran, [
	\amp, n.linlin(0, 4, -3, -20).dbamp,
	\buf, b,
	\out, 0,
	\atk, 1,
	\rel, 1,
	\gate, 1,
	\sync, 1,
	\dens, exprand(20, 40),
	\baseDur, 0.05,
	\durRand, 1.5,
	\rate, 1,
	\rateRand, 2.midiratio,
	\pan, 0,
	\panRand, 0.5,
	\grainEnv, -1,
	\ptrBus, ~ptrBus,
	\ptrSampleDelay, n.linlin(0, 4, 20000, s.sampleRate*2) ,
	\ptrRandSamples, 10000,
	\minPtrDelay, 1000,
], ~granGrp);
)


~g.set(\gate, 0);
~g.do({arg n; n.set(\gate, 0)})





b.plot;
s.defaultGroup.deepFree;






(
SynthDef.new(\mic, {
	arg in = 0, out = 0, amp = 1;
	var sig;
	sig = SoundIn.ar(in) * amp;
	Out.ar(out, sig);
}).add;

SynthDef.new(\ptr, {
	arg out = 0, buf = 0, rate = 1;
	var sig;
	sig = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
	sig.poll;
	Out.ar(out, sig);
}).add;

Synth(\ptr, [\buf, b, \out, ~ptrBus], ~ptrGrp);
~ptrGrp.set(\rate, 1);
s.default

SynthDef.new(\rec, {
	arg ptrIn = 0, micIn = 0, buf = 0;
	var ptr, sig;
	ptr = In.ar(ptrIn, 1);
	sig = In.ar(micIn, 1);
	BufWr.ar(sig, buf, ptr);
}).add;
)



SynthDef.new(\gran, {
	arg amp = 0.5, out = 0, atk = 1, rel = 1, gate = 1, sync = 1, dens = 40, baseDur = 0.05, durRand = 1, rate = 1, rateRand = 1, pan = 0, panRand = 0, grainEnv = (-1);

	var sig, env, densCtrl, durCtrl, rateCtrl, panCtrl;

	env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction:2);
	densCtrl = Select.ar(sync, [Dust.ar(dens), Impulse.ar(dens)]);
	durCtrl = baseDur*LFNoise1.ar(100).exprange(1/durRand, durRand);
	rateCtrl = rate*LFNoise1.ar(100).exprange(1/rateRand, rateRand);
	panCtrl = pan + LFNoise1.kr(100).bipolar(panRand);

	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;



(
b.zero;
~g = Synth(\gran, [
	\amp, 0.5,
	\buf, b,
	\out, 0,
	\atk, 1,
	\rel, 1,
	\gate, 1,
	\sync, 0,
	\dens, 200,
	\baseDur, 0.08,
	\durRand, 1.5,
	\rate, 1,
	\rateRand, 2.midiratio,
	\pan, 0,
	\panRand, 0.5,
	\grainEnv, -1,
	\ptrBus, ~ptrBus,
	\ptrSampleDelay, n.linlin(0, 4, 20000, s.sampleRate*2) ,
	\ptrRandSamples, 10000,
	\minPtrDelay, 1000,
], ~granGrp);
)



(
b.zero;
~g = Synth(\gran, [
	\amp, 0.5,
	\buf, b,
	\out, 0,
	\atk, 1,
	\rel, 1,
	\gate, 1,
	\sync, 0,
	\dens, 200,
	\baseDur, 0.1,
	\durRand, 1,
	\rate, 1,
	\rateRand, 1,
	\pan, 0,
	\panRand, 0.5,
	\grainEnv, -1,
	\ptrBus, ~ptrBus,
	\ptrSampleDelay, 0.2 * s.sampleRate * (-3.midiratio),  // 0.01 *
	\ptrRandSamples, 2000,
	\minPtrDelay, 1000,
], ~granGrp);
)


~ptrGrp.set(\rate, 0);



























































