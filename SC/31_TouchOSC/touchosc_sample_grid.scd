(
//requires "sample grid demo.touchosc" interface loaded onto mobile device

~rate = 1;
~amp = 0.25;
~send = -60;
~imphz = 10;

s.newBusAllocators;
~bus = Bus.audio(s, 2);

s.waitForBoot({

	Buffer.freeAll;
	s.sync;

	b = ();

	//substitute your own sample libraries here:
	b.glitch = PathName("/Users/eli/Sounds/scaudio/glitch/").entries.collect({
		arg n;
		Buffer.readChannel(s, n.fullPath, channels:[0]);
	});
	b.caltone = PathName("/Users/eli/Sounds/scaudio/calTone/glitch/").entries.collect({
		arg n;
		Buffer.read(s, n.fullPath);
	});

	SynthDef(\p, {
		var sig, env, trig;
		env = Env.asr(\atk.kr(0.001), \sus.kr(1), \rel.kr(0.001)).ar(0, \gate.kr(1));
		trig = Impulse.ar(\imphz.kr(20).lag(0.05));
		sig = PlayBuf.ar(
			1,
			\buf.kr(0),
			BufRateScale.kr(\buf.kr(0)) * \rate.kr(1).lag(0.05),
			trig,
			\spos.kr(0),
			\loop.kr(0)
		);
		sig = sig * env;
		sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.2).lag(0.05));
		Out.ar(\out.kr(0), sig);
		Out.ar(\outfx.kr(0), sig * \send.kr(-60).dbamp.lag(0.05));
	}).add;

	SynthDef(\v, {
		var sig;
		sig = In.ar(\in.kr(0), 2);
		sig = GVerb.ar((sig[0] + sig[1]) * -3.dbamp, 249, 4);
		sig = LPF.ar(sig, 1200);
		Out.ar(\out.kr(0), sig);
	}).add;

	s.sync;

	~bufnums = Prand((b.glitch ++ b.caltone), inf)
	.asStream.nextN(64).collect({arg n; n.bufnum});

	s.bind({
		~g = Group.new;
		~verb = Synth(\v, [\in, ~bus], ~g, \addAfter);
		~synths = 64.collect({
			arg n;
			Synth(\p, [
				\out, 0,
				\outfx, ~bus,
				\buf, ~bufnums[n],
				\gate, 0,
				\rate, ~rate,
				\send, ~send,
				\amp, ~amp,
				\loop, 0,
				\imphz, ~imphz,
				\atk, 0.02,
				\rel, 0.02,
			], ~g);
		});
	});

	s.sync;

	(1..8).do({
		arg row;
		(1..8).do({
			arg col;
			var index;
			index = ((row-1) * 8) + (col-1);
			OSCdef(("touchosc" ++ row ++ col).asSymbol, {
				arg msg;
				~synths[index].set(\gate, msg[1]);
			}, ("/1/multipush1/"++row++"/"++col).asSymbol, nil, 57120);
		});
	});

	OSCdef(\fader1, {
		arg msg;
		~rate = msg[1].linlin(0,1,-48,48).midiratio;
		~g.set(\rate, ~rate);
	}, '/1/fader1', nil, 57120);

	OSCdef(\fader2, {
		arg msg;
		~send = msg[1].linlin(0,1,-60,0);
		~g.set(\send, ~send);
	}, '/1/fader2', nil, 57120);

	OSCdef(\fader3, {
		arg msg;
		~imphz = msg[1].lincurve(0,1,1,4000,7);
		~g.set(\imphz, ~imphz);
	}, '/1/fader3', nil, 57120);

	OSCdef(\fader4, {
		arg msg;
		~amp = msg[1].lincurve(0,1,0,1,3);
		~g.set(\amp, ~amp);
	}, '/1/fader4', nil, 57120);

	OSCdef(\notesoff, {
		arg msg;
		if(msg[1] == 1, {~g.set(\gate, 0)});
	}, '/1/push1', nil, 57120);
});
)
