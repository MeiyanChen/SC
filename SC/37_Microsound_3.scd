//----------------------------------
// different control strategies applied to density
//synchronous, quasi-synchronous, asynchronous
edgard varese



( // synchronous - regular time intervals
Pbindef(\grain0).clear;
Pbindef(\grain0).play;
Pbindef(\grain0,
	\instrument, \expodec,
	\freq, Pn(Penv([200, 1200], [10], \exp), inf),
	\dur, 0.1, \sustain, 0.06
);
)

// different fixed values
Pbindef(\grain0, \dur, 0.06) // rhythm
Pbindef(\grain0, \dur, 0.035)
Pbindef(\grain0, \dur, 0.02) // fundamental frequency 50Hz

// time-changing values:accelerando/ritardando
Pbindef(\grain0, \dur, Pn(Penv([0.1, 0.02], [4], \exp), inf));
Pbindef(\grain0, \dur, Pn(Penv([0.1, 0.02, 0.06, 0.01].scramble, [3, 2, 1], \exp), inf));

//repeating values: rhythms or tones  /*
Pbindef(\grain0, \dur, Pstutter(Pwhile(2, 15), Pfunc({ Pexprand(0.01, 0.3) })));

// introducing irregularity - quasi-synchronous
Pbindef(\grain0, \dur, 0.03 * Pwhite(0.8, 1.2))
Pbindef(\grain0, \dur, 0.03 * Pbrown(0.6, 1.4, 0.1)) //slower drift 布朗运动
Pbindef(\grain0, \dur, 0.03 * Pwhite(0.2, 1.8))

//average density constant, vary degree of irregularity
Pbindef(\grain0, \dur, 0.02 * Pfunc({(0.1.linrand * 3) + 0.9}));
Pbindef(\grain0, \dur, 0.02 * Pfunc({(0.3.linrand * 3) + 0.3}));
Pbindef(\grain0, \dur, 0.02 * Pfunc({(1.0.linrand * 3) + 0.0}));
Pbindef(\grain0, \dur, 0.02 * Pfunc({2.45.linrand.squared}));// very irregular


( //coupling - duration depends on freq parameter
Pbindef(\grain0,
	\freq, Pn(Penv([200, 1200], [10], \exp), inf),
	\dur, Pfunc({|ev| 20/ev.freq})
);
)

(
Pbindef(\grain0).clear;
Pbindef(\grain0,
	\instrument, \expodec,
	\freq, 200,
	\sustain, 0.05, \dur, 0.07
).play;
)

//time-varying freq with envelope pattern
Pbindef(\grain0, \freq, Pn(Penv([200, 1200], [10], \exp), inf));

//random freq
Pbindef(\grain0, \freq, 400 * Pwhite(-24.0, 24).midiratio);

//timechanging with random variation
Pbindef(\grain0, \freq, Pn(Penv([400, 2400], [10], \exp), inf) * Pwhite(-24.0, 24).midiratio);

//panning
Pbindef(\grain0, \pan, Pwhite(-0.8, 0.8)); //random
Pbindef(\grain0, \pan, Pn(Penv([-1, 1], [2]), inf)); //tendency
Pbindef(\grain0, \pan, Pfunc({|ev| ev.freq.explin(50, 5000, -1, 1)})); // coupled to freq

//time scattering variants
Pbindef(\grain0, \dur, 0.1 * Pwhite(0.5, 1.5)); //random range
Pbindef(\grain0, \dur, 0.05 * Prand([0, 1, 1, 2, 4], inf)); //rhythmic random

//amplitude - randomized
Pbindef(\grain0, \amp, Pwhite(0.01, 0.2));//linear
Pbindef(\grain0, \amp, Pwhite(-50, -14).dbamp); // exponential -more depth
Pbindef(\grain0, \dur, 0.025 * Prand([0, 1, 1, 2, 4], inf)); //could be denser now




//random amplitude envelopes with Pseq /*
(
Pbindef(\grain0,
	\amp, Pseq(
		Pxrand([-50, -20, -30, -40] + 10, inf), //level pattern
		Pxrand([0.5, 1, 2, 3], inf),
		Prand([\step, \lin], inf)
	).dbamp
);
)

//grain sustain time coupled to freq
Pbindef(\grain0, \sustain, Pkey(\freq).reciprocal * 20).play;








//-----------------------------------
//Granular systhesis on the server
// TGrain, GrainSin, GrainFM, GrainBuf, GrainIn, Wrap


//----------   GrainSin
p = ProxySpace.push;
(
~grain.play;
~grain = {arg envbuf = -1, density = 10, graindur = 0.1, amp = 0.2;
	var pan, env, freqdev;
	var trig = Impulse.kr(density);
	pan = MouseX.kr(-1, 1); //use mouse-x for panning
	//use WhiteNoise and mouseY to control deviation from center
	freqdev = WhiteNoise.kr(MouseY.kr(400, 0).poll);
	GrainSin.ar(2, trig, graindur, 440 + freqdev, pan, envbuf) *amp
};
)


// GrainSin 's envelop need to store in the buffer first

q = q ? (); //make a dictionary to keep things around

q = ();
q.envs = (); //space for some envelopes
q.bufs = (); //and some bufffers
             //make an envelope and send it to a buffer
q.envs.perc1 = Env([0, 1, 0], [0.1, 0.9], -4);
q.bufs.perc1 = Buffer.sendCollection(s, q.envs.perc1.discretize, 1); //discretize离散化 represent or approximate (a quantity or series) using a discrete quantity or quantities.给缓存器里的包络一个特定的内存大小？
~grain.set(\envbuf, -1); //switch to built-in envelope
~grain.set(\envbuf, q.bufs.perc1.bufnum); //or customized

~grain.set(\density, 20);
~grain.set(\graindur, 0.03);

//map a control proxy to a parameter
~grdur = 0.1; ~grain.map(\graindur, ~grdur);
~grdur = {LFNoise1.kr(1).range(0.01, 0.1)}; //random graindur
~grdur = {SinOsc.kr(0.3).range(0.01, 0.1)}; //periodic
~grdur = 0.01; //fixed value

//create random densities from 2 to 2 ** 6, exponentially distributed
~grdensity = {2 ** LFNoise0.kr(1).range(0, 6)};
//map to density control
~grain.map(\density, ~grdensity);





//---------------------GrainFM  (frequency modulation)
~grain = {arg envbuf = -1, density = 10, graindur = 0.1, modfreq = 200;
	var pan = WhiteNoise.kr;
	var trig = Impulse.kr(density);
	var freqdev = WhiteNoise.kr(MouseY.kr(0, 400));
	var modrange = MouseX.kr(1, 10);
	var moddepth = LFNoise1.kr.range(1, modrange);
	GrainFM.ar(2, trig, graindur, 440 + freqdev, modfreq, moddepth, pan, envbuf ) *0.2
};


//-------------------------
// GrainFM with individual control proxies
p = ProxySpace.push;

(
~trig =  {|dens = 10| Impulse.kr(dens)};
~freq = {MouseX.kr(100, 2000, 1) * LFNoise1.kr(1).range(0.25, 1.75)};
~moddepth = {LFNoise1.kr(20).range(1, 10)};
~modfreq = 200;
~graindur = 0.1;

~grain = { arg envbuf = -1;
	GrainFM.ar(2, ~trig.kr, ~graindur.kr,
		~freq.kr, ~modfreq.kr, ~moddepth.kr,
		pan: WhiteNoise.kr, envbufnum: envbuf) * 0.2
};
~grain.play;
)

// change control ugens:
~modfreq ={ ~freq.kr * LFNoise2.kr(1).range(0.5, 2.0)}; //modfreq roughly follows freq
~trig = { |dens = 10| Dust.kr(dens)}; // random triggering, same density
~freq = {LFNoise0.kr(0.3).range(200, 800)};
~moddepth = 3; // fixed depth
~graindur ={LFNoise0.kr.range(0.01, 0.1)};




//------------------------
//GrainBuf with control proxies
//Soundfile granulation 颗粒化

//b = Buffer.read(s, "sounds/a11wlk01.aiff");
b = Buffer.readNoUpdate(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

//play original soundfile
(
x = SynthDef(\help_Buffer, { arg out = 0, bufnum;
    Out.ar( out,
        PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum))
    )
}).play(s,[\bufnum, b]);
)

// use Node proxies to play sound file
(
~grain.set(\wavebuf, b.bufnum); //arg will stay with set

~trig = {|dens = 10| Impulse.kr(dens)};
~graindur = 0.1;
~filepos = {LFNoise2.kr(0.2).range(0, 1)};
~rate = {LFNoise1.kr.range(0.5, 1.5)};

~grain = {arg envbuf = -1, wavebuf = 0;
	GrainBuf.ar(2, ~trig.kr, ~graindur.kr, wavebuf,
		~rate.kr, ~filepos.kr, 2, WhiteNoise.kr, envbuf) * 0.2
	};
~grain.play;
)

//experiment with control proxies

~trig = {|dens = 20| Impulse.kr(dens)};
~rate = {LFNoise1.kr.range(0.99, 1.01)};
~filepos = {MouseX.kr + LFNoise0.kr(100, 0.03)};
~graindur = 0.05;
~trig = { |dens = 50| Dust.kr(dens)};

c = Buffer.sendCollection(s, Env.perc(0.01, 0.99).discretize, 1);
~grain.set(\envbuf, c.bufnum);
~grain.set(\envbuf, -1);

~trig = {|dens = 50| Impulse.kr(dens)}; ~graindur = 0.05;




//---------------------------------------------------
//Exploring Granular Synthesis Flavors

SynthDef(\grainFM1, {|out, envbuf, carfreq = 440, modfreq = 200, moddepth = 1, sustain = 0.02, amp = 0.2, pan|
	var env = Osc.ar(envbuf, sustain);
	var sound = SinOsc.ar(carfreq, SinOsc.ar(modfreq) * moddepth) * env;
	OffsetOut.ar(out, Pan2.ar(sound, pan, amp))
}, \ir.dup(8)).add;

Synth(\grainFM1, [\out, 0]);

SynthDef(\grainBuf1, {|out, envbuf, wavebuf, filepos, rate = 1, sustain = 0.02, amp = 0.2, pan|
	var env = Osc.ar(envbuf, sustain);
	var sound = PlayBuf.ar(1, wavebuf, rate * BufRateScale.ir(wavebuf), 1, startPos:BufFrames.ir(wavebuf) * filepos) * env;
	OffsetOut.ar(out, Pan2.ar(sound, pan, amp))
}, \ir.dup(8)).add;

Synth(\grainBuf1);

//Glisson synthesis

(
b = Buffer.alloc(s, 2048);
b = Buffer.readNoUpdate(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

SynthDef("glisson",
	{ arg out = 0, envbuf, freq = 800, freq2 = 1200, sustain = 0.001, amp = 0.2, pan = 0.0;
		var env = Osc.ar(envbuf, sustain);
		var freqenv = XLine.ar(freq, freq2, sustain);
		OffsetOut.ar(out, Pan2.ar(SinOsc.ar(freqenv) * env, pan, amp)
		)
	}, \ir!7).add;
)


(
Tdef(\gliss0, { |e|
	100.do({ arg i;
		s.sendBundle(s.latency, ["/s_new", "glisson", -1, 0, 0,
			\freq, i % 10 * 100 + 1000,
			\freq2, i % 13 * -100 + 3000,
			\sustain, 0.05,
			\amp, 0.1,
			\envbuf, b.bufnum
		]);
		(3 / (i + 10)).wait;
	});

}).play;
)


//------------------------------------
(
q = ();
q.curr = (); //make a dict for the set of tables
q.curr.tab = ();
             //random tables for pulsaret and envelope waveforms
q.curr.tab.env = Env.perc.discretize;
q.curr.tab.pulsaret = Signal.sineFill(1024, {1.0.rand}.dup(7));

            //random tables for the control parameters;
q.curr.tab.fund = 200 ** Env({1.0.rand}!8, {1.0.rand}!7, \sin).discretize.as(Array);
q.curr.tab.form = 500 ** (0.5 + Env({rrand(0.0, 1.0)}!8, {1.0.rand}!7, \sin).discretize.as(Array));
q.curr.tab.amp = 0.2.dup.(1024);
q.curr.tab.pan = Signal.sineFill(1024, {1.0.rand}.dup(7));

            //make buffers from all of them;
q.bufs = q.curr.tab.collect({|val, key| Buffer.sendCollection(s, val, 1)});
)
    //plot one of them
q.bufs.pulsaret.plot("a pulsaret");


//--------------------------------------
// Pulsars as nodeproxies using GrainBuf
(
p = ProxySpace.push;

  // fund, form, amp, pan
~controls = [16, 100, 0.5, 0];
~pulsar1.set(\wavebuf, q.bufs.pulsaret.bufnum);
~pulsar1.set(\envbuf, q.bufs.env.bufnum);

~pulsar1 = { |wavebuf, envbuf = -1|
	var ctls = ~controls.kr;
	var trig = Impulse.ar(ctls[0]);
	var grdur = ctls[1].reciprocal;
	var rate = ctls[1] * BufDur.kr(wavebuf);

	GrainBuf.ar(2, trig, grdur, wavebuf, rate, 0, 4, ctls[3], envbuf);
	};
	~pulsar1.play;
)

// crossfade between control settings
~controls.fadeTime = 3;
~controls = [16, 500, 0.5, 0]; //change formfreq
~controls = [50, 500, 0.5, 0]; //change fundfreq
~controls = [16, 100, 0.5, 0]; //change both
~controls = [rrand(12, 100), rrand(100, 1000)];

(//control parameters from looping tables
~controls = { |looptime = 10|
	var rate = BufDur.kr(q.bufs.pulsaret.bufnum)/looptime;
	A2K.kr(PlayBuf.ar(1, [\fund, \form, \amp, \pan].collect(q.bufs[_]), rate: rate, loop: 1));
};
)

q.bufs.pulsaret.sendCollection(Array.linrand(1024, -1.0, 1.0)); //noise burst
q.bufs.pulsaret.read("sounds/a11wlk01.wav", 44100 *1.5);//sample

q.bufs.pulsaret.sendCollection(Pbrown(-1.0, 1.0, 0.2).asStream.nextN(1024));

// make a new random fundfreq table, and send it
q.curr.tab.fund = 200 ** Env({1.0.rand}!8, {1,0.rand}!7, \sin).discretize.as(Array);
q.bufs.fund.sendCollection(q.curr.tab.fund);

//and a new random formfreq table
q.curr.tab.form = 500 ** (0.5 + Env({rrand(0.0, 1.0)}!8, {1,0.rand}!7, \sin).discretize.as(Array);
q.bufs.form.sendCollection(q.curr.tab.form);



















































































































