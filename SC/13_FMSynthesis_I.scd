/*
FM Synthesis = Frequency modulation synthesis
https://zh.wikipedia.org/wiki/%E9%A2%91%E7%8E%87%E8%B0%83%E5%88%B6

Frequency modulation synthesis (or FM synthesis) is a form of sound synthesis whereby the frequency of a waveform is changed by modulating its frequency with a modulator. The frequency of an oscillator is altered "in accordance with the amplitude of a modulating signal".

FM refers to a synthesis configuration in which the output signal of one oscillator called the modulator is used to offset the frequency of another oscillator called the carrier.

carrier(载波) and modulator(调幅/变) are both sine waves
載波（carrier wave）是指被調變以傳輸訊號的波形，一般為正弦波
調變（modulation）是一種將一個或多個週期性的載波混入想傳送之訊號的技術

调变方式：
相位调变 phase modulation, PM
频率调变 frequency modulation, FM
振幅调变 amplitude modulation, AM

*/





s.boot;
s.scope;
FreqScope.new;

{SinOsc.ar(500) * 0.2!2}.play;   // carrier oscillator
//         freq   mul stereo



{SinOsc.ar(500 + SinOsc.ar(1)) * 0.2!2}.play;   // 499-501 hz的频率改变不太明显
//               modulator

{SinOsc.ar(500 + SinOsc.ar(1, mul:20)) * 0.2!2}.play; // 因此可加大modulator的振幅  carrier ranges：480 - 520 hz


{SinOsc.ar(500 + SinOsc.ar(1, mul:400)) * 0.2!2}.play; //carrier ranges：480 - 520 hz
{SinOsc.ar(500 + SinOsc.ar(2, mul:400)) * 0.2!2}.play;
{SinOsc.ar(500 + SinOsc.ar(4, mul:400)) * 0.2!2}.play;
{SinOsc.ar(500 + SinOsc.ar(8, mul:400)) * 0.2!2}.play;


{SinOsc.ar(500 + SinOsc.ar(MouseX.kr((1, 2000, 1).poll), mul:400)) * 0.2!2}.play;
//                                   最左，最右 指数上升步数

{SinOsc.ar(MouseY.kr(200, 5000, 1).poll + SinOsc.ar(MouseX.kr(1, 2000, 1).poll, mul:400)) * 0.2!2}.play;
        //carrier frequency

{SinOsc.ar(MouseY.kr(200, 5000, 1).poll + SinOsc.ar(MouseX.kr(1, 2000, 1).poll, mul: LFNoise0.kr(8).range(20, 10000))) * 0.2!2}.play;
                                                                                //non interpolating noise generator for modulator amplitude generating new values 8 times a second which can range from 20 to 10000


(
SynthDef.new(\fm, {
	arg carHz = 500, modHz = 100, modAmp = 200;
	var car, mod;
	mod = SinOsc.ar(modHz, mul:modAmp);
	car = SinOsc.ar(carHz + mod) *0.2!2;
	Out.ar(0, car);
}).add;
)

Synth(\fm);




(
SynthDef.new(\fm, {
	arg carHz = 500, modHz = 100, modAmp = 200, atk = 0.01, rel = 1, amp = 0.2, pan = 0;
	var car, mod, env;
	env = EnvGen.kr(Env.perc(atk, rel), doneAction:2);
	mod = SinOsc.ar(modHz, mul:modAmp);
	car = SinOsc.ar(carHz + mod) * env * amp;
	car = Pan2.ar(car, pan);
	Out.ar(0, car);
}).add;
)

Synth(\fm, [\pan, 0, \amp, 0.3, \carHz, 1000, \modHz, 300]);
 // pan: -1, 0, 1



(
Synth(\fm, [
	\carHz. exprand(20, 10000),
	\modHz, exprand(20, 10000),
	\modAmp,rrand(0, 10000),
	\amp, exprand(0.1, 0.5),
	\atk, exprand(0.001, 0.05),
	\rel, exprand(0.05, 1.2),
	\pan, rrand(-1.0, 1.0),
]);
)



(
p = Pbind(
	\instrument, \fm,
	\dur, 1/8,
	\carHz, exprand(20, 10000),  // 固定数据
	\modHz, exprand(20, 10000),
	\modAmp,rrand(0, 10000),
	\amp, exprand(0.1, 0.5),
	\atk, exprand(0.001, 0.05),
	\rel, exprand(0.05, 1.2),
	\pan, rrand(-1.0, 1.0),
).play;
)


(
p = Pbind(
	\instrument, \fm,
	\dur, 1/8, // an eight of a second
	\carHz, Pexprand(20, 10000),
	\modHz, Pexprand(20, 10000),
	\modAmp,Pwhite(0, 10000),
	\amp, Pexprand(0.1, 0.5),
	\atk, Pexprand(0.001, 0.05),
	\rel, Pexprand(0.05, 1.2),
	\pan, Pwhite(-1.0, 1.0),
).play;
)

//无法写出旋律  因为carrier 和modulator frequency 无法与我们脑中能感知的音高相对应
p.stop;


























