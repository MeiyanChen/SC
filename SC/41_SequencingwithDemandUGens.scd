//by design, patterns are language-side, and although it is often useful to have this separation from the audio server, it does mean that we can't plug them directly in a Demand UGensSynthDef.

//However, there's a category of Demand UGens that produce pattern-like behavior, most of them actually have nearly the same name as their pattern counterparts. These demand classes can be incorporated into a UGen function and applied directly to audio and control signals. They're kinda like sequencer modules on an analog synth, so they're a good choice for arpeggiators, rhythm generators, and just about anything sequential in nature.



s.options.sampleRate = 48000;
s.boot;


(
SynthDef(\d, {
	var freq, sig;
	freq = Pseq([200, 300, 400], inf);  // not working!!!!
	sig = Saw.ar(freq, mul:0.1 ! 2);
	Out.ar(0, sig);
}).play;
)



//load the Dorian mode into a buffer, which is just the integers 0, 2, 3, 5, 7, 9, 10.

b = Buffer.loadCollection(s, Scale.dorian);
b.plot;


 // a basic filtered sawtooth instrument.
(
SynthDef(\d, {
	var freq, sig;
	freq = 50.midicps;
	freq = freq * {Rand(-0.1, 0.1).midiratio}.dup(4);
	sig = Saw.ar(freq);
	sig = Splay.ar(sig);
	sig = MoogFF.ar(sig, 1500);
	Out.ar(0, sig);
}).play;
)




(
SynthDef(\d, {
	var freq, sig, trig, deg;
	trig = Impulse.ar(4); //start with an impulse generator as a basic timing signal
	deg = Demand.ar(
		trig,    //Demand receives those triggers
		0,  //ignore for now
		Dseq([0, 2, -1, -3], inf) //demand-based pattern,  Dseq: step through its values in order
	);
	freq = (DegreeToKey.ar(b, deg) + 50).midicps; //use DegreeToKey, basically just retrieves buffer values by index, allowing us to use consecutive integers to traverse the scale.
	freq = freq * {Rand(-0.1, 0.1).midiratio}.dup(4);
	sig = Saw.ar(freq);
	sig = Splay.ar(sig);
	sig = MoogFF.ar(sig, 1500);
	Out.ar(0, sig);
}).play;
)


(
SynthDef(\d, {
	var freq, sig, trig, deg;
	trig = Impulse.ar( MouseX.kr(2, 150, 1));  //MouseX and MouseY to control impulse rate and cutoff frequency, for a little interactive fun and also to help understand what's going on a little bit more clearly.
	deg = Demand.ar(
		trig,
		0,
		Dseq([0, 2, -1, -3], inf)
	);
	freq = (DegreeToKey.ar(b, deg) + 50).midicps;
	freq = freq * {Rand(-0.1, 0.1).midiratio}.dup(4);
	sig = Saw.ar(freq);
	sig = Splay.ar(sig);
	sig = MoogFF.ar(sig, MouseY.kr(100, 8000, 1));
	Out.ar(0, sig);
}).play;
)


//-----------------------------------
// Duty is similar to Demand but interprets its first argument as a duration instead of expecting a trigger signal.



(
SynthDef(\d, {
	var freq, sig, trig, deg;
	deg = Duty.ar(
		1/4,    //  Drand([1/4. 1/8], inf)   //but the duration doesn't have to be static, Duty Pattern in fact it can be any signal, like an LFO or even another demand-style pattern, like Drand.
		0,
		Dseq([0, 2, -1, -3], inf)
	);
	freq = (DegreeToKey.ar(b, deg) + 50).midicps;
	freq = freq * {Rand(-0.1, 0.1).midiratio}.dup(4);
	sig = Saw.ar(freq);
	sig = Splay.ar(sig);
	sig = MoogFF.ar(sig, 1500);
	Out.ar(0, sig);
}).play;
)


 //The reset argument can be used to restart a sequence at any point. So, for example, if the duration is 1/8 and we want a repeating sequence of 11 notes, we can use an impulse generator with a frequency of 8/11 because frequency and period are inversely related.
(
SynthDef(\d, {
	var freq, sig, trig, deg;
	deg = Duty.ar(
		1/8,
		Impulse.ar(8/11),  //The reset argument can be used to restart a sequence at any point. So, for example, if the duration is 1/8 and we want a repeating sequence of 11 notes, we can use an impulse generator with a frequency of 8/11 because frequency and period are inversely related.
		Dseq([0, 2, -1, -3], inf)
	);
	freq = (DegreeToKey.ar(b, deg) + 50).midicps;
	freq = freq * {Rand(-0.1, 0.1).midiratio}.dup(4);
	sig = Saw.ar(freq);
	sig = Splay.ar(sig);
	sig = MoogFF.ar(sig, 1500);
	Out.ar(0, sig);
}).play;
)


//Just like patterns, demand UGens can be nested inside of each other for more complex results,so here's a composite rhythmic sequence, and a little bit of randomness on the second pitch value.

(
SynthDef(\d, {
	var freq, sig, trig, deg;
	deg = Duty.ar(
		Dseq([
			Dseq([1/4, 1/8], 4),
			Dseq([1/8], 4)
		], inf),
		0,
		Dseq([0, Drand([2, 3, 4], 1), -1, -3], inf)
	);
	freq = (DegreeToKey.ar(b, deg) + 50).midicps;
	freq = freq * {Rand(-0.1, 0.1).midiratio}.dup(4);
	sig = Saw.ar(freq);
	sig = Splay.ar(sig);
	sig = MoogFF.ar(sig, 1500);
	Out.ar(0, sig);
}).play;
)


//-----------------------------
//For amplitude sequencing, we can use TDuty to trigger an envelope according to some unique rhythm.
//TDuty is very similar to Duty. but outputs its values as triggers, instead of sample-and-hold behavior, as you can see on these two plots.

(
x = {
	[TDuty, Duty]. collect{ |n|
		n.ar(
			0.0005,
			0,
			Dseq([1, 7, 3], inf),
		);
	}
}.plot(bounds: Rect(400, 250, 110, 600)).parent.name_("TDuty vs. Duty");
)



(
SynthDef(\d, {
	var freq, sig, trig, deg;
	trig = TDuty.ar(
		Dseq([0.75, 0.75, 0.5], inf),  // So, a little syncopated rhythm for these triggers, and since we're just gating an envelope, we don't need some complicated value sequence — just any positive number is fine.
		0,
		1
	);
	deg = Duty.ar(
		2,  //slow things down, because eight chord changes per second seems a little fast.
		0,
		Dseq([0, 2, -1, -3], inf)
	);
	freq = (DegreeToKey.ar(b, deg + [0, 4, 6, 7, 8, 9]) + 50).midicps; //If we want a chord progression, all we have to do is create some array representing a stack of scale degrees, add it to the base degree value, taking advantage of multichannel expansion.
	freq = freq * {Rand(-0.1, 0.1).midiratio}.dup(4);
	sig = Saw.ar(freq);
	sig = Splay.ar(sig);
	sig = MoogFF.ar(
		sig,
		Env(  //A very analog synth thing to do here is modulate the cutoff frequency with another envelope controlled by the same trigger signal.
			[100, 1500, 100],
			[0.05, 0.75],
			-4
		).ar(gate:trig);
	);
	sig = sig * Env.perc(0.005, 0.5).ar(gate:trig);
	Out.ar(0, sig);
}).play;
)


// Dconst
// it outputs values according to its second input until the sum of those values would exceed the threshold represented by the first value, at which point it truncates the last value to fit.

(
SynthDef(\d, {
	var freq, sig, trig, deg;
	trig = TDuty.ar(
		Dseq([ //wrap this in a Dseq so that the whole process repeats.
			Dconst(4, 0.75) //So, in this specific case we'll get 0.75, five times in a row, which adds up to 3.75, and then the sixth value is shortened to 0.25.
		], inf),
		0,
		1
	);
	deg = Duty.ar(
		2,
		0,
		Dseq([0, 2, -1, -3], inf)
	);
	freq = (DegreeToKey.ar(b, deg + [0, 4, 6, 7, 8, 9]) + 50).midicps;
	freq = freq * {Rand(-0.1, 0.1).midiratio}.dup(4);
	sig = Saw.ar(freq);
	sig = Splay.ar(sig);
	sig = MoogFF.ar(
		sig,
		Env(
			[100, LFTri.kr(1/16, 3).exprange(200, 2500), 100], //LFO modulating cutoff frequency
			[0.05, 0.75],
			-4
		).ar(gate:trig);
	);
	sig = sig * Env.perc(0.005, LFTri.kr(1/16, 3).exprange(0.15, 4)).ar(gate:trig); //an LFO for the envelope release
	sig = sig + CombN.ar(sig, 0.5, 0.5, 4, -12.dbamp);  // delay
	sig = sig.blend(LPF.ar(GVerb.ar(sig, 200, 5).sum, 1000, 0.33)); //reverb
	Out.ar(0, sig);
}).play;
)









