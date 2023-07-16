s.options.sampleRate = 48000;

s.boot;
// referance: randomness

rrand(0, 99);

//a random number generator(RNG) begins with a seed.  some integer that provides a starting point for the algorithm。

thisThread.randSeed = 24; //the simplest way to seed播种 sclangs RNG

//then we generate some random numbers which seem random enough but recede and we'll get the exact same sequence every time
// and this applies to any random choice that sclang makes.


(
thisThread.randSeed = 27;
4.do({[1, 2, 3, 4, 5].choose.postln}); //choosing from an array
)


(
thisThread.randSeed = 27;
4.do({0.7.coin.postln}); //flipping a coin
)


(
thisThread.randSeed = 27;
4.do({ exprand(80, 8000).postln}); //using a different method like exprand
)

(
thisThread.randSeed = 24; // if we change the seed even by the smallest possible amount the results arecompletely different
4.do({ exprand(80, 8000).postln});
)


// in the supercollider language the context in which code runs is called a thread.
//right now we're in the main top level thread so that's what this thread refers to



//------------------ what is thread
// there's a class called thread which mainly exists to provide a framework for its subclass routine,  which is a special type of function that can pause and resume.

//routines inherit the RNG seed from their parent thread. in other words the thread in which they were created, so if the main thread seed is 24, then this routine has the same seed and produces the same sequence from before

thisThread.randSeed = 24;  //the main thread seed

(
r = Routine.new({
	loop{
		rrand(0, 99).postln;
		0.4.wait;
	};
});

r.play;
)

r.stop;

//but a routine can have its own seed and one option is to use the randseed method on the routine before it plays
(
r = Routine.new({
	loop{
		rrand(0, 99).postln;
		0.4.wait;
	};
});
r.randSeed = 25;
r.play;
)


//or you can use this thread inside the routine in which case it refers to the new child thread instead of the main parent thread
//and in this case resetting the routine has the side effect of reseeding the rng. because reseeding takes place in the routine

//if the top level seed is 24 and we grab a couple numbers we already know,  the next one's going to be 99 even if we let this routine blow through a few numbers, this has no effect on the rng of the parent thread case in point 99 still next in line


thisThread.randSeed = 24;  // parent thread 线, 脉络
rrand(0, 99);  // 不会影响母脉络随机数的输出

(
r = Routine.new({
	thisThread.randSeed = 25; // child thread
	loop{
		rrand(0, 99).postln;
		0.4.wait;
	};
});

r.play;
)

r.stop;
r.reset.play;



// first looping routine

(
~soundMaker = Routine.new({
	loop{ //loop the process over and over again
		{ //play Ugen function
			var sig, freq;
			freq = {exprand(80, 8000)}.dup(8); // random frequencies, duplicate
			sig = 8.collect({
				arg i;
				SinOsc.ar( // sine waves
					freq: freq[i] * [-0.1, 0.1].midiratio, // 在序列数中选其中一个
					mul: 0.05
				);
			}).sum;
			sig = sig * EnvGen.ar( // envelope
				Env.perc(0.002, 0.1),
				doneAction:2
			);
		}.play(fadeTime:0);

		1.wait; // 1.yield;  same result //so when using next on a routine, this line is like a traffic cop that says stop and i will tell you when you can keep going
	};
});
)

// second looping routine
(
~player = Routine.new({
	loop{
		~soundMaker.randSeed_(~seed); // seed the first routine
		6.do{ //six times in a row, it calls next on the first routine and then waits for 0.12 seconds

			~soundMaker.next;  //jump to iteration blook
			0.12.wait;
		};
	};
});
)

//calling next on a routine tells it to start evaluating and then come to a full stop if it runs into a wait.  you can also replace wait with yield same result

~soundMaker.play;

~seed = 46; // prepare a seed value  // try to change the value, 45, 46, 47
~player.play; // play the second routine, we get six random bloops that then repeat indefinitely

~player.reset.play;
~player.stop;

//because seed is a global variable inside a continually reevaluated process.we can swap it out in real time,  but the seed only updates at the beginning of a sixth note cycle,  so the rhythm is preserved.



//--------------------
//all these techniques are exclusively language side,  so it only applies to RNG in sclang not on the server

//if we swap the xprand method for the exprand UGen, the behavior is different.  the randomness no longer repeats,  because now the RNG lives on the server an entirely different program with a separate RNG mechanism, find the solution check RandID, RandSeed

(
~soundMaker = Routine.new({
	loop{
		{
			var sig, freq;
			freq = {ExpRand(80, 8000)}.dup; // swap the exprand method for the Exprand ugen
			sig = 8.collet({
				arg i;
				SinOsc.ar(
					freq:freq[i] * [-0.1, 0.1],
					mul:0.05
				);
			}).sum;
			sig = sig * EnvGen.ar(
				Env.perc(0.002, 0.1),
				doneAction:2
			);
		}.play(fadeTime:0);

		1.wait;
	};
});
)


(
~player = Routine.new({
	loop{
		~soundMaker.randSeed_(~seed);

			~soundMaker.next;
			0.12.wait;
		};
	};
});
































































