s.boot;

(
~bowl = Buffer.read(s, "audio/prayer_bowl.aiff".resolveRelative);
~pvc = Buffer.read(s, "audio/pvc.aiff".resolveRelative);
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

(
r = Routine.new({
	Synth.new(\play, [buf: ~bowl, rate: -7.midiratio]);
	0.25.wait;
	Synth.new(\play, [buf: ~bowl, rate: -5.midiratio]);
	0.25.wait;
	Synth.new(\play, [buf: ~bowl, rate: 2.midiratio]);
	0.25.wait;
});
)

r.play

(
r = Routine.new({
	inf.do({
		[-7, -5, 2].do({ |n|
			Synth.new(\play, [buf: ~bowl, rate: n.midiratio]);
			0.25.yield;
		});
	});
});
)

r.next;

r.play;
r.stop;
r.reset;

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

(
~soundGen = Routine.new({
	inf.do({
		Synth.new(\play, [buf: ~bowl, rate: ~noteGen.next.midiratio]);
		0.25.yield;
	});
});
)
)

~soundGen.play;
~soundGen.stop;

~noteGen.next;
~noteGen.reset;

TempoClock.default.tempo;

t = TempoClock.new(72/60);

t.beats;

t.sched(0, {"hi".postln; 1;});

t.schedAbs(t.nextBar, {"hi".postln});

t.beatsPerBar;

t.stop;

(
~postinfo = { t.beats.postln; 1; };
t = TempoClock.new(72/60).permanent_(true);
t.sched(0, { ~postinfo.() });
)

~postinfo = { };

(
~postinfo = { t.beats.postln; 1; };
t.schedAbs(t.nextBar, { t.tempo_(130/60) });
)

t.sched(4, {"hi".postln});

t.schedAbs(t.nextBar, {"hi".postln});

t.beatsPerBar;

t.beats;

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

~soundGen = Routine.new({
	inf.do({
		Synth.new(\play, [buf: ~bowl, rate: ~noteGen.next.midiratio]);
		0.25.yield;
	});
});
)

~soundGen.play(t, [4, -1]);

~soundGen.stop;

~soundGen.reset;

t.tempo_(108/60);
