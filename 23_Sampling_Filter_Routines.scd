s.boot;



b.play;

b = Buffer.read(s, "23_Sampling_Filter_Routines/prayer_bowl.aiff".resolveRelative);

PathName.new(thisProcess.nowExecutingPath).parentPath ++ "audio/prayer_bowl.aiff";

(
~path = PathName.new(thisProcess.nowExecutingPath).parentPath ++ "23_Sampling_Filter_Routines/prayer_bowl.aiff";
b = Buffer.read(s, ~path);
)

// a syntax shortcut which involves making the argument a symbol and then putting a rate that you wanted to run,  by default arguments will run at the control rate and that's a usually perfectly fine, and then give them a value

(
SynthDef.new(\play, {
	var sig, env;

	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: \buf.kr(0),
		rate: BufRateScale.kr(\buf.kr(0)) * \rate.kr(1),
		startPos: \spos.kr(0),
		loop: \loop.ir(0) // 0  means false
	);

	sig = LPF.ar(sig, \lpf.ir(20000).clip(20, 20000)); // 20000 pass everything,   clip = constrains the range
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
	sig = sig * \amp.kr(1); //a global amplitude control and we send it on out

	Out.ar(\out.kr(0), sig);
}).add;
)



//
var scale = [0, 3, 5, 7, 10];
Array.fill(8, {scale.choose})  // it fills an array with eight numbers chosen from our scale variable



(
var scale = [0, 3, 5, 7, 10]; // iterate by order of the array  //scale  minor pendatonic
Array.fill(8, {scale.choose}).do({ |n|   // the number of synth to iterate
	n = n + [11, 12, 0, -12, -24, -36].choose; // transpose (steps in semitones )
	Synth.new(
		\play,
		[
			buf: b.bufnum,
			rate: n.midiratio    // change the pitch
			* rrand(-0.2, 0.2).midiratio // in semitones
			* [1, -1].choose, // -1  reverse playback
			pan: rrand(-0.8, 0.8),
			atk: exprand(0.002, 0.2), // soften the attack
			rel: exprand(3, 10), // longer the release
			spos: s.sampleRate * rrand(2.0, 4.0), // 去掉淡出淡入
			loop: 1,
			amp: 1,
			hpf: 200,  // check differences
		]
	);
});
)


x = [10, 20, 30, 40, 50]
x[0]
x[[1,2,3]] //an array of the items at indices



(
var scale = [0, 3, 5, 7, 10];
var coll;
coll = scale.scramble; // randomize the array
coll = coll ++ scale.scramble[[0,1,2]]; // attach more items to the end of it
coll.do({ |n|
	n = n + [11, 12, 0, -12, -24, -36].choose;
	Synth.new(
		\play,
		[
			buf: b.bufnum,
			rate: n.midiratio
			* rrand(-0.2, 0.2).midiratio
			* [1, -1].choose,
			pan: rrand(-0.8, 0.8),
			atk: exprand(0.002, 0.2),
			rel: exprand(3, 10),
			spos: s.sampleRate * rrand(2.0, 4.0),
			loop: 1,
			amp: 1,
		]
	);
});
)

(
r = Routine.new({

	[-3, 0, 2].do({ |n| // orginally chord with three notes, now play as melody
		Synth.new(
			\play,
			[
				buf: b.bufnum,
				rate: n.midiratio
				* rrand(-0.2, 0.2).midiratio,
				pan: rrand(-0.8, 0.8),
				atk: exprand(0.002, 0.2),
				rel: exprand(3, 10),
			]
		);

		yield(rrand(0.1, 0.7));

	});

});
)

r.play;
r.next; // it just starts evaluating and as soon as it bumps into a yield it just stops. it doesn't treat it as a as a duration. it just says, this is a pause, we have to pause here.

r.reset;




