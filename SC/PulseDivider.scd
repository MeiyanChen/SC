//clock dividers and step sequencers aretwo examples of tools that interact with trigger signals and allow us to do interesting things with timing and rhythm
s.boot;


//pulse divider counts pulses and when count equals div it outputs a pulse of its own and resets the count to zero.


(
{
	var clock, pdiv;
	clock = Impulse.ar(15);
	pdiv = PulseDivider.ar(clock, div:2);
	Trig.ar([clock, pdiv], SampleDur.ir*50);
}.plot(0.5, bounds:Rect(150, 300, 1600, 500), minval: -0.1, maxval:1.1);
)  //these signals generate single sample impulse which generally don't show up nicely on a plot. but we can use Trig to extend them and make them more visible. as you can see pulse divider gives one pulse for every two received


(
{
	var clock, pdiv;
	clock = Impulse.ar(15);
	pdiv = PulseDivider.ar(clock, div:[2, 3, 4]); // multichannel expasion
	Trig.ar([clock, pdiv].flat, SampleDur.ir*50);
}.plot(0.5, bounds:Rect(150, 300, 1600, 500), minval: -0.1, maxval:1.1);
)


//the start parameter offsets the initial count. it's essentially a phase control. here's division by three with start values 0 1 and two if start equals div minus one as it does here at the bottom pulse divider will generate a pulse right at the beginning pulse
(
{
	var clock, pdiv;
	clock = Impulse.ar(15);
	pdiv = PulseDivider.ar(clock, div:3, start:[0, 1, 2]);
	Trig.ar([clock, pdiv].flat, SampleDur.ir*50);
}.plot(0.5, bounds:Rect(150, 300, 1600, 500), minval: -0.1, maxval:1.1);
)




//div values represent duration per pulse. in other words a smaller number means more frequent pulses. so the Rhythm we actually hear is the least common multiple divided by div
(
{
	var clock, pdiv, sig, div= [3, 4]; // polyrythm , 3 left channel, 4 right channel
	clock = Impulse.ar(15);
	pdiv = PulseDivider.ar(clock, div:div, start:div -1);
	sig = SinOsc.ar([500, 900]) * Env.perc(0.002, 0.1).ar(gate: pdiv) * 0.1;
}.play(fadeTime: 0);
)




//  60/[3, 4, 5]
(
{
	var clock, pdiv, sig, div= [20, 15, 12];
	clock = Impulse.ar(45);
	pdiv = PulseDivider.ar(clock, div:div, start:div -1);
	sig = SinOsc.ar([500, 900, 1300]) * Env.perc(0.002, 0.1).ar(gate: pdiv) * 0.1;
	Splay.ar(sig);
}.play(fadeTime: 0);
)
//don't get distracted by the math, instead just throw numbers at it until it sounds good



//here div is the integers 2 through 20 used to divide pulses and also interpreted as scale degrees to generate pitch information
(
{
	var clock, pdiv, notes, sig, div= (2..20);
	clock = Impulse.ar(15);
	pdiv = PulseDivider.ar(clock, div:div, start:div -1);
	notes = DegreeToKey.kr(
		LocalBuf.newFrom(Scale.lydian.degrees),
		div - 2,
	) + 64;
	sig = SinOsc.ar(notes.midicps) * Env.perc(0.002, 0.1).ar(gate: pdiv) * 0.1;
	Splay.ar(sig);
}.play(fadeTime: 0);
)




// Pulsedivider in Playbuf --------------------------------


b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav"); // 尝试用打击乐音频
b.play;

(
{
	var clock, pdiv, sig, div= (2..20);
	clock = Impulse.ar(15);
	pdiv = PulseDivider.ar(clock, div:div, start:div -1);
	sig = PlayBuf.ar(1, b, BufRateScale.ir(b),
		trigger: pdiv,
		startPos: div.linlin(2, 21, 0, BufFrames.ir(b)); //start positions are derived by mapping div values across the length of the buffer
	);
	sig = sig * Env.perc(0.002, 0.1).ar(gate: pdiv) * 0.5;
	Splay.ar(sig);
}.play(fadeTime: 0);
)

//Stepper---------------------------------------------------------

// stepper also counts pulses, but outputs the count value itself which repeatedly goes from Min to Max.

(
{
	var clock, step;
	clock = Impulse.ar(10);
	step = Stepper.ar(clock, min:0, max:15).poll(clock); // 0 to 15
}.play(fadeTime: 0);
)



(
{
	var kick, clave, blip, metro, clock, step;
	clock = Impulse.ar(10);
	step = Stepper.ar(clock, reset: Impulse.ar(0), min:0, max:15).poll(clock); // an Impulse with frequency 0 returns a single impulse//  provide a one-time reset trigger which forces stepper to start at its Min value otherwise the first clock pulse makes it start one higher
	metro = WhiteNoise.ar(0.03 ! 2) * Env.perc(0, 0.05).ar(gate: clock);
	blip = SinOsc.ar(5000 ! 2) * Env.perc(0, 0.05).ar(gate: step  < 1) * 0.3; ////to put a tone on each downbeat we can gate the tone envelope with step less than one, which of course is only true at the beginning of each cycle this works. this is because on the server, a conditional check is 1 if true, 0 if false.
	blip + metro;
}.play(fadeTime: 0);
)

//step % 8 < 1     //if we modulo step count by half, half the cycle size we get a blip on every half note

//step % 4 < 1     //subdividing again puts a blip on every quarter note

//step < 4 * clock     //four blips, one on each of the first four 16th notes of the cycle

//step - 4 % 16 < 4 * clock      // to shift this cluster of notes to a later beat, we can subtract a value from Step,  modulo by total steps to wrap back to the correct range

//step - 2 % 3 < 1 * clock   //  modulo values that don't evenly divide the cycle create polyrythms, so here's a new layer step Min - 2 mod 3 will be less than one on Beats 2 5 8 11 and 14 so sort of a clav style Rhythm


(
{
	var kick, clave, blip, metro, clock, step;
	clock = Impulse.ar(10);
	step = Stepper.ar(clock, reset: Impulse.ar(0), min:0, max:15).poll(clock);
	metro = WhiteNoise.ar(0.03 ! 2) * Env.perc(0, 0.05).ar(gate: clock);
	blip = SinOsc.ar(5000 ! 2) * Env.perc(0, 0.05).ar(gate: step - 4 % 16 < 4 * clock) * 0.3;
	clave = SinOsc.ar([2300, 2450]) * Env.perc(0, 0.1).ar(gate: step - 2 % 3 < 1 * clock) * 0.2;
	kick = SinOsc.ar( // a synthesis kik
		freq: Env([40, 350, 40], [0.0001, 0.1], -6).ar(gate:step % 4 < 1 * clock),
		mul: Env([0, 0.25, 0], [0.0001, 0.6], -6).ar(gate:step % 4 < 1 * clock),
	);
	clave + blip + metro + kick;
}.play(fadeTime: 0);
)



// example combine Pulsediver and Stepper
//merging previousexamples and adding some variations pause


(
x = {
	var pd, sig, kick, clave, blip, metro, notes, clock, pdiv, step, div = (4..16);
	clock = Impulse.ar(\n.kr(8));
	pdiv =  PulseDivider.ar(clock, div);
	step = Stepper.ar(clock, reset: Impulse.ar(0), min:0, max:15);
	metro = WhiteNoise.ar(0.03 ! 2) * Env.perc(0, 0.01).ar(gate: clock);
	blip = SinOsc.ar(5000 ! 2) * Env.perc(0, 0.05).ar(gate: step - 4 % 16 < 4 * clock) * 0.6;
	clave = SinOsc.ar([2300, 2450]) * Env.perc(0, 0.1).ar(gate: step - 2 % 3 < 1 * clock) * 0.08;
	kick = SinOsc.ar(
		freq: Env([40, 350, 40], [0.0001, 0.1], -6).ar(gate:step % 4 < 1 * clock),
		mul: Env([0, 0.25, 0], [0.0001, 0.6], -6).ar(gate:step % 4 < 1 * clock),
	);
	notes = DegreeToKey.kr(LocalBuf.newFrom([0, 3, 5, 7, 10]), div - 2) + 45;
	sig = Pulse.ar(notes.scramble.midicps) * Env.perc(0.001, 0.3).ar(gate:pdiv);
	sig = Splay.ar(
		MoogFF.ar(sig, Env.perc(curve: -12).ar(gate:pdiv).linexp(0, 1, 100, 3000), 2.5),
		spread: 0.75
	);
	pd = Splay.ar(
		PlayBuf.ar(1, bufnum: b,
			rate: BufRateScale.ir(b) * (8 - step).midiratio,
			trigger: pdiv,
			startPos: div/20 * BufFrames.ir(b),
			) * Env.perc(0.002, 0.1).ar(gate: pdiv),
		spread:0.75
	);
	sig = [pd * 2, sig, clave, blip, metro, kick].sum;
	sig = sig.blend(LPF.ar(GVerb.ar(sig.sum, 300, 4), 1500), 0.015);
}.play(fadeTime: 0);
)


x.set(\n, 4);
x.set(\n, 2);
x.set(\n, 0);
x.free;

































