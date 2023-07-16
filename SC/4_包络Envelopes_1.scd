/*定义
In sound and music, an envelope describes how a sound changes over time. It may relate to elements such as amplitude (volume), frequencies (with the use of filters) or pitch.

Envelope generators, which allow users to control the different stages of a sound, are common features of synthesizers, samplers, and other electronic musical instruments. The most common form of envelope generator is controlled with four parameters: attack, decay, sustain and release (ADSR).


UGen -> Envelopes
*/

s.boot;

x = {PinkNoise.ar * 0.5}.play;


Line

/* UGen -> done-actions
0	do nothing when the UGen is finished
2	free the enclosing synth

*/

s.plotTree;


(
x = {
	var sig, env;
	env = Line.kr(1, 0, 1);
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play;
)

x.free;

(
{
	var sig, env;
	env = Line.kr(1, 0, 1, doneAction: 2);  //控制音量
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play;
)

(
{
	var sig, freq, env;
	env = XLine.kr(1, 0.01, 5, doneAction:2); //argument "end" 不能为0
	freq = XLine.kr(880, 110, 5, doneAction:0); // 参数dur控制时长， 音量包络时长一定要大于音高包络时长
	sig = Pulse.ar(ExpRand(freq)) * env;
}.play;
)


// dont't put doneAction 2 on a 1 second UGEN
s.record;
s.stop;