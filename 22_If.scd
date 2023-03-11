s.options.sampleRate = 48000;
s.boot;

// reference: control structures
//https://depts.washington.edu/dxscdoc/Help/Overviews/SymbolicNotations.html

(
f = {
	arg num = 0;  //we have a function with an argument if
	if(
		num == 0,
		{ {SinOsc.ar(500)*0.2!2}.play},  // it's zero play a tone
		{ {PinkNoise.ar(1)*0.2!2}.play} //otherwise play some noise
	);
};
)

f.value([0, 1].choose.postln);





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


//it will not work correctly.  and in fact this is such a common pitfall that there's a dedicated page on the supercollider website.
// check if statements in a SynthDef (https://supercollider.sourceforge.net/wiki/index.php/If_statements_in_a_SynthDef)
//so no matter how we manipulate the argument, we always get noise.  and if we change the conditional expression to num < 1, then the synthetic just fails out right, and says the expression is non-boolean,  which seems outrageou.  because num is 0, and we just want to know, is it less than one



//this if construct is language side. and that means before the server even gets involved. the language says, oh it's an if. i need to evaluate this and it does. so it says is num == 0. and to us humans,  it looks obviously true.


Control.kr(0) == 0; //but what's actually being evaluated, is this which is false
//comparing a ugen to an integer these will never be equal,  so the result is and always will be pink noise


//synthDef arguments automatically become instances of a class called control,  which is basically what lets us interact with sounds using set messages, so going back to the version that checks equality with zero

// reference: Control
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
	if(
		num == 1,
		{sig = SinOsc.ar(500)},
		{sig = PinkNoise.ar(1)}
	);
	Out.ar(0, sig*0.2!2);
}).dumpUGens; // dump Ugens ,we can see there's actually no SinOsc present so from the server's perspective
)
//dump 转存（计算机数据）；（尤指系统发生故障后内存的）打印输出
x = Synth(\if, [\num, 1]);
x.set(\num, 0);
x.free;

  ^
  ^
  |
  |   //same
(
SynthDef.new(\if,{
	arg num = 0;
	var sig;
	sig = PinkNoise.ar(1);
	Out.ar(0, sig*0.2!2);
}).dumpUGens;
)

//this which is why pink noise is the only thing that ever comes out


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
}).dumpUGens;
)

x = Synth(\if, [\num, 1]);
x.set(\num, 0);
x.free;

  ^
  ^
  |
  |   // what the languagues sees
Control.kr(0) < 1;

//returns a binary OpUGen. it's another type of UGen created behind the scenes. most other binary operations produce the same result

Control.kr(0) + 1;
Control.kr(0) - 1;
Control.kr(0) == 1; //equality check


//a binary op-ugen is non-boolean. it's neither true nor false. so the language doesn't know what to do and we get an error



//-------------------------Solution-----------------------------------
//the Select UGen it'sbasically the closest thing we have to a UGen version "if"

(
SynthDef.new(\if,{
	arg num = 0; //provide a number
	var sig;
	sig = Select.ar(
		num, //the integer part is used as an index
		[
			SinOsc.ar(500),
			PinkNoise.ar(1)   // into an array of ugens
		]
	);
	Out.ar(0, sig*0.2!2);
}).add;
)
x = Synth(\if, [\num, 1]);
x.set(\num, 1);
x.set(\num, 0);
x.free;




(
SynthDef.new(\if,{
	arg num = 0;
	var sig;
	sig = SelectX.ar(  //cross fades between adjacent signals
		num.varlag(2),  //when the index is a non-integer, we'll put a varlag on the index
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


//  an arpeggiator  琶音--------------------------------------


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

//the downside缺点 of Select is that all UGens in the array are continuously running. even when not selected. so computational efficiency is a consideration.

//------

//conditional expressions do have meaning by themselves on the server. but the results are represented using 1 and 0 instead of true and false.

(
{
	var sig, amp, isLoud;
	sig = PinkNoise.ar(1!2);
	amp = LFDNoise3.kr(4).exprange(0.02, 0.5);   //amplitude of pink noise randomly moves between 0.02 and 0.5
	isLoud = amp > 0.1; //if it's greater than 0.1 isLoud has a value of 1 otherwise 0.
	isLoud.poll; // check
	sig = sig * amp;
}.play;
)

//this is really useful if we think in terms of mathematical signal manipulation
//for example it could be used as a kind of gate to turn something on or off, depending on the condition.



//so here we mix in an impulse generator which turns on, whenever the amplitude of the noise is below threshold
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


//the hardest part i think is training yourself not to think in conventional terms of "if", then "else". and instead think in terms of ones and zeros. and then mathematically weave these numbers into your algorithms to get the results you want







































