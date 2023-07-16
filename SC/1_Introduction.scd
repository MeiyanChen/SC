/*
1.Supercollider的基本了解

编程语言形式
The SC language combines the object-oriented structure of Smalltalk and features from functional programming languages with a C-family syntax.

快捷键：
Boot server （启动服务器） cmd + b
Evaluate (执行代码)  cmd + enter
Stop （停止代码&声音播放）cmd + .
Reference (查找参考信息)  cmd + d

2. 编程基本语言理解
Object 对象
Message 信息
Variable 变量
Local variable 本地变量
Global variable 全局变量
Argument  参数&自变量
Comment 注解

3. 注意事项

输入代码时，仔细检查是否有错误符号
每条完成代码结束，都要以引号（” ; ”）结束
注意音量， 随时准备关闭服务器，或者退出软件

*/



{ [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.play;


receiver.message

3.cubed //3的三次方


//global variable: 通用的变量 a到z
x = 3.cubed
x
x + 10

// local variable 只能用在特定的范围 可以自命名
(
var number;
number = 3.cubed;
)

number; // 无法使用
~number //加上 "~"转变为global variable

~number = 3.cubed;
~number;



(
SynthDef(\snare909,{ |out=0,mul=1,velocity=1|
	var excitation, membrane;

	excitation = LPF.ar(WhiteNoise.ar(1), 7040, 1) * (0.1 + velocity);
	membrane = (
		/* Two simple enveloped oscillators represent the loudest resonances of the drum membranes */
		(LFTri.ar(330,0,1) * EnvGen.ar(Env.perc(0.0005,0.055),doneAction:0) * 0.25)
		+(LFTri.ar(185,0,1) * EnvGen.ar(Env.perc(0.0005,0.075),doneAction:0) * 0.25)

		/* Filtered white noise represents the snare */
		+(excitation * EnvGen.ar(Env.perc(0.0005,0.4),doneAction:2) * 0.2)
		+(HPF.ar(excitation, 523, 1) * EnvGen.ar(Env.perc(0.0005,0.283),doneAction:0) * 0.2)

	) * mul;
	Out.ar(out, membrane!2)
}).add
)

Synth(\snare909,[\mul,0.5,\velocity, rrand(0.5, 1.0)]);