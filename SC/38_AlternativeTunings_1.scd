//UGen ->Tour of UGens
//Tutorials/A-Practical-Guide |
//Streams-Patterns-Events > A-Practical-Guide -> Pattern Guide 02: Basic Vocabulary
              //-> Pattern Guide 08: Event Types and Parameters


//Standard Tuning : 12-Note Equal Temperament---------------------

{SinOsc.ar(523.2511306012, 0, 0.5)}.play;

//MIDI Notes-------------
60.midicps // middle C   cycle per second
61.midicps // C sharp
72.midicps // C in the next higher octave


{SinOsc.ar(72.midicps, 0, 0.5)}.play;


//Midiratio---------
0.midiratio // first note
1.midiratio // second note
12.midiratio // first note, one actave up

(0.midiratio) * 440
(1.midiratio) * 440
(12.midiratio) * 440

{SinOsc.ar((0.midiratio) * 440, 0, 0.5)}.play;
{SinOsc.ar((7.midiratio) * 440, 0, 0.5)}.play;

//third note of the chromatic scale plus a quarter tone
{SinOsc.ar((2.5.midiratio) * 440, 0, 0.5)}.play;

60
6000 c
6100 c#
6200 d
6250
6300 #d


//same
f = {|degree, root = 440|
	(degree.midiratio)*root
};


{SinOsc.ar(f.(0), 0, 0.5)}.play;
{SinOsc.ar(f.(7), 0, 0.5)}.play;
{SinOsc.ar(f.(2.5), 0, 0.5)}.play;

(
//read a whole sound into memory
s = Server.local;
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");  // remember to free the buffer later
)

(
SynthDef(\help_PlayBuf, {| out = 0, bufnum = 0, rate = 1 |
    Out.ar(out,
    Pan2.ar(
			PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate, loop:1), 0)
    )
}).add;
)

p = Synth(\help_PlayBuf, [\rate, 0.midiratio, \out, 0, \bufnum, b.bufnum]); //original pitch
p.set(\rate, 12.midiratio); //one octave up
p.set(\rate, 7.midiratio); // seven semitones up (5th)

p.free;
p = nil;
b.free;
b = nil;

//Pbind with \midinote
(
Pbind(
	\midinote, Pseq([0, 2, 3, 5, 7] + 60, inf),
	\dur, 0.3
).play
)


//Pbind with \midinote and cents
(
Pbind(
	\midinote, Pseq([0, 2, 3, 5.25, 7.5] + 60, inf),
	\dur, 0.3
).play
)
//5 + 250 cents


//Pbind with \note  与midinote 不同
(
Pbind(
	\note, Pseq([0, 2, 4, 5, 7, 9, 11, 12] + 60, inf),
	\dur, 0.3,
	\octave, 1
).play
)


//Pbind with \degree
(
Pbind(
	\degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7], inf),
	\dur, 0.3,
	\octave, 5
).play
)

//Pbind with \degree and \scale
(
Pbind(
	\degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7], inf),
	\dur, 0.3,
	\octave, 5,
	\scale, (0..11) //chromatic scale
).play
)

//Pbind with \degree and \scale and cents
(
Pbind(
	\degree, Pseq([0, 2, 2.1, 2.05], inf),
	\dur, 0.3,
	\scale, (0..11),
	\octave, 5
).play
)


//Other Equal Temperaments-----------------
//Pbind with \stepPerOctave
(
Pbind(
	\note, Pwhite(-6, 9),
	\dur, 0.3,
	\sustain, 1.1,
	\stepPerOctave, 7 // 7 equal notes per octave
).play
)


(
e = Pbind(
	\degree, Pwhite(-3, 7),
	\dur, 0.25,
	\stepPerOctave, 21,
	\sustain, 1.1,
	\scale, [0, 4, 8, 11, 14, 17]  // define the interval
).play;
)


(
//previous example should still be running
e.stream = Pbind(
	\degree, Pwhite(-3, 7),
	\dur, 0.25,
	\stepPerOctave, 21
	\sustain, 1.1,
	\scale, [0, 3, 5, 8, 10, 13]
).asStream;
)

DWGBowed

1/12
2 * 1/12
3* 1/12

// Calculation of Equal Temperament -----------
2.pow(degree/stepsPerOctave);


//third note of the 12-equal-note tuning system
2.pow(1/12)
2.pow(3/12)



(
var stepsperoctave = 3;
Array.fill(stepsperoctave, {arg i; 2.pow(i/stepsperoctave)});
)

//Using a function to calculate the value at a chosen degree

(
f = {|degree, steps|
	2.pow(degree/steps)
};
)

// degree 0
f.(0, 3);

// degree 1
f.(1, 3);

// degree 2
f.(2, 3);

// the function is modified to multiply the value by a root frequency in Hertz
(
f = {|degree, steps, root = 440|
	2.pow(degree/steps)*root
};
)

// 12 notes per octave, degree 0, 1 and 12
f.(0, 12);
f.(1, 12);
f.(12, 12);

// 14 notes per octave, degree 0, 1 and 12 and 14
f.(0, 14);
f.(1, 14);
f.(12, 14);
f.(14, 14);



//Using degreeToKey (method)-------------------------------------
// *(DegreeToKey is a UGen that converts a signal to modal pitch.)

0.degreeToKey((0..13), 14)
1.degreeToKey((0..13), 14)
15.degreeToKey((0..13), 14)


0.degreeToKey([0, 3, 5, 9], 14)
1.degreeToKey([0, 3, 5, 9], 14)
15.degreeToKey([0, 3, 5, 9], 14)

//getting the degree
a = 0.degreeToKey([0, 3, 5, 9], 12)
//calculating the frequency
2.pow(a/12)*440

//another degree in the scale
b = 4.degreeToKey([0, 3, 5, 6], 12)
//calculating the frequency
2.pow(b/12)*440


//Unequal divisions of the Octave-----------------------------

// Custom UnequaL Division of the Octave
a = [1, 1.030303030303, 1.0606060606061, 1.1212121212121, 1.2121212121212, 1.3636363636364, 1.6060606060606]

//--------
a = [1, 2 ,3, 5, 8, 13, 21]

//--------- ++++
b = a.linlin(1, 2024, 1, 2);

b * 220


// Pbind with unequal octave divisions for \freq
(
SynthDef(\tone2,
	{arg freq = 440, amp = 0.5, gate = 1, envdur = 1.5;
	var sound, env;
	env = EnvGen.kr(Env.perc(0.01, envdur), doneAction: 2);
	sound = Pan2.ar(SinOsc.ar(freq, 0, amp)* env, 0);
	Out.ar(0, sound);
}).add;
)

(
a = [1, 1.030303030303, 1.0606060606061, 1.1212121212121, 1.2121212121212, 1.3636363636364, 1.6060606060606] * 220;

e = Pbind(
	\freq, Pseq(a, inf),
	\dur, 0.2,
	\amp, 0.5,
	\sustain, 0.6,
	\instrument, \tone2
).play

)
//choose the notes randomly
(
e.stream = Pbind(
	\freq, Pn(Prand(a, 1)),
	\dur, 0.2,
	\amp, 0.5,
	\sustain, 0.6,
	\instrument, \tone2
).asStream
)


//Just intonation 纯律
//Well temperament 良律
//Meantone temperament 中庸全音律

//Using Odd-limit ratios with sound
(
~rationames = [1/1, 8/7, 7/6, 6/5, 5/4, 4/3, 7/5, 10/7, 3/2, 8/5, 5/3, 12/7, 7/4];
~scale = [0, 3, 5, 8, 10, 12];

e = Pbind(
	\freq, Pseq([
		Pfunc({
			(~rationames.wrapAt(~scale).[~scale.size.rand])*440
		})
	], inf),
	\dur, 0.25,
	\amp, 0.5,
	\sustain, 0.6,
	\instrument, \tone2
).play; // returna an EventStream
)

~scale = [0, 2, 5, 7, 9, 11];
~scale = [0, 1, 3, 5, 6, 8, 9];
~scale = [0, 3, 5, 8, 10, 12];

(
var n, buts, synthes, ratios, rationames;
w = Window("tonality diamond", Rect(200, 500, 420, 150));
w.view.decorator = FlowLayout(w.view.bounds);

Rationames = [
	"7/4", "3/2","5/4", "1/1",
	"7/5", "6/5","1/1", "8/5",
	"7/6", "1/1","5/3", "4/3",
	"1/1", "12/7","10/7", "8/7",
];

n.rationames.size;

n.do({ |i|
Button(w, Rect(20, 20+(i*30), 100, 30))
.states_([[rationames[i], Color.black,
if((rationames[i]) == "1/1", {Color.red}, {Color.yellow})
	]
	])
.action_({arg butt;
Synth(\tone2, [\freq, ((rationames[i].interpret)*440]);

})
});
w.font;
)


































































































