s.options.memSize = 2.pow(20);
s.reboot;

b = Buffer.read(s, PathName(thisProcess.nowExecutingPath).parentPath ++ "/delay.aiff");

b.play;

(
//Select uses in index to select a signal from an array
SynthDef(\source, {
	var sig;
	sig = Select.ar(\choose.kr(0), [
		SoundIn.ar(0!2),
		PlayBuf.ar(1!2, b, loop:1),
	]);
	sig = sig * \amp.kr(1);
	Out.ar(\out.kr(0), sig);
}).add;
)

(
//setup code for busses, synths, groups
~setup = {
	s.newBusAllocators;
	~fxBus = Bus.audio(s,2);
	s.bind({
		~sourceGrp = Group.new;
		~src = Synth(\source, [\out, ~fxBus], ~sourceGrp);
		~fxGrp = Group.after(~sourceGrp);
	});
};
ServerTree.removeAll;
ServerTree.add(~setup);
)

(
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2);
	del = DelayN.ar(sig, 1, \del.kr(0.5)); //a default delaytime of half a second and a maximum delay of one second
	sig = sig.blend(del, \mix.kr(0.4)); //blend it with the input signal
	Out.ar(\out.kr(0), sig);
}).add;
)

~del = Synth(\del, [\in, ~fxBus], ~fxGrp);
~del.set(\del, 1); //change the delay time

//comb filters. it is called a filter but it is actually just a delay. it's called the filter because it has the ability to drastically change the spectrum of a sound and really color it. in this way that we often think of as filtering

//a delay line with a feedback path, so everything that is output by the delay line is scaled by some coefficient and fed back into the delay line so we'll just swap this delayN for combN

(
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2);
	del = CombN.ar(sig, 1, \del.kr(0.5), \dec.kr(5)); //the decay time is a value in seconds. by default it's 1 and it represents the amount of time it will take for this feedback delayto decay by 60 decibels
	sig = sig.blend(del, \mix.kr(0.4));
	Out.ar(\out.kr(0), sig);
}).add;
)

~del = Synth(\del, [\in, ~fxBus], ~fxGrp);
~del.set(\del, 1/60);// try  1/20, 1/40, 1/200

//when the delay time gets smaller than one twentieth of a second or so, then the echoes start to occur fast enough that they sort of fuse together into a sense of pitch. you can think of the delay time as being the inverse of the resonant frequency 共振频率的倒数
//for example 1 over 60 we get a very strong resonance at 60 hertz and all of its harmonics because all the harmonics of 60 hertz also line up perfectly with the delayed copies of the signal so we get this kind of thing


//allpass filters: it includes an additional design component which shifts the phase. it introduces a frequency dependent phase shift into the signal
(
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2);
	del = AllpassN.ar(sig, 1, \del.kr(0.5), \dec.kr(5));
	sig = sig.blend(del, \mix.kr(0.4));
	Out.ar(\out.kr(0), sig);
}).add;
)

~del = Synth(\del, [\in, ~fxBus], ~fxGrp);
~del.set(\del, 1/50);

//it's just you're never going to get  allpass filters to resonate in the way comb filters resonate. so comb filters are useful if you want to just create this very overt metallic ringing resonant sensation. when you use comb filters it's actually usually a good idea to limit the signal (use Limiter to constrain the volume)

// if you want to constrain the amplitude because the resonance is just completely unchecked in comb filters but all pass filters they have this phase scattering component which causes them to have a much more mellow effect




//dynamic comb filter delay---------------------
//if we're doing a dynamic delay we should use an interpolating comb filter or an interpolating delay

//comb filters
(
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2);
	del = CombL.ar(sig, 1, SinOsc.kr(0.1).exprange(0.01, 0.2), \dec.kr(4));
	sig = sig.blend(del, \mix.kr(0.4));
	Out.ar(\out.kr(0), sig);
}).add;
)
//we get pitch shifts that go up and down with a comb filter that pitch shifted signal is fed back into itself and in this case it's going to take four seconds to decay down to 60 decibels quieter

~del = Synth(\del, [\in, ~fxBus], ~fxGrp);
~del.set(\del, 1/50);

//try a different unit generator to to modulate the delay time

///////////////////////////////////////

//reverb effect using delay lines
// other reverb FreeVerb, GVerb
//check in Browse -> Tutorials -> Mark Pollshook tutorial > Delays reverbs -> Reverbration
(
//schroeder-like reverb
SynthDef(\reverb, {
	var sig, wet, dec = \dec.kr(3); //control the decay time
	sig = In.ar(\in.ir(0), 2);
	wet = DelayN.ar(sig, 0.1, \predel.kr(0.03)); //pre-delay is the time that it takes between the direct sound to hit you and the very earliest reflection
	wet = 6.collect({ //the signal goes through six all pass filters
		CombC.ar(wet, 0.1, LFNoise1.kr(0.02!2).exprange(0.02,0.1), dec); // the delay time of the comb filters is random but moving very slowly it's a linear interpolating noise generator. a multi-channel expansion here so each ear has a different noise generator modulating the delay time
	}).sum;
	6.do({
		wet = AllpassC.ar(wet, 0.02, LFNoise1.kr(0.02!2).exprange(0.01,0.02), dec)
	});
	wet = LPF.ar(wet, \lpf.kr(1500)); //pass the reverb signal through a low-pass filter for damping just to attenuate high frequencies
	sig = sig.blend(wet, \mix.kr(0.35)) * \amp.kr(0.85);
	Out.ar(\out.ir(0), sig);
}).add;
)

//the comb filters are meant to represent the four walls or the six surface. just like the various the size of the room and the delays you get from signals bouncing off of those and then the all-pass filters are kind of have a dispersing effect. so they kind of wash away the natural resonance of the comb filters

~reverb = Synth(\reverb, [\in, ~fxBus], ~fxGrp);
~reverb.free;
~reverb.set(\mix, 0.08);

////////////////////////////////////////

//delay-based realtime harmonizer

(
SynthDef(\delharm, {
	var sig, phs, del, env, rate, maxdel=0.05;
	rate = \n.kr(0).midiratio - 1 / maxdel;
	sig = In.ar(\in.ir(0), 2);
	phs = LFSaw.ar(rate.neg, [1,0]).range(0,maxdel);
	env = SinOsc.ar(rate, [3pi/2,pi/2]).range(0,1).sqrt;
	del = DelayC.ar(sig, maxdel, phs) * env;
	del = del.sum!2 * \amp.kr(0.85);
	Out.ar(\out.ir(0), del);
}).add;
)

~del = Synth(\delharm, [\in, ~fxBus], ~fxGrp);
~del.set(\n, 6);

(
~del = [
	Synth(\delharm, [\in, ~fxBus, \n, -3], ~fxGrp),
	Synth(\delharm, [\in, ~fxBus, \n, 2], ~fxGrp),
	Synth(\delharm, [\in, ~fxBus, \n, 5], ~fxGrp),
];
)

~src.set(\choose, 1);
~src.set(\choose, 0);

/////////////////////////////////////////

//extrapolating:
[-48, -15/16]
[-36, -7/8]
[-24, -3/4]
[-12, -1/2]
[0, 0]
[12, 1]
[24, 3]
[36, 7]
[48, 15]

(
SynthDef(\delharm, {
	var sig, phs, del, env, rate, maxdel=0.05;
	rate = \n.kr(0).midiratio - 1 / maxdel;
	sig = In.ar(\in.ir(0), 2);
	phs = LFSaw.ar(rate.neg, [1,0]).range(0,maxdel);
	env = SinOsc.ar(rate, [3pi/2,pi/2]).range(0,1).sqrt;
	del = DelayC.ar(sig, maxdel, phs) * env;
	del = del.sum!2 * \amp.kr(0.85);
	Out.ar(\out.ir(0), del);
}).add;
)

~del = Synth(\delharm, [\in, ~fxBus], ~fxGrp);
~del.set(\n, -7);

{LFSaw.ar(100, [1,0])}.plot(0.05);
{SinOsc.ar(100,[3pi/2,pi/2]).range(0,1).sqrt}.plot(0.05)

(
x = [
	Synth(\delharm, [\in, ~fxBus, \n, -5], ~fxGrp),
	Synth(\delharm, [\in, ~fxBus, \n, -2], ~fxGrp),
	Synth(\delharm, [\in, ~fxBus, \n, 4], ~fxGrp)
];
)

(
x = [
	Synth(\delharm, [\in, ~fxBus, \n, -2], ~fxGrp),
	Synth(\delharm, [\in, ~fxBus, \n, -4], ~fxGrp),
	Synth(\delharm, [\in, ~fxBus, \n, -6], ~fxGrp),
	Synth(\delharm, [\in, ~fxBus, \n, -8], ~fxGrp),
	Synth(\delharm, [\in, ~fxBus, \n, -10], ~fxGrp),
	Synth(\delharm, [\in, ~fxBus, \n, -12], ~fxGrp),
];
)

(
x = 8.collect({
	Synth(\delharm, [\in, ~fxBus, \n, rrand(-24.0, 24.0), \amp, 0.4], ~fxGrp)
});
)

~src.set(\choose, 1);
~del = Synth(\delharm, [\in, ~fxBus, \n, -4], ~fxGrp);
~del.set(\n, -36);
