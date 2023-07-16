s.options.sampleRate = 48000;
s.boot;
b = Buffer.readChannel(s, "/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Supercollider/zifuzhimingpart.wav", channels:[0]);




// rate setting / pitch shifter ------------------------------------------------------------------
/*this value is a ratio so 2 transposes every grain up an octave, classic chipmunk voice.  and 0.5 is an octave in the other direction.  and that is your basic demonic voice but the interesting thing here is that we're shifting pitch.

without also affecting the total duration of the audio file and this is something that we can't really do using basic sample playback techniques with like playbuff and buff read okay.
so let's adjust a few things and see if we can't make this pitch shifting effect a little bit cleaner for example we might consider using a higher grain  density and relatively long grains to kind of fill in all the gaps,  and we should anticipate that lots of grains possibly means higher amplitude so scaling back the amplitude is probably a good idea.


*/


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(100), // a higher grain  density
	    0.2, // relatively long grains
		b,
		0.5, // try 2, 0.5, 1.35, 0.7
		(
			Phasor.ar(0, 1* BufRateScale.ir(b), 0, BufSamples.ir(b)-1)
		   + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)
	    ) / BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.4; //scaling back the amplitude
}.play
)


/*
and keep in mind you don't have to think in terms of frequency ratios which can be kind of clumsy if you want to think in terms of musical semitones you can do so and just use midi ratio to convert

if you've ever played around with pitch correction software, you've probably noticed that you can make small pitch change,  and kind of get away with it without anyone noticing.  but if you try to adjust by like several octaves then the sound just becomes utterly utterly ridiculous.
*/

(
{ arg pitch
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(100),
	    0.2,
		b,
		30.midiratio, // try -1, -2, -3, -4, 30
		(
			Phasor.ar(0, 1* BufRateScale.ir(b), 0, BufSamples.ir(b)-1)
		   + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)
	    ) / BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.4;
}.play
)


/*there is one possible pitfall to be aware of.  suppose we eliminate this random pointer deviation by collapsing the range to zero

and so now let's play around with these rate values once again, weirdly all of a sudden the sound has this strong ringing character

*/

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(100),
	    0.2,
		b,
		0.7,  //try 1.4, 1.5, 1.6, 0.7, 0.8
		(
			Phasor.ar(0, 1* BufRateScale.ir(b), 0, BufSamples.ir(b)-1)
		   + LFNoise1.ar(100).bipolar(0.0 * SampleRate.ir)   //*
	    ) / BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.4;
}.play
)


/* let's swap this value for mouse x which might make it a little easier to hear what's going on. what I meant to put here was 0.5 comma 2 comma 1. but i gave myself a linear range from 0.5 to 2.1
but basically we're having phase issues with overlapping grains.
 comb filtering (https://www.dpamicrophones.com/mic-university/the-basics-about-comb-filtering-and-how-to-avoid-it#:~:text=Comb%20filtering%20occurs%20when%20a,same%20signal%20at%20different%20positions.)  which is a type of resonance caused by a regular pattern of signal interference (https://zh.wikipedia.org/wiki/%E5%B9%B2%E6%B6%89_(%E7%89%A9%E7%90%86%E5%AD%A6)) .
often the result of a signal being added to a delayed copy of itself.
and that's basically what's going on here,  there's grain generation rate,  grain duration,  the resampling factor resulting from the playback rate, and of course there's also the content of the original audio file to consider and basically all these factors are working together to create a predictable pattern of phase related interference between overlapping grains.

as a result certain frequencies reinforce themselves and other frequencies cancel themselves out so in the end we get these unique spectral colors with very strong resonance at certain harmonics we can hear these clearly whenever the mouse is standing still and moving the mouse causes the resonances to kind of sweep up and down creating this kind of zipper effects
*/

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(100),
	    0.2,
		b,
		MouseX.kr(0.5, 2.1).poll,
		(
			Phasor.ar(0, 1* BufRateScale.ir(b), 0, BufSamples.ir(b)-1)
		   + LFNoise1.ar(100).bipolar(0.0 * SampleRate.ir)   //*
	    ) / BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.4;
}.play
)




/*
the point is if you're aiming for a clean pitch shift this tiny amount of randomness in the grain pointer can make all the difference because even a tiny bit is enough to diffuse,
the phase issues and produce a noticeably cleaner sound


*/


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(100),
	    0.2,
		b,
		MouseX.kr(0.5, 2.1).poll,
		(
			Phasor.ar(0, 1* BufRateScale.ir(b), 0, BufSamples.ir(b)-1)
		   + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)   //*
	    ) / BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.4;
}.play
)


/* similarly you might find a slight improvement if you use dust instead of impulse.  for the grain trigger because that removes the inherent fundamental frequency of the grain trigger,
because dust is random the overall amplitude of the output signal might be a little bit less consistent than impulse but it is not too much of a problem especially if you're generating plenty of grains



*/


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar(100),
	    0.2,
		b,
		MouseX.kr(0.5, 2.1).poll,
		(
			Phasor.ar(0, 1* BufRateScale.ir(b), 0, BufSamples.ir(b)-1)
		   + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)   //*
	    ) / BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.4;
}.play
)


// with dust usually or at least in this case you can actually omit the slight randomness in the pointer and the pitch shift still sounds pretty good
//you can decide for yourself which version you think sounds best



(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar(100),
	    0.2,
		b,
		MouseX.kr(0.5, 2.1).poll,
		(
			Phasor.ar(0, 1* BufRateScale.ir(b), 0, BufSamples.ir(b)-1)
		   + LFNoise1.ar(100).bipolar(0.00 * SampleRate.ir)   //*
	    ) / BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.4;
}.play
)



/*
let's use the horizontal and vertical mouse position to control pitch and time independent of each other


*/


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar(100),
	    0.2,
		b,
		MouseX.kr(0.5, 2.1),
		(
			Phasor.ar(0, MouseY.kr(0.1, 2.1)* BufRateScale.ir(b), 0, BufSamples.ir(b)-1)
		   + LFNoise1.ar(100).bipolar(0.0 * SampleRate.ir)   //*
	    ) / BufSamples.ir(b),
		2,
		0,
		-1,
		512
	);
	sig = sig * 0.4;
}.play
)




//these four parameters grain trigger grain duration grain playback rate and grain start position i consider these four central pillars of grainbuf








//----------------------------------------------------------------------------
//interpolation value

// MouseY is what determines how samples are interpolated when the playback rate changes,  2 is linear,  but if we drop it to 1,  then the change in quality is subtle but definitely audible particularly for downward pitch shifting

//down pitching means the granulator is stretching out the wave forming the grains. in that case it has to do some guesswork in between the original samples . and with no interpolation it's just not guessing at all so the resolution of the waveform degrades quite a bit.   and there's a noticeable loss of quality that manifests as a bunch of high frequency garbage,  so generally i would not recommend an interpolation of 1.

//now if you want to go up from linear to cubic personally i cannotvhear much of a difference in most cases.

//but the increase in cpu is noticeable so with linear interpolation kind of hovers around two percent maybe just below.  and with cubic it's up around three percent maybe just below now that might not seem like very much but if you've got a lot of granulation happening all percent maybe just below now that might not seem like very muc.  but if you've got a lot of granulation happening all at once. it can really add up so pick whichever one you like best but generally i think linear strikes a good balance


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar(400),//* is what determines how samples are interpolated when the playback rate changes
	    0.1,
		b,
		0.7,
		(                   //*
			Phasor.ar(0, 1* BufRateScale.ir(b), 0, BufSamples.ir(b)-1)
		   + LFNoise1.ar(100).bipolar(0.0 * SampleRate.ir)
	    ) / BufSamples.ir(b),
        2, // voice down about half an octave with linear interpolation
		0.8,  // try 0.8, -0.8
		-1,
		512
	);
	sig = sig * 0.4;
}.play
)


/*
-------------------------------------------
panning is straightforward we know how to pan ,  since we specified two channels this value here between minus one and plus

*/



(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar(400),
	    0.1,
		b,
		0.7,
		(
			Phasor.ar(0, 1* BufRateScale.ir(b), 0, BufSamples.ir(b)-1)
		   + LFNoise1.ar(100).bipolar(0.0 * SampleRate.ir)
	    ) / BufSamples.ir(b),
		4,
        2, // try 1
		LFNoise1.kr(100).range(-1, 1), //* automate the pan position as long as we keep the output range between negative one and positive one
		-1,
		512
	);
	sig = sig * 0.4;
}.play
)




//-------------------------------
//for grain envelope this negative one means we're using that built-in handling envelope and with a configuration like this we can very easily hear that bell curve shape

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(1),
	    0.75,
		b,
		1,
		0.45,
        2, // try 1
		LFNoise1.kr(100).range(-1, 1),
		-1,
		512
	);
	sig = sig * 0.4;
}.play
)


// a percussive shape with a very short attack and long release the first step is to create an instance
/*
we load this env into a buffer  and the envelope.

but we can't just load an end into a buffer as is because these types of data are not compatible with each other.

buffers are discrete 离散,  Envs are not.  we need to convert the end into a discrete collection of numbers. and we can do that with the method discretize providing the size of the collection in parentheses.

the default is 1024 and that's probably fine but since we have such a short attack transient i think i'd like just a little bit more resolution so i'm going to go with 8192, this does not actually have to be a power of two
*/


(
e = Env.new([0, 1, 0], [0.01, 1], [0, -4]);
~grainEnv = Buffer.sendCollection(s, e.discretize(8192)) //so we use buffer.send collection providing the server
)


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(10),
	    0.75,
		b,
		1,
		0.4,
        2, // try 1
		0,
		~grainEnv,
		512
	);
	sig = sig * 0.7;
}.play
)









//------------------------------------------------------------------------------------------------------------------------------------------
//使用注意事项

/*
no.1: ar and kr

earlier in the video i used the mouse to control the frequency at which grains are generated, and i used an audio rate impulse generator like this.
*/

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(MouseX.kr(1, 200, 1).poll),
	    0.09,
		b,
		1,
		0.2,
        2, // try 1
		0,
		-1,
		512
	);
}.play
)


//now you might reasonably ask impulse is controlling some aspect of grainbuf, we're not listening to impulse directly so can't we just use kr and save some cpu cycles


(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.kr(MouseX.kr(1, 200, 1).poll), //* Impulse.ar(MouseX.kr(1, 200, 1).poll)
	    0.09,
		b,
		1,
		0.2,
        2, // try 1
		0,
		-1,
		512
	);
}.play
)

// kr 只在低音区声音平稳
//compare that again to ar which i think you'll agree sounds much better, at low frequencies it's really not a problem but when we get into higher frequencies you know low hundreds or so /
// kr just sounds kind of crappy, the grains are not perfectly synchronized , it kind of hiccups a little bit.
//this is simply because the control rate is not fast enough to provide the precise resolution that we're looking for with these fast synchronous grains, and this kind of problem might pop up with other parameters in grain buff as well.

//use audio rate Ugen, especially if it's a periodic generator running at a relatively high frequency






//------------------------

//No.2: position


//here's a question, suppose we configure grainbuf to produce grains that are each two seconds long but they start 85 percent of the way through the file in this case.
//how does grainbuf manage to conjure up a two second grain. if grainbuf bumps into the end of the file it wraps back to the beginning and finishes the rest of the grain there
//so this is just something to be aware of and a very good reason to make sure the ends of your original file are faded in and faded out because if you're careless and like clumsily hack off some important content then all of a sudden there could be a huge discontinuity between the end and the beginning of your buffer and that means some grains could have a big ugly click right in the middle




(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(0.5),
	    2,
		b,
		1,
		0.85,
        2,
		0,
		-1,
		512
	);
}.play
)


b.duration*0.85;





//no.3: negative playback ratios------------------------------------------------------------------------------

//  it results in grains being played backwards but it's useful to know precisely how it works. as you might be able to guess is not backwards.  instead of extracting the grain and then reversing. grainbuf  starts at the start position and actually moves the pointer in the opposite direction like literally plays the file backwards. so what we're getting is the word, but backwards really again this is just a little nuance to keep in mind if you feel like messing around with negative playback rates
//先逆行，再产生粒子
(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(0.8),
	    1.1,
		b,
		1, // try -1
		0.2,
        2,
		0,
		-1,
		512
	);
}.play
)



//no.4: maxgrains-----------------------------------------------------------------------------

//max grains 512 by default,  this is a high ceiling that you probably won't hit unless you're actively trying to do so, nevertheless a very sensible question is what happens if you go above the maximum number of grains. does it crash the server? does it blow up like a recursive filter? fortunately it does not.

//to demonstrate what happens i'm going to make a somewhat dense texture and drop max grains all the way down to 12. so it sounds fine sounds like what i'd expect it to sound like but the post window is clearly trying to get our attention and just for emphasis let's go ahead and drop max grains all the way down to two.

//grain buff just won't create any new grains if it's already at capacity it's kind of like a bouncer at the entrance to a club who is not letting people in because it is already ridiculously crowded inside
(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Dust.ar(40),
	    0.2,
		b,
		1, // try -1
		0.2,
        2,
		0,
		-1,
		512 // try 2
	);
}.play
)




// no.5: 尝试不同类型的音频
//your results will vary greatly depending on the type of source (spoken word,  instruments synthesized sounds ambient or environmental recordings, drum loops ) make sure you're careful with your volume when using high grain densities or long grain durations








