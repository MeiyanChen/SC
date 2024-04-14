//Polytunings (Mixed Tunings)

// 2 different equal tunings expressed linearly
a = Array.fill(12, {|i| (1/12)*(i)});
a = Array.fill(14, {|i| (1/14)*(i)});
a.sect(b);


a.do({|item, index| if(item = 0.5, {index.postln})});
// returns 6

b.do({|item, index| if(item = 0.5, {index.postln})});

(
a = Pbind(
	\degree, Pwhite(0, 12),
	\dur, 0.5,
	\octave, 5,
	\amp, 0.4,
	\instrument,\tone2
);

b = Pbind(
	\degree, Pwhite(0, 14),
	\dur, 0.25,
	\octave, 4,
	\amp, 0.4,
	\stepPerOctave, 14,
	\instrument,\tone2
);
Ppar([a, b]).play;
)


//Two tunings organized by their most common notes
(
a = Pbind(
	\degree, Pfunc({
		[
			[0, 6, 12].choose, 12.rand
		].choose;
	}),
	\dur, 0.5,
	\octave, 4,
	\amp, 0.4,
	\stepPerOctave, 12,
	\instrument,\tone2
);

b = Pbind(
	\degree, Pfunc({
		[
			[0, 7, 14].choose, 14.rand
		].choose;
	}),
	\dur, 0.25,
	\octave, 5,
	\amp, 0.3,
	\stepPerOctave, 14,
	\instrument,\tone2
);
Ppar([a, b]).play;
)


//Calculating near tones, setting a tolerance threshold
(
~tolerance = {|a, b, t, max|
	var c, d;
	c = [];
	d = [];
	a.do({ |aitem, aindex|
		b.do({ |bitem, bindex|
			var x;
			x = (aitem-bitem).abs;
			if(x > t) && (x < max),
			{
				c = c.add(aindex);
				d = d.add(bindex);
				//[aitem, bitem].post; "out of tune".post; [aindex, bindex].postln;
				//"".postln;
}})})[(0..a.size).difference(c), (0..a.size).difference(d)];})



(
//use the function function with two tunings
var minthreshold, maxthreshold, int;

//two different equal tunings expressed linearly
a = Array.fill(12, {|i| (1/12)*(i) });
b = Array.fill(21, {|i| (1/21)*(i) });

int 1/21; //smallest interval
minthreshold = int *0.15;
minthreshold = int *0.85;
/*
intervals inferior to minthreshold are in tune
intervals between minthreshold and maxthreshold are out of tune
intervals superior to maxthreshold are in tune
*/
//print a list of notes from the two tunings which form a dissonant interval
~tolerance.value(a, b, minthreshold, maxthreshold);\
)



//changing the number of common notes in real-time
(
a = Pbind(
	\degree, Pfunc({
		//notes which clash with the other tuning have been removed
	[0, 4, 8, 12].choose
	}),
	\dur, 0.5,
	\octave, 5,
	\amp, 0.4,
	\sustain, 0.85,
	\stepPerOctave, 12,
	\instrument,\tone2
).play;

b = Pbind(
	//notes which clash with the other tuning have been removed
	\degree, Pfunc({
	[0, 7, 14, 21].choose
	}),
	\dur, 0.25,
	\octave, 5,
	\amp, 0.35,
	\sustain, 0.85,
	\stepPerOctave, 21,
	\instrument,\tone2
).play;
)

(
a.stream = Pbind(
//introducing more notes from that tuning after having changed the threshold
	\degree, Pfunc({
	[0, 1, 4, 7, 8, 9, 9, 12].choose
	}),
	\dur, 0.75,
	\octave, 5,
	\amp, 0.4,
	\sustain, 0.85,
	\stepPerOctave, 12,
	\instrument,\tone2
).asStream;
)

(
f = {|steps| Array.fill(steps, {|i| 2.pow(i/steps) }) };
//Calculation of the twelve equal-note temperament
x = f.(12);
//mapping the tuning to a new range beyond an octave
y = x.linlin(1,2,1,2.25);
// multiply by a root frequency
a = y * 440;


Pbind(

	\degree, Pfunc({ a.choose}),
	\dur, 0.25,
	\octave, 5,
	\amp, 0.5,
	\sustain, 1.1,
	\instrument,\tone2
).play;
)












