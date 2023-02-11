s.boot;

(
p = Pbind(
	\midinote, Pseq([
		Pxrand([51, 53, 55, 58],4), // four random low notes
		Pxrand([72, 75, 77, 79],4) // four random high notes
	], inf),
	\sustain, 0.02,
	\dur, 0.15,
	\amp, 0.5,
);

q = p.play;
)

q.stop;

// try to make the number of low notes to be different every time-----
(
p = Pbind(
	\midinote, Pseq([
		Pxrand([51, 53, 55, 58], rrand(2, 5)), // 表示随机出现2次到5次前面的音高
		//the number of low notes will be random, but it'll be the same random number every time we roll back around to this Pxrand
		Pxrand([72, 75, 77, 79],4)
	], inf),
	\sustain, 0.02,
	\dur, 0.15,
	\amp, 0.5,
);

q = p.play;
)

rrand(2,5) // （最低值，最高值）


(
p = Pbind(
	\midinote, Pseq([
		Pxrand([51, 53, 55, 58], {rrand(2,5)}),  // enclose the random expression in curly braces so that it becomes a function by doing so in a sense we're deferring 推迟 the evaluation of this code until the stream that plays this pbind， actually needs to know what that value is，  at which point it'll evaluate the function and obtain a new random number each time 每次都会重新刷新新的数据

		Pxrand([72, 75, 77, 79],4)
	], inf),
	\sustain, 0.02,
	\dur, 0.15,
	\amp, 0.5,
);

q = p.play;
)



// more complex than just pick a random number------

//one low note followed by four high notes, then two low notes followed by four high, then three, then four and four then four etc, just adding a new low note each time



(
p = Pbind(
	\midinote, Pseq([
		Pxrand([51, 53, 55, 58], Pseries(1, 1, inf)), // it's just stuck on the low notes
		Pxrand([72, 75, 77, 79],4)
	], inf),
	\sustain, 0.02,
	\dur, 0.15,
	\amp, 0.5,
);

q = p.play;
)

//the distinction between a pattern and astream


x = Pseries(1, 1, inf)
//a pattern like this one here defines some sequence but it is not the sequence itself, instead a pattern is a recipe or a blueprint for that sequence and if all we have is a pattern then there is no way for us to actually get the output directly from the pattern
// pxrand needs a number of repeats and pseries is not a number


x = Pseries(1, 1, inf).asStream;
//a stream is a tangible 明显 execution of some pattern and that's what we need a thing that actually says here's the next number.... so we can convert a pattern to a stream, using asStream.( it says routine here,) technically routine is a type of stream.  and then we can call .value or .next on the result,  and we actually get the values.
rand
x.next;
x.value;
x.please;





(
~reps = Pseries(1,1,inf).asStream; //  use a stream derived from a pattern to control the number of repeats of pxrand

p = Pbind(
	\midinote, Pseq([
		Pxrand([51, 53, 55, 58], ~reps),
		Pxrand([72, 75, 77, 79],4)
	], inf),
	\sustain, 0.02,
	\dur, 0.15,
	\amp, 0.5,
);

q = p.play; //q is independent from the p series stream
)
// if we stop the event stream player and even if you also reset the event stream player doing so does not also reset reps. internal stream remembers where it left off and we'll continue from there if we restart the event stream player

q.stop;
q.reset;

//if you want to reset everything then the internal stream needs its own reset message or even easier just create the entire thing and start over
~reps.reset;

q.play;







