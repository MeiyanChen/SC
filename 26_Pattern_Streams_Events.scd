s.boot;


//Patterns
//-> value patterns:they Define sequences of values and usually these values are numbers

(
~noteGen = Routine.new({
	var pch;
	inf.do({
		pch = -12;
		8.do({
			pch.yield;
			pch = pch + rrand(1,6);
		});
	});
});
)

~noteGen.next;

(
SynthDef(\pulse, {
	var sig, env, freq, cf;

	freq = \freq.kr(100);
	freq = freq * { Rand(-0.1, 0.1).midiratio }.dup(4);
	cf = freq * \harm.ir(2);

	sig = Pulse.ar(freq, \width.ir(0.5)).sum * 0.1;
	sig = LPF.ar(sig, cf.clip(20, 20000));

	env = EnvGen.kr(
		Env.adsr,
		\gate.kr(1),
		doneAction: 2
	);

	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.2));
	sig = sig * env;
	Out.ar(\out.kr(0), sig);
}).add;
)

Synth(\pulse, [freq: 400, width: 0.5, amp: 0.5, rel: 3, harm: 8])



(
p = Pseq(list: [3, 7, -2, 10], repeats: 4, offset: 0);
q = p.asStream;
)  //offset起始值
//from that pattern we generate a stream called q. so q is the process that we can call next on and that was four repeats. so now we're at the end of that stream and there's nothing left


(
p = Pseq(list: [3, \hello, "something", 10], repeats: 4, offset: 0);  //pseq is often used as a number generator but the things in the array can be anything
q = p.asStream;
)

q.next; //重复四次以后 就不会有数据出现了
q.reset; //重新开始 same same Principle as routine


(
p = Prand([10, 20, 30], inf); // a list and a number of repeats  // it will simply randomly choose an item from that array
q = p.asStream;
)

q.next;

// any any pattern value pattern that accepts a repeats value that can be a number between one and a very large number，  or it can be INF which means do this forever. you can call next on it forever, and it will never exhaust. its supply of values,  there are a couple variations on Prand.

//there's pxRand this is a variation which picks randomly but will never pick the same item twice in a row

(
p = Pxrand([10, 20, 30], inf);
q = p.asStream;
)

//PX Rand is unaware that some of these items are equal. so you're very likely in this case to get some repeated values. it doesn't know if the atoms inside are equal, it just knows their indices and it never picks the same indexed item twice in a row
(
p = Pxrand([10, 20, 30, 30, 30, 30], inf);
q = p.asStream;
)

q.next;

//this one needs an additional array of Weights which must sum to a value of one
//this stream will output 10,  13 of the time 20 and 7 of the time 30.
(
p = Pwrand([10, 20, 30], [0.8, 0.13, 0.07] , inf); //weighted 加权的
q = p.asStream;
)

(
p = Pwrand([10, 20, 30], [8, 3, 2].normalizeSum, inf); //
q = p.asStream;
)// this returns an array where the relative proportions of these numbers Remains the Same,  but they've all been scaled so that their sum is one

q.nextN(40);// next n will give you the next n items


(
p = Pshuf((1..5), inf); //create a array in it.
q = p.asStream;
)

q.next;

//the nesting ability of patterns
(
p = Pseq([ Pshuf((1..5), 1) ], inf);
q = p.asStream;
)

q.next;


(
p = Pseries(0, 12, 4); //**
q = p.asStream;
)

(
p = Pseries(0, -3, inf); //**
q = p.asStream;
)

q.next.dbamp; //you can you can always convert to amplitude


(
p = Pgeom(1, 2, inf);
q = p.asStream;
)

(
p = Pgeom(1, 0.5, inf);
q = p.asStream;
)

//one musical application of Pgeom is to reduce something by a certain number of decibels
(
p = Pgeom(1, -3.dbamp, inf); //the amplitude ratio
q = p.asStream;
)

q.next;




(
p = Pwhite(1, 9.0, inf); //randomness of amplitude samples
q = p.asStream;
)

(
p = Pwhite(1, 9, inf);
q = p.asStream;
)

q.next;
//functionally the same
(
p = Prand((1..9), inf);
q = p.asStream;
)



(
p = Pexprand(1, 10000, inf); //it always outputs floats and it has an exponential like distribution
q = p.asStream;
)

q.next;

Pbrown()
Plprand() //向低选择
Phprand() //向高选择
Pmeanrand() //向中间选择

(
p = Pn(Pshuf((1..5), 1), inf);
q = p.asStream;
)

q.next;


(
p = Pdup(2, Pwhite(1, 100, inf));
q = p.asStream;
)

q.next;




(
p = Pfunc({
	var num;
	num = 4;
	num = num + rrand(1,5);
	num = num + num.isPrime.asInteger;
});
q = p.asStream;
)

q.next;


(
p = Pseq([10,20,30], rrand(1,3));
q = p.asStream;
)

q.next;


(
p = Plazy({
	Pseq([10,20,30], rrand(1,3))
});
q = p.asStream;
)

q.next;
q.reset;



(
~noteGen = Routine.new({
	var pch;
	inf.do({
		pch = -12;
		8.do({
			pch.yield;
			pch = pch + rrand(1,6);
		});
	});
});
)

~noteGen.next;

(
p = Pseries(-12, Pwhite(1, 6, inf), 8);
q = p.asStream;
)

q.next;


(
p = Pseq([ Pseries(-12, Pwhite(1, 6, inf), 8)], inf);
q = p.asStream;
)

q.next;
q.reset;

Synth(\pulse, [freq: (q.next + 60).midicps]);



///////////////////////

e = (guppy: 5, goldfish: 3, minnow: 4);

e[\minnow]

e[\goldfish] = e[\goldfish] + 3;

e[\goldfish]

e[\beta] = 2;

e.removeAt(\minnow);
e.removeAt(\goldfish);
e.removeAt(\guppy);

(type: \rest).play;

Event.eventTypes.keys;


(sustain: 3).play

x = Synth(\pulse, [amp: 0.3, freq: 300]);

x.set(\gate, 0);

(instrument: \pulse, sustain: 3, amp: 0.8, width: 0.05, blurf: 7).play






