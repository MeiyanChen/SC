/*
参考资料：
Supercollider 3 Server Tutorial
Client vs Server
Server Architecuture

1. Boot local server
Interpreter 解释程序 (显示绿色为启动)


-The name "SuperCollider" is in fact used to indicate five different things (Figure 1):
Supercollider实际上由以下五类事物构成：

--an audio server 音频服务器
--an audio programming language 音频程序语言
--an interpreter for the language, i.e. a program able to interpret it 程序语言解释器
--the interpreter program as a client for the server 解释器作为用户端的服务器
--the application including the two programs and providing mentioned functionalities 有服务器和客户端以及其相关功能的运用程序


*/

Server.local.boot;
Server.local.quit;

s; // global variable

s.boot;
s.quit;


/*

2. Function 次程式或函数  //参考资料：Functions and Other Functionality
-用花括号"{}" 来封闭function
-可以重复使用

method


Synth
Frequency is just the frequency of the oscillator in Hertz (Hz), or cycles per second (cps)

Phase is given in radians, it's a value between 0 and 2 * pi
       //https://zh.wikipedia.org/wiki/%E7%9B%B8%E4%BD%8D

Mul stand for the amplitude of the signal, or how loud it is. The default mul of most UGens is 1, which means that the signal will oscillate between 1 and -1. This is a good default as anything bigger would cause clipping and distortion. A mul of 0 would be effectively silent, as if the volume knob was turned all the way down.
（velocity）
 0.0 - 1.0

*/
b = {840.0.rand};
d = {1.0.rand};
b.value;
a = {SinOsc.ar(b)};
x = a.play;
x.free;
x.stop;

XLine.ar(start: 1.0, end: 2.0, dur: 1.0, mul: 1.0, add: 0.0, doneAction: 0)

c = {SinOsc.ar(freq:880, mul:d)}.play;
c.stop;
s.scope;

/*
3.Ugen (Unit generator)
UGens represent calculations with signals. They are the basic building blocks of synth definitions on the server, and are used to generate or process both audio and control signals. The many subclasses of UGen are the client-side representations of unit generators, and are used to specify their parameters when constructing synth definitions

'ar' means make the instance audio rate. SuperCollider calculates audio in groups of samples, called blocks. Audio rate means that the UGen will calculate a value for each sample in the block.

'kr', which means control rate. This means calculate a single value for each block of samples. This can save a lot of computing power, and is fine for (you guessed it) signals which control other UGens, but it's not fine enough detail for synthesizing audio signals.

ir

*/
{ SinOsc.ar(MouseX.kr(40, 1000, 1), 0, MouseY.kr(0.2, 0.8, 1)) }.play;