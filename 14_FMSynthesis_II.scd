s.boot;
s.scope;
FreqScope.new;

/*FM synthesis creates additional frequency components in the output spectrum called sidebands that appear in pair on the either side of the carrier frequency,
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