s.options.sampleRate = 48000;

s.boot;


p = ProxySpace.new(s).push;

~sig.play.fadeTime_(2);

(
~sig = {
	var sig;
	sig = SinOsc.ar({exprand(80,1600)}!16) * 0.1;
	sig = Splay.ar(sig);
};
)

~sig = {};

~sig.stop(fadeTime:1);
~sig.play(fadeTime:1);

~sig.release;
~sig.send;

~sig.clear(3);

//buffers
//this won't work if the current environment is a ProxySpace

~buf = Buffer.read(s,"/Users/meiyanchen/Documents/GitHub/SC/SC/34_Live_Coding_2/audio/bowl.aiff");


~buf.clear;


//Events are useful for storing any number of named things in any sort of hierarchy
e = (); // an empty event
e.stuff = 5;
e.things = ();
e.things.numbers = [1, 17, 3.9];
e.things.numbers[1];

(
//e.buf.path = path to audio files
//e.buf[0] = 0th audio file
//e.buf[1] = 1st audio file, etc.

e = ();
e.buf = ();
e.buf.path = PathName(thisProcess.nowExecutingPath).parentPath ++ "audio/";
PathName(e.buf.path).entries.collect({
	arg n,i;
	e.buf[i] = Buffer.read(s, n.fullPath);
});
)

e.buf[2].play; //testing

//store whatever you like in e — anything you might need to keep track of
e.freq = ();
e.freq[0] = Array.fill(8, {exprand(200,1000)});

//a buffer-driven proxy source:
~sig.clear;

(
~sig = {
	var sig, trig, env, buf;
	trig = Dust.kr(2); //generate random impulses approximately two per second
	buf = e.buf[0];
	sig = PlayBuf.ar(1!2, buf, 1, trig); //multi-channel expansion to make it stereo
	env = Env.perc(0.001, 0.2, 1, -2).kr(0, trig);
	sig = sig * env;
}
)  //so every time dust generates a trigger a Playbuf is going to restart the buffer and that trigger is also being used to trigger little percussive envelopes that have a very short attack and a 0.2 second decay

//the reason there's clicks is because some every now and then dust will generate. it's supposed to be two per second. but it's a loose density so every time you might get two triggers very close togetherback to back. and when that's the case, the envelope restarts and it's in the middle of its 0.2 second decay ,but then another trigger comes in and causes it to jump back to the beginning. but the sound wasn't fully faded out.


//Use Trig: when it receives a trigger, it outputs a value of one for this duration, so it's a way of holding a trigger for a certain amount of time. so that no triggers can get in during that time and so dust might generate two triggers back to back that are closer than 0.2 seconds ("rel"), but trig is just going to ignore them. because it snaps to 1 when it gets a trigger and it doesn't go back down to 0 until 0.2 seconds later. so this will guarantee we won't get any clicks and it also means we'll never get two samples that are any closer to each other than 0.2 seconds


(
~sig.play.fadeTime_(3);
~sig = {
	var sig, trig, env, buf, rel, rate;
	rel = {exprand(0.4,2)}!12;
	trig = Trig.kr(Dust.kr(1!12), rel); //*12 channel triger/ unique trigger signals. the triggers will randomly hold themselves open for some amount of time all 12 of them
	rate = TChoose.kr(trig, (-12..24).midiratio); // pitch
	buf = TChoose.kr(trig, (0..3).collect({arg n; e.buf[n]}));
	sig = PlayBuf.ar(1, buf, rate, trig);
	env = Env.perc(0.2, rel, 1, -2).kr(0, trig);
	sig = sig * env;
	sig = Splay.ar(sig);
}
)

~sig.release;


~sig2.play.fadeTime_(3);

(
//doneAction:2 is much less of a concern when using proxies
~sig2 = {
	var sig;
	sig = PlayBuf.ar(1!2, e.buf[4], [1.0,0.9]) * 0.5;
};
)

~sig2.clear;

~sig.send;


//---------------------------
//modularity/routing/mapping/interconnecting

//how do i do effects?  how do i route one NodeProxy into one or more effects?  how do i chain effects in series?  how do i do effects in parallel?  how do i like mix several proxies together?

~sig.clear;



(
~sig.play.fadeTime_(3);
~sig = {
	var sig, trig, env, buf, rel, rate;
	rel = {exprand(0.2,2)}!12;
	trig = Trig.kr(Dust.kr(1!12), rel);
	rate = TChoose.kr(trig, (-12..24).midiratio);
	buf = TChoose.kr(trig, (0..3).collect({arg n; e.buf[n]}));
	sig = PlayBuf.ar(1, buf, rate, trig);
	env = Env.perc(0.001, rel, 1, -2).kr(0, trig);
	sig = sig * env;
	sig = Splay.ar(sig) * 0.5;
}
)

(
~verb.play.fadeTime_(3);
~verb = {
	var sig;
	sig = GVerb.ar(\in.ar(0), 250, 4); //nothing's plugged into it right now
	sig = LPF.ar(sig, 2000);
	sig = sig * 0.5;
};
)

//may produce a pop
~verb.map(\in, ~sig); // connect to reverb
~verb.unmap(\in); // disconnect

//crossfade mapping
~verb.xmap(\in, ~sig);
~verb.xmap(\in, 0); // disconnect

(
~del.play.fadeTime_(3);
~del = {
	var sig;
	//On stream I meant to set the default value to 0!2 instead of 0
	sig = CombN.ar(\in.ar(0!2), 1, 0.3, 8);
	sig = sig * 0.5;
};
)

//send to delay
~del.xmap(\in, ~sig);

//remove from delay send
~del.xmap(\in, 0!2);

//remove from reverb send
~verb.map(\in, 0!2);

//effects in series: sig -> del -> reverb
~verb.map(\in, ~del);

(
//remove dry, only reverb wet
~sig.stop(fadeTime:5);
~del.xmap(\in, 0!2);// so it's stereo
~verb.xmap(\in, ~sig);
)

//bring dry back into the mix
~sig.play(fadeTime:5);

~lfo = {SinOsc.kr(0.1).exprange(0.05, 0.5)}; // use to control delay time

(
~del.play.fadeTime_(3);
~del = {
	var sig;
	sig = CombL.ar(\in.ar(0), 1, \indeltime.kr(0.3), 8);
	sig = sig * 0.5;
};
)

//modulate delay time
~del.xmap(\indeltime, ~lfo);

~lfo2 = {SinOsc.kr(0.12).exprange(400,5000)};

(
~sig.play.fadeTime_(3);
~sig = {
	var sig, trig, env, buf, rel, rate;
	rel = {exprand(0.2,2)}!12;
	trig = Trig.kr(Dust.kr(1!12), rel);
	rate = TChoose.kr(trig, (-12..24).midiratio);
	buf = TChoose.kr(trig, (0..3).collect({arg n; e.buf[n]}));
	sig = PlayBuf.ar(1, buf, rate, trig);
	env = Env.perc(0.001, rel, 1, -2).kr(0, trig);
	sig = sig * env;
	sig = Splay.ar(sig) * 0.5;
	sig = RLPF.ar(sig, \filt.kr(15000), 0.2);
}
)

//apply resonant lowpass filter to source signal
~sig.xmap(\filt, ~lfo2);

~lfo = {SinOsc.kr(0.1).exprange(0.1, 0.5)};

(
//unmap and fade out
~verb.xmap(\in, 0);
~del.xmap(\in, 0!2);
~sig.clear(3);
)

////////////////////////////////
//an alternative routing approach:
//plug proxy objects directly into other proxy source functions

p.clear;

(
~sig.play.fadeTime_(2);
~sig = {
	var sig, trig, env, buf, rel, rate;
	rel = {exprand(0.2,2)}!12;
	trig = Trig.kr(Dust.kr(1!12), rel);
	rate = TChoose.kr(trig, (-12..24).midiratio);
	buf = TChoose.kr(trig, (0..3).collect({arg n; e.buf[n]}));
	sig = PlayBuf.ar(1, buf, rate, trig);
	env = Env.perc(0.001, rel, 1, -2).kr(0, trig);
	sig = sig * env;
	sig = Splay.ar(sig) * 0.25;
}
)


// directly plug in the signal
(
~verb.play.fadeTime_(3);
~verb = {
	var sig;
	sig = GVerb.ar(~del.ar(1) + ~sig.ar(1), 250, 9);  // Gverb expects a monophonic input and output stereo. and sig is outputting a stereo signal so what we need to say sig.ar and then the number of channels. Pass delay first, then signal
	sig = LPF.ar(sig, 1000);
	sig = sig * 0.5;
};
)

(
~del.play.fadeTime_(3);
~del = {
	var sig;
	sig = CombL.ar(~sig.ar(2), 1, 0.3, 8); // 2 channels
	sig = sig * 0.5;
};
)

~lfo.clear;
~lfo = {SinOsc.kr(0.1).exprange(0.05,0.8)}

(
~del.play.fadeTime_(3);
~del = {
	var sig;
	sig = CombL.ar(~sig.ar(2), 1, ~lfo.kr(1), 8);
	sig = sig * 0.5;
};
)

(
~del.play.fadeTime_(3);
~del = {
	var sig;
	sig = CombL.ar(~sig.ar(2), 1, ~lfo.kr(1).lag(3), 8);
	sig = sig * 0.5;
};
)

//side note — you can set volume of proxy monitoring nodes via .vol_(number)
~sig.vol_(1.0);
~del.vol_(1.0);

p.clear(3);

//set & xset

(
~sig.play.fadeTime_(3);
~sig = {
	var sig, detune = \detune.kr(1), bend;
	bend = LFNoise2.kr(0.1!16).bipolar(detune).midiratio;// 16 channels. ranging from positive to negative detune. converted to midi ratio .it is the value in semitones in either direction
	sig = Saw.ar(\freq.kr(200) * bend) * 0.1;  //a frequency which is 200 multiplied by this frequency deviation signal scaled down all 16 channels spread over stereo,  Try LFTri, Saw, Pulse, Varsaw
	sig = LPF.ar(sig, \cf.kr(2000));
	sig = Splay.ar(sig);
};
)

//instantaneous set
~sig.set(\freq, 450, \detune, 4); // even if I change the Ugen in ~sig, the freq will stay with set

//xfade new version with updated parameters
~sig.xset(\freq, 28.midicps, \detune, 9);

(
//with varlagged parameters
~sig.play.fadeTime_(3);
~sig = {
	var sig, detune = \detune.kr(1).varlag(3,1), bend;
	bend = LFNoise2.kr(0.1!16).bipolar(detune).midiratio;
	sig = Saw.ar(\freq.kr(200).varlag(2,1) * bend) * 0.1;
	sig = LPF.ar(sig, \cf.kr(2000));
	sig = Splay.ar(sig);
};
)

//set will interpolate with lag time
~sig.set(\freq, 50, \detune, 0.5);

//xset will ignore lag time, crassfade the lagtime
~sig.xset(\freq, 150, \detune, 2);
~sig.xset(\freq, 28.midicps, \detune, 2);

~sig.clear(6);


//check more example in Reference: NodeProxy