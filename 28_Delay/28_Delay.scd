s.boot;
s.option
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
	var sig;
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
	sig = In.ar(\in.kr(0), 2); //
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
//if we're at 48 000 samples per second, 32-bit is 4 bytes (https://web.stanford.edu/class/cs101/bits-bytes.html), so it's 192 000 bytes per second divide that by a thousand and we get 192 kilobytes per second， multiply by 2 for stereo, 384 kilobytes. so 8192 is enough. it's more than enough for a stereo one second delay but if we want a 100 second delay that's 38.4 megabytes



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

~del = Synth(\del, [\in, ~fxBus, \del, 0.25], ~fxGrp); // a quarter second delay
~del.set(\del, 0.05);
~del.set(\del, 0.5);
~del.set(\del, 1);
~del.set(\del, 1.5); //fails — delay buffer not big enough -> so one second is our theoretical maximum

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
	sig = sig.blend(del, \mix.kr(0.4)); //change the mix between the dry signal and the delayed signal
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
	~del = ~del.add(Synth(\del, [\in, ~fxBus, \mix, 0, \del, 0, \amp, 1], ~fxGrp)); //add one more synth to this array of 20 ,send it through a delay where we don't listen to the delayed signal at all and the delay time is zero

});
)

// linlin is a mapping method
(0..19).linlin(0, 19, 200, 300) //array starting at 200 ending at 300 with a linear distribution
(0..19).linexp(0, 19, 200, 300) //it's an exponential curve
(0..19).lincurve(0, 19, 200, 300, 0) // last arguments 0 > linear (equally spaced) 1 > exponential
//0 (linear)      <0 (concave, negatively curved)         >0 (convex, positively curved)

//reference: SimpleNumber

(
s.bind({

	~del = 20.collect({
		arg n;
		Synth(\del, [
			\in, ~fxBus,
			\mix, 1,
			\amp, 0.1,
			\del, n.linlin(0,19,0.15,4)
		], ~fxGrp
		);
	});

	~del = ~del.add(Synth(\del, [\in, ~fxBus, \mix, 0, \del, 0, \amp, 1], ~fxGrp));

});
)


// how to use method blend
{SinOsc.ar(200, 0, 0.2).blend(Saw.ar(40, 0.05), 0)}.play;
{SinOsc.ar(200, 0, 0.2).blend(Saw.ar(40, 0.05), 1)}.play;
{SinOsc.ar(200, 0, 0.2).blend(Saw.ar(40, 0.05), 0.5)}.play;
{SinOsc.ar(200, 0, 0.2!2).blend(Saw.ar(40, 0.05!2), 0.5)}.play;

(
//add L/R spatial control via Balance2
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2);
	del = DelayN.ar(sig, 4, \del.kr(1));
	sig = sig.blend(del, \mix.kr(0.4));
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0), \amp.kr(1)); //we cannot Pan2 a stereo signal,  sig[0] left, sig[1] right
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
			\pan, rrand(-1.0,1.0), // n.linlin(0, 19, -1, 1) go from left to right
		], ~fxGrp
		);
	});

	~del = ~del.add(Synth(\del, [\in, ~fxBus, \mix, 0, \del, 0, \amp, 1], ~fxGrp));

});
)

//what if we modulate the delay time?
//if you want to make this delay time move around in real time, like modulate it with a sine wave,  you should not be using any delay ugen that ends with N, because these are non-interpolating delay lines and so as the delay time moves there's a delay read pointer that's internal to the process and it's being asked to change its delaytime,  which has the result of moving it faster or more slowly through the buffer and so the samples don't line up with the sample clock, when it moves at a at a different speed from the the normal speed

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
//different pitch changes in the voice



//loading a buffer as alternate sound source
b = Buffer.read(s, "/Users/meiyanchen/Documents/GitHub/SC/28_Delay/delay.aiff");

b.play;
b.numChannels;
b.duration;
s.sampleRate;

(
//Select uses in index to select a signal from an array
SynthDef(\source, {
	var sig;
	sig = Select.ar(\choose.kr(1), [   //selects from one of several input sources in an array
		SoundIn.ar(0!2), //index: 0
		PlayBuf.ar(1!2, b, loop:1), // index: 1
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
	del = DelayL.ar(sig, 1, SinOsc.kr(0.2).range(0.1,1).poll); // try delayN first, see the difference
	sig = sig.blend(del, \mix.kr(0.4));
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0), \amp.kr(1));
	Out.ar(\out.kr(0), sig);
}).add;
)

~del = Synth(\del, [\in, ~fxBus, \mix, 0.4], ~fxGrp);
~del.set(\mix, 1); //all the delayed signal and none of the original buffer
~del.free;

//when the delay time is going from high to low , the pitch goes up, when the delay time is going from low to high, the pitch goes down.  that is something that some people might not be expecting to hear in a delay line. you expect to hear when you change the delay line, you sort of expect to hear an echo that gets farther and farther away and closer and closer away to the source sound in time, but instead we get this glissando thing going on here

//usually we draw buffers as like a line with like a bunch of individual  rectangles in it, because the buffer has like a start and an end. and it's got a certain length.   But in a delay line, a buffer is allocated but it is treated as if it were circular, so the last frame is adjacent to the first frame. so it kind of goes around and around forever.

//so in a delay line, basically it's the same thing as like playbuf and recordbuf, we have some writing process. some process which is responsible for writing samples into the buffer.

//as time progresses this write pointer moves through the buffer, just imagine counter clockwise is forward through the buffer and it just writes samples. and then chasing behind it.  we have some read pointer which is also moving around and if it's a fixed delay time then this amount of time let's call it 0.5 , that's a five seconds.  so if you're a fixed delay time. the distance between the read and write pointer is always the same.

//but that's not the case in the one. what we're doing right here we have a sine wave we got some right sine wave, it's going up and down and this is at the top is the max delay and at the bottom is the minimum delay. so the distance is changing. it's like sort of extending. out to be one full second, and catching up to be 1 seconds. and so over time, this signal that's modulating the delay, (it is similar to the grain buf and tgrains have an interpolation argument and that determines what kind of interpolation is going to happen, if the grains get played back at a non original speed). so basically as a sine wave is going from it's peak to its valley. it's going from the maximum delay time to the minimum delay time. and so the read pointer is catching up to the right pointer as they both spin around. in that moment it's reading through samples that have been stored in that buffer faster, then the sine wave turns around starts going from minimum to maximum delay time, stretches out again. and so you have the slowing speeding up and slowing down.

//so you really want to have an interpolating delay line like delay l or delay c, so that you can smoothly read those samples at a different rate and that's why we get this pitch shifting stuff as we read through it. so now if you watch the numbers again as they go from low to high the pitch goes down, as they go from high to low the pitch goes up, and as the sine wave is leveling off just for a brief moment the slope of the sine wave is zero. it's like not changing and so at that moment the pitch kind of centers at the original pitch for a while actually part of a family, part of three units.


//--------------------------------------------------
(
//flanger effect 飘忽效果
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2);
	del = DelayL.ar(
		sig,
		1/10, //tenth of a second buffer
		SinOsc.kr(\delhz.kr(0.2)).range(\delmin.kr(1/1000),  \delmax.kr(1/100)).poll; //delhz: the speed of the modulator
	);
	sig = sig.blend(del, \mix.kr(0.4));
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0), \amp.kr(1));
	Out.ar(\out.kr(0), sig);
}).add;
)

~del = Synth(\del, [\in, ~fxBus, \mix, 0.4], ~fxGrp); // the pitch variations are so slightly

~del.set(\mix, 1); //listen to only delayed signal — imperceptible pitch shifts

//increase modulator frequency makes pitch shifts more extreme and faster
~del.set(\delhz, 5);

~del.free;
// increased the frequency of the modulator so it's going the sine wave frequency has increased quite a bit and so it's going from a thousandth of a second to 100th of a second, really fast and so the slope of that sine wave is actually much steeper and so the pitch changes are much more drastic and faster, so that's by increasing the speed of the modulator. it doesn't just make the flanger effect faster. it makes it more extreme in terms of pitch.
//----------------------------

(
//more complex flanger effect — four summed modulated delays
SynthDef(\del, {
	var sig, del;
	sig = In.ar(\in.kr(0), 2);
	del = 4.collect({ //make an array of four delay lines
		DelayL.ar(
			sig,
			1/10,
			SinOsc.kr(ExpRand(0.1,0.2), Rand(0, 2pi)).range(1/ExpRand(1000,2000), 1/ExpRand(20,100))
		); //each sine wave they don't all start in phase now. each one's going to startat some random point in its cycle, so that they don't line up and then drift out of phase. they'll just start randomly out of phase from each other. minimum delay is going to be somewhere between a millisecond and half a millisecond, maximun delay is from 20th of a second to one hundredth of a second
	}).sum; //and then add them together (sum)
	sig = sig.blend(del, \mix.kr(0.4));
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0), \amp.kr(1));
	Out.ar(\out.kr(0), sig);
}).add;
)

~del = Synth(\del, [\in, ~fxBus, \mix, 0.4], ~fxGrp);
~src.set(\choose, 0); //back to mic signal
~del.free;

s.freeAll;

//try C, it's cubic interpolation instead of linear so it's more computationally expensive but more nice and smoother