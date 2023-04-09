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

~a = Synth(\pulse, [freq: 100, width: 0.1, amp: 0.2, rel: 3, harm: 8]);
~b = Synth(\pulse, [freq: 200, width: 0.2, amp: 0.2, rel: 3, harm: 8]);
~c = Synth(\pulse, [freq: 300, width: 0.3, amp: 0.5, rel: 3, harm: 8]);
~d = Synth(\pulse, [freq: 400, width: 0.5, amp: 0.5, rel: 3, harm: 8]);



(
p = Pseq(list: [3, 7, -2, 10], repeats: 4, offset: 0);
q = p.asStream;
)  //offset起始值
//from that pattern we generate a stream called q. so q is the process that we can call next on and that was four repeats. so now we're at the end of that stream and there's nothing left


(
p = Pseq(list: [3, \hello, "something", 10], repeats: 4, offset: 0);  //pseq is often used as a number generator but the things in the array can be anything
q = p.asStream;
)

(
p = Pseq(list: [~a, ~b, ~c, ~d], repeats: 4, offset: 0);  //pseq is often used as a number generator but the things in the array can be anything
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
p = Pseries(0, 12, inf); //**
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


Pn //there's lots of situations where Pn and Pseq can be kind of interchanged
(
p = Pn(Pshuf((1..5), 1), inf); // 不用方括号
q = p.asStream;
)

q.next;


(
p = Pdup(2, Pwhite(1, 100, inf)); // a duplication number， a way of creating repeated copies
q = p.asStream;
)

q.next;



 //Pfunc evaluates a function and embeds The Returned value of that function into the stream
(
p = Pfunc({2});
q = p.asStream;
)

(
p = Pfunc({
	var num;
	num = 4;
	num = num + rrand(1,5);
	num = num + num.isPrime.asInteger; // prime 质数
});
q = p.asStream;
)

q.next;


//this rrand gets evaluated it's going to it's going to turn into some hard value and that's going to be permanently baked into this pattern
(
p = Pseq([10,20,30], rrand(1,3));
q = p.asStream;
)
q.reset; //if we reset this and start again it's not going to pick a different number and just because we reset, it does not compel the stream. because the pattern stream are separate objects the pattern has been defined
q.next;

// like Pfunc, P lazy evaluates a function and that function is supposed to return a pattern and that's the pattern that gets embedded in the Stream

//when we call next the Plazy is going to evaluate its function, and return this pattern. because we're actually evaluating this function, it's going to interpret the whole thing again and pick.  it's a way of forcing a pattern to come into existence again a new value
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
p = Pseries(-12, 2, 8);
q = p.asStream;
)

(
p = Pseries(-12, Pwhite(1, 6, inf), 8);
q = p.asStream;
)

q.next;

//make this random sequence of eight values that always starts at negative 12.
(
p = Pseq([ Pseries(-12, Pwhite(1, 6, inf), 8)], inf);
q = p.asStream;
)

q.next;
q.reset;

Synth(\pulse, [freq: (q.next + 60).midicps]);



/////////////////////// Class Event
//an event is basically a type of collection
// Reference: Collection
//Event is an unordered collection and the organizational structure is that each item has a unique name. it's a named space basically and event also has a literal syntactical representation

e = (guppy: 5, goldfish: 3, minnow: 4); //it's unordered when it appears in the post window

e[\minnow]

e[\goldfish] = e[\goldfish] + 3; //conventionally they're called keys, so the item at the Goldfish key set it equal to itself plus three

e[\goldfish]

e[\beta] = 2; //you can just spontaneously create keys

e.removeAt(\minnow); // remove the key
e.removeAt(\goldfish);
e.removeAt(\guppy);

//events are used to store things. but events are also used to model actions taken in response to a play message.

().play;// so you can have an empty event and play it
//this is possible because under the hood there is a vast and complex and sophisticated event prototype structure
//so there are many different types of events and each of those events models some sort of action, and the default action is to play. it create a synth and play a sound based on some synth Def

// there are different types of events.
//the example above, we're just making an event it doesn't have a type, it's just a collection of things


Event.eventTypes.keys; //all of the types of events that exist

//note event, note is actually the default type of event when you play an event which means we could say type note. note is the default type which means we don't have to specify it and that will be the type automatically chosen for us

//Reference: Browse -> Streams-Patterns-Events -> A Practical Guide -> Pattern Guide 08: Event Types and Parameters -> Event Types -> note

(type: \note).play;

//rest event
(type: \rest).play; //rest event just does nothing for a specific amount of time

//in post window:   "instrument" is the name of a synthdef  to use to create

//where the sound coming from? it is in the source code for the event class


(freq: 500).play
(amp: 0.1).play
(pan: 0.1).play


x = Synth(\default); //doesn't actually turn off because it's a sustaining envelope

x.set(\gate, 0); //so we need to set the gate to be zero in order to free it


//but the event structure (the event Paradigm) includes a key called sustain,  which automatically sends a gate zero message after sustained number of Beats.  it's kind of convenient because all of a sudden the process of turning a sustaining synth off is built into the playing mechanism
(sustain: 3).play  // turns off after three seconds



x = Synth(\pulse, [amp: 0.3, freq: 300]);


(instrument: \pulse).play

(instrument: \pulse, sustain: 3).play

(instrument: \pulse, sustain: 3, amp: 0.8, width: 0.05, blurf: 7).play
//check if synth def has a fixed duration envelope. the sustain key is automatically sending a gate zero. but it's not doing anything if this synthdef has an envelope that terminates itself automatically

//once you specify a synthdef, all of the arguments declared in that synthdef become keys that you can use in this event

//if we put something nonsensical in here, it becomes part of the event but there's no synthdef argument named blurf and there's no key in the underlying event Paradigm named blurf,  so it just kind of lives there in the event and has no effect on anything




