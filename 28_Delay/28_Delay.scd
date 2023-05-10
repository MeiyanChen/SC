s.boot;

//USE HEADPHONES!! this lecture/code document includes a lot of live microphone sound

// delay-based synthesis
//we have a signal,  we record it into a buffer,  and we play it back some amount of time later

{CombN.ar(SoundIn.ar(0), 0.5, [0.5,0.47], 60) * SinOsc.kr(1, [pi/2,3pi/2]).range(-12,0).dbamp}.play;

s.defaultGroup.set(\gate, 0, \fadeTime, 10);

/////////////////////

s.meter;
s.plotTree;

(
//simple mic input SynthDef
SynthDef(\source, {
	var sig; arg out = 0,
	sig = SoundIn.ar(0!2); //read signal from microphone to two channels
	sig = sig * \amp.kr(1);//amplitude adjustment which is by default having no effect
	Out.ar(\out.kr(0), sig); //write it out to a bus
}).add;
)

(
//setup code for busses, synths, groups
~setup = {
	s.newBusAllocators; //reset the bus count
	~fxBus = Bus.audio(s,2); //make a two channel bus
	s.bind({
		~sourceGrp = Group.new; // pipe a couple of osc commands from the language to the server which makes a group
		~src = Synth(\source, [\out, ~fxBus], ~sourceGrp); //puts a source synth in that group writing to that bus (target)
		~fxGrp = Group.after(~sourceGrp); //makes another group
	});
};
ServerTree.removeAll;
ServerTree.add(~setup);  //we'll just register all of that with server tree which means as soon as we hit command period it sets up our our stuff for us so we got our source synth writing to an audio bus somewhere
)

//press command period to initialize the node tree

//---------------------------
DelayN, DelayL, DelayC //these are simple delay lines they take a signal and they output that signal some amount of time later

// N -> no interpolation, if you're working with a fixed delay time, like a standard kind of echo , the delay time isn't changing,  so there's no interpolation necessary
// L -> linear
// C -> cubic
// if you are going to be dynamically changing your delay time,  then some sort of interpolationis necessary so L or C in order to prevent aliasing artifacts

CombN, CombL, CombC //this is a delay line with feedback. it's almost exactly the same thing, but the output signal is fed back into the input, and so we actually get a sequence of echoes

AllpassN, AllpassL, AllpassC //all passes also a delay with feedback, it passes all frequencies with equal gain, but it introduces phase shifts into different a frequency specific phase shift into a signal , so it has a way of dispersing phase分散相 information  -> a delay with feedback which causes a phase dispersion

//
(
//basic non-interpolating, non-feedback delay
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2); //read in a two channel signal
	del = DelayN.ar(sig, 1, 1); //max delay time = 1, actual delay time = 1 second
	sig = sig.blend(del, 0.4); //when we're working with delays in a creative context usually the most interesting things happen when we combine an input signal with a delayed copy of itself rather than just listening to the output of the delay exclusively so we are going to use a method called blend
	sig = sig * \amp.kr(1);
	Out.ar(\out.kr(0), sig);
}).add;
)

// command + i -> ugen blend -> enter
//0 means all the dry signal,  1 means all the wet signal

~del = Synth(\del, [\in, ~fxBus], ~fxGrp);
~del.free;

// what is maxdelaytime ? -> whenever we're dealing with a delay a digital delay, somewhere somehow there is a buffer being allocated, when we allocate a buffer we have to say exactly how much of a buffer we want up front. we cannot dynamically change the size of a buffer. once it's been allocated, so that's what this first number(maxdelaytime) is for.
/// the actual delay time we are welcome to go lower than the maximum delay time all the way down to zero with no delay, but we can't go above it


(
//extremely large max delay times (or numerous delay synths) will throw memory allocation failure messages
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2);
	del = DelayN.ar(sig, 100, 1);
	sig = sig.blend(del, 0.4);
	sig = sig * \amp.kr(1);
	Out.ar(\out.kr(0), sig);
}).add;
)

~del = Synth(\del, [\in, ~fxBus], ~fxGrp); //will probably fail
~del.free;

//increase memory size to allow larger/more delays
s.options.memSize;  //by default is 8192kb
s.options.memSize = 2.pow(20);

//must be rebooted for changes to take effect
s.reboot;

48000 * 4 / 1000 * 2; //kB needed for 1-second stereo delay buffer
48000 * 4 / 1000 * 2 * 100; //kB needed for 100 second stereo delay buffer
//if we're at 48 000 samples per second that's 32-bit is four bytes so it's 192 000 bytes per second divide that by a thousand and we get 192 kilobytes per second multiply by 2 for stereo 384 kilobytes so 8192 is enough it's more than enough for a stereo one second delay but if we want um a 100 second delay that's 38.4 megabytes


(
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2);
	del = DelayN.ar(sig, 1, \del.kr(1));
	sig = sig.blend(del, 0.4);
	sig = sig * \amp.kr(1);
	Out.ar(\out.kr(0), sig);
}).add;
)

~del = Synth(\del, [\in, ~fxBus, \del, 0.25], ~fxGrp);
~del.set(\del, 0.05);
~del.set(\del, 0.5);
~del.set(\del, 1);
~del.set(\del, 1.5); //fails — delay buffer not big enough

2.pow(16)/s.sampleRate; //SC actually allocates a buffer with size = next highest power of 2

//works
~del = Synth(\del, [\in, ~fxBus, \del, 1.3652], ~fxGrp);

//doesn't
~del.set(\del, 1.3654);

(
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2);
	del = DelayN.ar(sig, 4, \del.kr(1));
	sig = sig.blend(del, \mix.kr(0.4));
	sig = sig * \amp.kr(1);
	Out.ar(\out.kr(0), sig);
}).add;
)

(
//delay cluster
s.bind({

	//20 fully "wet" delay effects
	~del = 20.collect({
		arg n;
		Synth(\del, [
			\in, ~fxBus,
			\mix, 1,
			\amp, n.linlin(0,19,-3,-30).dbamp,
			\del, n.lincurve(0,19,0.02,2,2) //experiment with delay times and delay amplitudes
		], ~fxGrp
		);
	});

	//one fully "dry" (bypassed) delay effect
	~del = ~del.add(Synth(\del, [\in, ~fxBus, \mix, 0, \del, 0, \amp, 1], ~fxGrp));

});
)

(
//add L/R spatial control via Balance2
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2);
	del = DelayN.ar(sig, 4, \del.kr(1));
	sig = sig.blend(del, \mix.kr(0.4));
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0), \amp.kr(1));
	Out.ar(\out.kr(0), sig);
}).add;
)

(
//each delay panned randomly
s.bind({
	~del = 20.collect({
		arg n;
		Synth(\del, [
			\in, ~fxBus,
			\mix, 1,
			\amp, n.linlin(0,19,-3,-30).dbamp,
			\del, n.lincurve(0,19,0.02,2,2),
			\pan, rrand(-1.0,1.0),
		], ~fxGrp
		);
	});

	~del = ~del.add(Synth(\del, [\in, ~fxBus, \mix, 0, \del, 0, \amp, 1], ~fxGrp));

});
)

//what if we modulate the delay time?

(
//it's bad to use non-interpolating delay ugens with a dynamic delay time
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2);

	//sinusoidally controlled delay
	del = DelayN.ar(sig, 1, SinOsc.kr(0.2).range(0.1,1));
	sig = sig.blend(del, \mix.kr(0.4));
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0), \amp.kr(1));
	Out.ar(\out.kr(0), sig);
}).add;
)

~del = Synth(\del, [\in, ~fxBus, \mix, 0.4], ~fxGrp);

//loading a buffer as alternate sound source
b = Buffer.read(s, "/Users/eli/Documents/Illinois/Teaching/AY 2020-2021/Spring 2021/MUS 499C/Livestream Code/livestream_code_week06/delay.aiff");

b.play;
b.numChannels;
b.duration;
s.sampleRate;

(
//Select uses in index to select a signal from an array
SynthDef(\source, {
	var sig;
	sig = Select.ar(\choose.kr(1), [
		SoundIn.ar(0!2),
		PlayBuf.ar(1!2, b, loop:1),
	]);
	sig = sig * \amp.kr(1);
	Out.ar(\out.kr(0), sig);
}).add;
)

(
//linear-interpolating delay line avoids alias artifacts with dynamic delay times
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2);
	del = DelayL.ar(sig, 1, SinOsc.kr(0.2).range(0.1,1).poll);
	sig = sig.blend(del, \mix.kr(0.4));
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0), \amp.kr(1));
	Out.ar(\out.kr(0), sig);
}).add;
)

~del = Synth(\del, [\in, ~fxBus, \mix, 0.4], ~fxGrp);
~del.set(\mix, 1);
~del.free;

(
//flanger effect
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2);
	del = DelayL.ar(
		sig,
		1/10,
		SinOsc.kr(\delhz.kr(0.2)).range(\delmin.kr(1/1000), \delmax.kr(1/100)).poll;
	);
	sig = sig.blend(del, \mix.kr(0.4));
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0), \amp.kr(1));
	Out.ar(\out.kr(0), sig);
}).add;
)

~del = Synth(\del, [\in, ~fxBus, \mix, 0.4], ~fxGrp);

~del.set(\mix, 1); //listen to only delayed signal — imperceptible pitch shifts

//increase modulator frequency makes pitch shifts more extreme and faster
~del.set(\delhz, 5);

~del.free;

(
//more complex flanger effect — four summed modulated delays
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2);
	del = 4.collect({
		DelayL.ar(
			sig,
			1/10,
			SinOsc.kr(ExpRand(0.1,0.2), Rand(0, 2pi)).range(1/ExpRand(1000,2000), 1/ExpRand(20,100))
		);
	}).sum;
	sig = sig.blend(del, \mix.kr(0.4));
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0), \amp.kr(1));
	Out.ar(\out.kr(0), sig);
}).add;
)

~del = Synth(\del, [\in, ~fxBus, \mix, 0.4], ~fxGrp);
~src.set(\choose, 0); //back to mic signal
~del.free;

s.freeAll;