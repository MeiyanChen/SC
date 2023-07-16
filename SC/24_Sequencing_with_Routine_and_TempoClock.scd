s.boot;

(
~bowl = Buffer.read(s, "23_Sampling_Filter_Routines/prayer_bowl.aiff".resolveRelative);
~pvc = Buffer.read(s, "23_Sampling_Filter_Routines/pvc.aiff".resolveRelative);
)

(
SynthDef.new(\play, {
	var sig, env;

	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: \buf.kr(0),
		rate: BufRateScale.kr(\buf.kr(0)) * \rate.kr(1),
		startPos: \spos.kr(0),
		loop: \loop.ir(0)
	);

	sig = LPF.ar(sig, \lpf.ir(20000).clip(20, 20000));
	sig = HPF.ar(sig, \hpf.ir(20).clip(20, 20000));

	env = EnvGen.kr(
		Env(
			levels: [0, 1, 0],
			times: [\atk.ir(0.02), \rel.ir(3)],
			curve: [-2, -4],
		),
		doneAction: 2
	);

	sig = Pan2.ar(sig, \pan.kr(0));
	sig = sig * env;
	sig = sig * \amp.kr(1);

	Out.ar(\out.kr(0), sig);
}).add;
)


Synth.new(\play, [buf: ~bowl, rate: -7.midiratio]);

(
r = Routine.new({  //hear all three at the same time
	Synth.new(\play, [buf: ~bowl, rate: -7.midiratio]);
	Synth.new(\play, [buf: ~bowl, rate: -5.midiratio]);
	Synth.new(\play, [buf: ~bowl, rate: 2.midiratio]);
});
).play;

(
r = Routine.new({
	Synth.new(\play, [buf: ~bowl, rate: -7.midiratio]);
	0.25.wait;  //at 60 beats per minute (a quator of a second)
	Synth.new(\play, [buf: ~bowl, rate: -5.midiratio]);
	0.25.wait;
	Synth.new(\play, [buf: ~bowl, rate: 2.midiratio]);
	0.25.wait;
});
)

r.play

(
r = Routine.new({
	inf.do({   // nest iterations
		[-7, -5, 2].do({ |n|
			Synth.new(\play, [buf: ~bowl, rate: n.midiratio]);
			0.25.yield; //without yield or wait, Interpreter to run an infinite amount of code as fast as possible, and then the server crash
		});
	});
});
)

//it performs an iteration block which results in three evaluations


r.next;

r.play;
r.stop;
r.reset; //rewinding back to the beginning and that lets you play it again


//stream is the parent class of many useful sequence based classes. and a stream is an object that represents a sequence of things which can sometimes be played as in the case of routine,  but all streams can respond or will respond to the routine.next message




// this routine doesn't really make sense to play.  it would not make sense to play this routine,  because then the yield times would be interpreted as durations to rest and the first one is -12. that's meaningless, you cannot rest for negative 12 beats

//it is for nesting (a random number generator / data sequence generator)
(
~noteGen = Routine.new({
	var pch;
	inf.do({ // an infinite Loop
		pch = -12; //initialize pitch
		8.do({  //inner iteration block which does the following eight times
			pch.yield; //yield the value of pitch
			pch = pch + rrand(1,6); // add a ramdon transposition
		});
	});
});
)

// yield is a stopping point  ->  yield that value and we pause and the routine is staying right at this moment until we say next and then it goes and it's picked a random value

~noteGen.next;
~noteGen.reset;
(

(
~soundGen = Routine.new({
	inf.do({
		Synth.new(\play, [buf: ~bowl, rate: ~noteGen.next.midiratio]);  //*
		0.25.yield;
	});
});
)
)

~soundGen.play;
~soundGen.stop;

~noteGen.next;
~noteGen.reset;

TempoClock.default.tempo; // beats per second

//https://zh.wikipedia.org/wiki/%E9%80%9F%E5%BA%A6_(%E9%9F%B3%E6%A8%82)

t = TempoClock.new(72/60); // 72 bpm = 72/60 bps
//Beat per minute, Beat per second

t = TempoClock.new(120/60); // 2 beat per second

t.beats;
// what is your current beat,  hold shift and return down and you can see it's it's counting beats here

//if we press command period I've pressed command period that destroys any Tempo clocks other than the default Tempo clock that one lives forever

//有时我们需要有效停止tempoclock， 有时不需要
t = TempoClock.new(120/60).permanent_(true); //永久有效， command period immune clock

t.sched(4, {"hi".postln;4;});  //sched -》 schedule, schedule the following function to be evaluated four beats from now //前一个四表示的是起始拍，后一个4表示间隔

//sched is a relative scheduling method that need provide two things. 1. a duration measured in Beats from now and  2. a function to be evaluated that many beats in the future

t.schedAbs(190, {"hi".postln});//absolute scheduling/ absolude beat value.  it is so that occurred on beat 190

t.schedAbs(t.nextBar, {"hi".postln; 1;}); //the default number of beats per bar, is a four
//so whenever I run this it sort of figures out its current beat, and it Compares it against it's beats per bar that is stored here. it just says okay what's the what's the beat number of the next cluster of four beats the next downbeat. basically so this is a way of of saying do this on the next downbeat. schedule this function on the next bar

t.beatsPerBar;

t.stop;




//post beats information in post windows

//if you schedule a function on a Tempo clock and it returns a number, then this function will be rescheduled that many beats later so it's a way to get a function to happen over and over and over again
(
~postinfo = { t.beats.postln; 1; }; //this is going to be the function that gets scheduled on the clock, 1 means a Tempo clock makes it reschedule everyone beat
t = TempoClock.new(60/60).permanent_(true);
t.sched(0, { ~postinfo.() });
)

t.sched(0, {"hi".postln; 1;}); // it schedules, it gonna at the immediately and it posts the string high and then Waits For One Beat and then schedules it again.there's no good way to unschedule this.  command period stop the clock

~postinfo = { }; //停止看到拍子unschedules this function because suddenly it's evaluating this function which has nothing in it so nothing happens and it doesn't return a number so no more function stuff


(//重启看到拍子
~postinfo = { t.beats.postln; 1; };
t.sched(0, { ~postinfo.() });
) //bring the function back , because the tempo clock is still going, we didn't stop the clock. we just unscheduled that function from it


//back on track
(
~postinfo = { t.beats.postln; 1; };
t.schedAbs(t.nextBar, { ~postinfo.() });
)


(
~postinfo = { t.beats.postln; 1; };
t.schedAbs(t.nextBar, { t.tempo_(130/60) });
)

t.sched(4, {"hi".postln});

t.schedAbs(t.nextBar, {"hi".postln});

t.beatsPerBar; // 每小节有几拍

t.beats;




(
~noteGen = Routine.new({
	var pch;
	inf.do({
		pch = -12.25;
		8.do({
			pch.yield;
			pch = pch + rrand(1.25,6.5);
		});
	});
});


1 - 12

~soundGen = Routine.new({
	inf.do({
		Synth.new(\play, [buf: ~bowl, rate: ~noteGen.next.midiratio]);
		0.25.yield; // number of beats,it is in fact following the tempo information of the clock
	});
});
)

~soundGen.play;//default tempoclock

~soundGen.play(t); //clock t, four notes for every one of these values

//we quantize it and we want this to come in on a beat that's a multiple of four and we provide the Quant information
~soundGen.play(t, 8); //it's going to look at uh sort of from time zero and it's got all of these four beats per bar and it's going  to come in on the next downbeat of a pair of two bars

~soundGen.play(t, [4, -1]);


~soundGen.stop;

~soundGen.reset;

t.tempo_(108/60); //change the tempo
