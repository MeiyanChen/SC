s.boot;

(
f = {
	arg num = 0;
	if(
		num == 0;
		{{SinOsc.ar(500)*0.2!2}.play},
		{{PinkNoise.ar(1)*0.2!2}.play}
	);
};
)

f.value([0,1].choose.postln);


(
SynthDef.new(\if,{
	arg num = 0;
	var sig;
	if(
		num == 0,
		{sig = SinOsc.ar(500)},
		{sig = PinkNoise.ar(1)}
	);
	Out.ar(0, sig*0.2!2);
}).add;
)

x = Synth(\if, [\num, 1]);
x.set(\num, 0);
x.free;

Control.kr(0) == 0;


(
SynthDef.new(\if,{
	arg num = 0;
	var sig;
	if(
		num < 1,
		{sig = SinOsc.ar(500)},
		{sig = PinkNoise.ar(1)}
	);
	Out.ar(0, sig*0.2!2);
}).add;
)

x = Synth(\if, [\num, 1]);
x.set(\num, 0);
x.free;




(
SynthDef.new(\if,{
	arg num = 0;
	var sig;
	sig = PinkNoise.ar(1);
	Out.ar(0, sig*0.2!2);
}).dumpUGens;
)

x = Synth(\if, [\num, 1]);
x.set(\num, 0);
x.free;

Control.kr(0) == 0;




(
SynthDef.new(\if,{
	arg num = 0;
	var sig;
	sig = SelectX.ar(
		num.varlag(2),
	[
		SinOsc.ar(500),
	    PinkNoise.ar(1)
		]
	);
	Out.ar(0, sig*0.2!2);
}).add;
)

x = Synth(\if, [\num, 1]);
x.set(\num, 1);
x.set(\num, 0);
x.free;

Control.kr(0) < 1;
Control.kr(0) == 1;


(
SynthDef.new(\if, {
	var notes, index, freq, sig;
	notes = (0, 7..42) +.x [0, 4];
	index = LFSaw.kr(1, 1).range(0, notes.size.postln);
	freq = Select.kr(index, notes);
	freq = (freq + 50).midicps;
	sig = SinOsc.ar(freq);
	Out.ar(0, sig* 0.2!2);
}).add;
)

Synth(\if);

(
{
	var sig, amp, isLoud;
	sig = PinkNoise.ar(1!2);
	amp = LFDNoise3.kr(4).exprange(0.02, 0.5);
	isLoud = amp > 0.1;
	isLoud.poll;
	sig = sig * amp;
}.play;
)


(
{
	var sig, amp, isLoud, imp;
	sig = PinkNoise.ar(1!2);
	amp = LFDNoise3.kr(4).exprange(0.02, 0.5);
	isLoud = amp > 0.1;
	isLoud.poll;
	imp = Impulse.ar([19, 20], mul:0.25);
	imp = imp *(1 - isLoud).lag(0.1);
	sig = sig * amp;
	sig = sig + imp;
}.play;
)










































