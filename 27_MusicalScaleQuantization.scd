s.boot;

// take a noise generator and plug it into an oscillator
(
{
	var sig, freq;
	freq = LFDNoise0.kr(7).exprange(110, 880);
	sig = VarSaw.ar(freq, mul:0.2!2);
}.play;
)

//we can think in terms of midi note numbers and convert to frequency with midicps


(
{
	var sig, pch, freq;
	pch = LFDNoise0.kr(7).range(45, 81);
	pch.poll(7); //this noise generator spits out floats which we can confirm by pulling it
	freq = pch.midicps;
	sig = VarSaw.ar(freq, mul:0.2!2);
}.play;
)

//if we want actual notes from a piano keyboard, we can round these pitch values to the nearest integer. it's a little bit more musical, but still pretty random.

(
{
	var sig, pch, freq;
	pch = LFDNoise0.kr(7).range(45, 81).round(1);  //round(2) we can round to a different number to do intervallic stuff, like a value of two , picks notes from a whole tone scale全音阶， round(7)  picks from a bunch of stacked fifths
	pch.poll(7);
	freq = pch.midicps;
	sig = VarSaw.ar(freq, mul:0.2!2);
}.play;
)


//musically quantize these pitches to the nearest scale degree in some scale

//1.  load a collection of scale degrees into a buffer
~scale0 = Buffer.loadCollection(s, Scale.minorPentatonic.degrees);
~scale3 = Buffer.loadCollection(s, [0, 2, 4, 6, 8, 10]);
//check Scale -> Creation -> Scale.directory
~scale0.plot; // hit the m key on keyboard once to plot the data as points stretch it vertically and we can see this buffer contains five values which are 0 3 5 7 and 10


0  1  2  3  4  5  6  7  8  9  10  11  12
C     D     E  F     G     A      B    C
C        bE    F     G        bB

//use a ugen called index which retrieves buffer values using the integer part of its input signal as an index.
(
{
	var sig,index, pch, freq;
	index = LFDNoise0.kr(7).range(0, 1); // represent octaves
	index = index * BufFrames.kr(~scale0); //scale it by the number of frames in the buffer,
	index.poll(7); //pull the index so as this plays watch the integer part of the numbers in the post window and you'll notice they correspond to the scale degrees that we hear
	pch = Index.kr(~scale0, index) + 48;  //index.kr uses this signal to look up scale degrees in the buffer. we should add a value which effectively determines the starting note of the scale
	freq = pch.midicps;
	sig = VarSaw.ar(freq, mul:0.2!2);
}.play;
)

// it's a good start but doesn't give us a lot of flexibility, if we increase the range of the indices. thinking we're gonna expand out to four octaves or whatever. index isn't really designed to work this way.  instead it just clips the index within the buffer frame range. so in this case we're just gonna hear that highest scale degree like 75,  80 percent of time.



 //a better option is a ugen called DegreeToKey,  which is similar but instead of clipping index values, it wraps暂存 them within the frame range and as it does so it also shifts the octave accordingly
(
{
	var sig,index, pch, freq;
	index = LFDNoise0.kr(7).range(0, 4);
	index = index * BufFrames .kr(~scale0);
	index.poll(7);
	pch = DegreeToKey.kr(~scale0, index) + 36;
	freq = pch.midicps;
	sig = VarSaw.ar(freq, mul:0.2!2);
}.play;
)

//to emphasize what's going on
(
{
	var sig,index, pch, freq;
	index = LFSaw.kr(0.8, 1).range(0, 4); //let's replace the index with LFSaw to sweep across these four octaves
	index = index * BufFrames.kr(~scale0);
	index.poll(7);
	pch = DegreeToKey.kr(~scale0, index) + 36;
	freq = pch.midicps;
	sig = VarSaw.ar(freq, mul:0.2!2);
}.play;
)


//convert above code into synthdef

(
SynthDef(\d2k, {
	arg buf;
	var sig,index, pch, freq;
	index = LFSaw.kr(0.8, 1).range(0, 4); //four octave range
	index = index * BufFrames.kr(buf); //if we switch to a scale with a different number of degrees, kr will track this change
	pch = DegreeToKey.kr(buf, index) + 36;// dropping the starting noteone octave lower
	freq = pch.midicps;
	sig = VarSaw.ar(freq, mul:0.2!2);
	Out.ar(0, sig);
}).add;
)

(
~scale1 = Buffer.loadCollection(s, [0, 4, 6, 7, 10]);
~scale2 = Buffer.loadCollection(s, [0, 2, 8, 9, 10]);
)

x = Synth(\d2k, [\buf, ~scale0]);
x.set(\buf, ~scale1);
x.set(\buf, ~scale2);


//a complex version

(
SynthDef(\d2k, {
	arg buf, inote = 36, gate = 1;
	var sig, index, pch, freq;
	index = LFDNoise3.kr(1!4).range(0, 5); //multi-channel expansion to create multiple voices/  one additional octave at the top
	index = index * BufFrames.kr(buf);
	pch = DegreeToKey.kr(buf, index) + inote; //inote argument for the starting note so we can very easily transpose
	pch = pch + LFNoise1.kr(1!4).bipolar(0.12); // detuning effect on the pitch
	freq = pch.midicps.lag(0.02); //slightly lagged so there's like a micro glissando whenever the pitch changes
	sig = VarSaw.ar(freq, mul:0.2);
	sig = Splay.ar(sig, 0.75);
	sig = sig * EnvGen.kr( //envelope mostly for fading out
		Env([0, 1, 0, 0],[0.05, 4, 7],[0, -2, 0], 1),
		gate, doneAction:2
	);
	sig = sig.blend(
		CombN.ar(sig, 0.25, 0.25, 2), 0.5 //and a delay reverb combN at the end
	);
	sig = sig.blend(
		LPF.ar(GVerb.ar(sig.sum, 200, 3), 1000),
		0.4
	);
	Out.ar(0, sig);
}).add;
)

x = Synth(\d2k, [\buf, ~scale0, \inote, 36]);
x.set(\buf, ~scale1, \inote, 32);
x.set(\buf, ~scale2, \inote, 30);
x.set(\buf, ~scale1, \inote, 39);
x.set(\gate, 0);




