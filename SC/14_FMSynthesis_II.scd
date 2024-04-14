 s.boot;
s.scope;
FreqScope.new;

/*FM synthesis creates additional frequency components in the output spectrum called sidebands 边频带 that appear in pair on the either side of the carrier frequency,
where these sidebands appear depends on the frequency of the modulator and the number of sidebands that are present depends on a factor called index of modulation
which is directly proportional to the amplitude of modulator

 sideband pair https://zh.wikipedia.org/wiki/%E8%BE%B9%E5%B8%A6

index of modulation => amplitude of modulator
*/



{SinOsc.ar(800 + SinOsc.ar(200, mul:0)) * 0.2!2}.play; // index of modulation is 0, 因此不会显示调变信号

{SinOsc.ar(800 + SinOsc.ar(200, mul:MouseY.kr(0, 400).poll)) * 0.2!2}.play; //观察调变幅度  control the number of sideband pairs that appear in the spectrum

//rule 1: as the amplitude of the modulator increases, the audible sidebands increases (we get a wider and more complex output spectrum)-------------------------------

{SinOsc.ar(800 + SinOsc.ar(MouseX.kr(200, 1200).poll, mul:MouseY.kr(0, 400).poll)) * 0.2!2}.play;

//Rule 2: as modulator frequency increases, the spacing between sidebands increases---------------------------------------------------------------------------
// the interval at which side bands appear is equal to the modulator frequency


{SinOsc.ar(800 + SinOsc.ar(200, mul:400)) * 0.2!2}.play;
//with the modulator fixed at 200 Hz, sidebands appear below this 800 hz carrier at 600, 400, 200, and above the carrier at 1000, 1200, 1400 etc


{SinOsc.ar(800 + SinOsc.ar(300, mul:400)) * 0.2!2}.play; // 500, 200, above 1100, 1400, 1700

{SinOsc.ar(800 + SinOsc.ar(MouseX.kr(200, 1200).poll, mul:400)) * 0.2!2}.play;
// as modulator frequency increases, the lower sidebands look like they are about to cross into negative values but instead they bounce off 0 hz and get reflected back
// into the positive domain
// because: a negative frequency means we are asking an oscillator to produce its periodic shape in reverse


{SinOsc.ar(800 + SinOsc.ar(350, mul:400)) * 0.2!2}.play;  // sideband: 450, 100, -250 (reflect to positive 250) -600 (600, very quiet)

// 结论 ：modulator frequency determines sideband spacing, modulator amplitude determines the number of audible sidebands------------------------------------------------
// the carrier frequency simply determines the point of origin around which this cluster of sideband activity occurs

{SinOsc.ar(MouseX.kr(800, 3000, 1).poll + SinOsc.ar(350, mul:400)) * 0.2!2}.play;
//carrier and sidebands all shift together, but the relative spacing of the partial remains the same

{SinOsc.ar(500 + SinOsc.ar(MouseX.kr(1, 1200, 1).poll, mul:400)) * 0.2!2}.play;
//if we sweep the modulator frequency more slowly and listen really carefully, you will notice that there are these pockets where we get a very clear sense of pitch
// like where the modulator is almost exactly 100 hz, 250 hz, 2000 hz

//Rule 3: we tend to get a very clear sense of pitch when a carrier and modulator frequencies form a simple ratio(比率), like 2:1, 3:1, 3:2------------------------------

{SinOsc.ar(500 + SinOsc.ar(100, mul:400)) * 0.2!2}.play; // 5:1   稳定的波形   （以100hz为基础音的泛音频谱）
 //       carrier          modulator

{SinOsc.ar(500 + SinOsc.ar(250, mul:400)) * 0.2!2}.play; //2:1     250, 500, 750, 1000, 1250


{SinOsc.ar(500 + SinOsc.ar(2000, mul:400)) * 0.2!2}.play; // 1:4
//only get odd-numbered harmonics, 1500, 2500, 3500

// 频谱音乐 https://en.wikipedia.org/wiki/Spectral_music  （composition technique）

(
SynthDef.new(\fm, {
	arg freq = 500, mRatio = 1, cRatio = 1, modAmp = 200, atk = 0.01, rel = 1, amp = 0.2, pan = 0;
	var car, mod, env;
	env = EnvGen.kr(Env.perc(atk, rel), doneAction:2);
	mod = SinOsc.ar(freq * mRatio, mul:modAmp);
	car = SinOsc.ar(freq * cRatio + mod) * env * amp;
	car = Pan2.ar(car, pan);
	Out.ar(0, car);
}).add;
)

Synth(\fm, [\freq, 600]);  // 基音， （人耳能感知到的音高）
Synth(\fm, [\freq, 900]);
Synth(\fm, [\freq, 67.midicps]); // midi ->> hz
Synth(\fm, [\freq, 60.midicps, \cRatio, 2]);
Synth(\fm, [\freq, 60.midicps, \cRatio, 3]); // a cluster harmonics centered increasingly higher and higher on the overtone series
Synth(\fm, [\freq, 60.midicps, \cRatio, 2.7]);// non integer values will tend to give us spectrum that we perceive as being inharmonic (不调和频率,偏差音) with no clear pitch center, usually has kind of a bell like sound
//偏差音:   https://zh.wikipedia.org/wiki/%E5%81%8F%E5%B7%AE%E9%9F%B3

Synth(\fm, [\freq, 60.midicps, \cRatio, 1, \mRatio, 2]);
// if we increase the modulator multiplier by integers, the carrier stays put, but the spacing of the sidebands increases, so we get different combinations of overtones.
// non integer values tends to produce inharmonic spectra
Synth(\fm, [\freq, 60.midicps, \cRatio, 1, \mRatio, 8  ]);
Synth(\fm, [\freq, 60.midicps, \cRatio, 5, \mRatio, 2  ]);



// index = modAmp/modHz           --------------------------------------------------
/*index of modulation is expressed as the ratio of modulator amplitude to modulator frequency, it loosely corresponds to the number of audible sideband pairs in the spectrum.
The number of audible sideband pairs in the spectrum is equal to index + 1

*/
(
SynthDef.new(\fm, {
	arg freq = 500, mRatio = 1, cRatio = 1, index = 1, atk = 0.01, rel = 1, amp = 0.2, pan = 0;
	var car, mod, env;
	env = EnvGen.kr(Env.perc(atk, rel), doneAction:2);
	mod = SinOsc.ar(freq * mRatio, mul:freq * mRatio * index); //when index = 1,  modulator frequency and modulater amplitude are equal.
	car = SinOsc.ar(freq * cRatio + mod) * env * amp;
	car = Pan2.ar(car, pan);
	Out.ar(0, car);
}).add;
)

Synth(\fm, [\freq, 60.midicps, \index, 0]); // pure sine wave of note number 60

Synth(\fm, [\freq, 60.midicps, \index, 15]); // index增加， 边带数量增加

//add an envelope to control the index of modulation, an index envelope allows us to dynamically shape the sound spectrum over the chords of a single notes, make sounds more lively and interesting. it can also be useful for modeling the dynamic spectrum of some acoustic instruments

(
SynthDef.new(\fm, {
	arg freq = 500, mRatio = 1, cRatio = 1, index = 1,iScale = 5, atk = 0.01, rel = 1, cAtk = 4, cRel = (-4),  amp = 0.2, pan = 0;
	var car, mod, env, iEnv;
	iEnv = EnvGen.kr(   // index envelope
		Env.new(
			[index, index * iScale, index], // start at our base index value, move to the index scaled, and then back to the base index， 除次之外 也可完全独立，用其他任意数据
			[atk, rel],
			[cAtk, cRel] // curve value
		)
	);
	env = EnvGen.kr(
		Env.perc(atk, rel, curve: [cAtk, cRel]),
		doneAction:2    // we don't need another doneAction 2 to  free the synth whenever it's finished, that's already being handled by amplitude envelope
	);
	mod = SinOsc.ar(freq * mRatio, mul:freq * mRatio * iEnv);
	car = SinOsc.ar(freq * cRatio + mod) * env * amp;
	car = Pan2.ar(car, pan);
	Out.ar(0, car);
}).add;
)


Synth(\fm, [\freq, 47.midicps, \rel, 1]);
// at the peak amplitude of the sound the spectrum is relatively broad and as the amplitude decays, the higher partials fade away more quickly

Synth(\fm, [\freq, 47.midicps, \rel, 1, \iScale, 10]);
// if increase the index envelope scaling factor, then the peak of our sound has even more partials

Synth(\fm, [\freq, 35.midicps, \rel, 1, \iScale, 10, \cRel, -12]);
// if we fine-tune the release curve of the envelopes, can get a bass synth sound

Synth(\fm, [\freq, 47.midicps, \rel, 4, \index, 20, \iScale, 0.05]);
//start with a higher base, and scale it by a value between 0 - 1

Synth(\fm, [\freq, 47.midicps, \rel, 4, \index, 20, \iScale, 0.05, \mRatio, 10]);
Synth(\fm, [\freq, 47.midicps, \rel, 4, \index, 20, \iScale, 0.05, \mRatio, 0.5]);
//play around with the carrier modulator ratio




//PMOsc => phase modulation oscillator ---------------------------------------------------------------------------------------------------------

//详细了解相位

//wavetable oscillators: they read values from a table instead of mathematically calculating them on the fly, so modulating the phase of one of these oscillators means we are asking a wavetable pointer to move more quickly and more slowly through its wave table , and indereclty this affects the frequency of the oscillator in the exact same way that we've been doing, FM VS PM, different implementation but essentially same results

//波表合成 Wavetable synthesis: https://wikichi.icu/wiki/Wavetable_synthesis
// 波表综合基本上是基于 周期性的 复制任意的单周期 波形图.在波表合成中，采用某种方法来改变或 调制 在波表中选择的波形。波形表中的位置选择单个周期波形。数字的 插补 相邻波形之间的间隔允许动态平滑地改变所产生音调的音色。可以以多种方式来控制在任一方向上扫描波表，例如，通过使用LFO，包络线，压力或速度。

// source code:  Language -> Look Up Implementations -> PMOsc
// ^ means return

{SinOsc.ar(500 + SinOsc.ar(4, mul:4*  10)) * 0.2!2}.play;
         //carrier       modulator    index

{SinOsc.ar(500, SinOsc.ar(4, mul:10)) * 0.2!2}.play;
//phase modulator,  we don't manipulate the frequency directly, but instead use an SinOsc as the phase input for the carrier oscillator
//in PM, index of modulation is the modulator amplitude

{PMOsc.ar(500, 4, 10) * 0.2!2}.play;
// Pseudo (伪) Ugen, a Ugen that serves as a shorthand（速记，简写） for a more complex combination of other Ugens

{PMOsc.ar(500, 4, 50) * 0.2!2}.play; // more than 8pi

//when use SinOsc, phase shoud be in -8pi - +8pi, otherwise et clipped, PMOsc no such boundraies. but if its higher than 8pi, it sounds weird. the frequency of the carrier has this staircasing effect (阶梯效应 )because the internal phase values have a range that's bigger than plus and minus 8pi, so those values are getting truncated （缩短） and we end up losing the smooth sinusoidal movement in the carrier frequency.  Use mod(2pi) to avoid it.(在source code 里改)
// save -> Language -> Recompile Class Library

{SinOsc.ar(500 + SinOsc.ar(4, mul:4*  50)) * 0.2!2}.play;



(
SynthDef.new(\fm, {
	arg freq = 500, mRatio = 1, cRatio = 1, index = 1,iScale = 5, atk = 0.01, rel = 1, cAtk = 4, cRel = (-4),  amp = 0.2, pan = 0;
	var car, mod, mod2 env, iEnv;
	iEnv = EnvGen.kr(
		Env.new(
			[index, index * iScale, index],
			[atk, rel],
			[cAtk, cRel]
		)
	);
	env = EnvGen.kr(
		Env.perc(atk, rel, curve: [cAtk, cRel]),
		doneAction:2
	); // don't have to be SinOsc
	mod2 = SinOsc.ar(freq/10, mul:freq/10* iEnv);
	mod = SinOsc.ar(freq * mRatio + mod2, mul:freq * mRatio * iEnv);    //modulating the first modulator and then that signal modulates the carrier
	car = SinOsc.ar(freq * cRatio + mod) * env * amp;
	car = Pan2.ar(car, pan);
	Out.ar(0, car);
}).add;
)

Synth(\fm, [\rel, 3]);


//more example: http://sccode.org/1-5bA
























