NetAddr.langPort;



s.boot;

(
SynthDef.new(\sine,{
arg freq=440,atk=0.005,rel=2.0,amp=0.1,
pan=0;
var sig,env;
atk =Rand(0.005,0.01);
rel =Rand(2.0,3.8);
amp =Rand(0.1,0.5);
pan =Rand(-0.8,0.8);
sig =SinOsc.ar(freq);
env =EnvGen.kr(Env.new([0,1,0],[atk,
rel],[1,-1]),doneAction:2);
sig =Pan2.ar(sig,pan,amp);
sig =sig*env;
Out.ar(0,sig*0.1);
}).add;
)


~syn1=(Synth.new(\sine,[\freq,293.664768]));


Synth.new(\sine);
(
OSCdef.new(\test, {arg msg;if(msg[1]==11,
~syn1)},'/trigger');
)

(
OSCFunc({arg msg;if(msg[1]==11,
~syn1)},'/trigger');
OSCFunc({arg msg;if(msg[1]==12,
{Synth.new(\sine,[\freq,391.995436])})},'/trigger', );
OSCFunc({arg msg;if(msg[1]==13,
{Synth.new(\sine,[\freq,466.163761])})},'/trigger');
OSCFunc({arg msg;if(msg[1]==14,
{Synth.new(\sine,[\freq,622.253967])})},'/trigger');
OSCFunc({arg msg;if(msg[1]==15,
{Synth.new(\sine,[\freq,698.456463])})},'/trigger');
OSCFunc({arg msg;if(msg[1]==16,
{Synth.new(\sine,[\freq,1174.659071])})},'/trigger');
)
f=NetAddr.new("127.0.0.1",1234);
f.sendMsg("/iannix/play",2);
f.sendMsg("/iannix/speed" , 1);
f.sendMsg("/iannix/rotate","0 60 -30");
--- 🕵️‍--------//OSCFunc({arg msg;if(msg[1]==11,   里面的11代表lanniX里面objects trigger的id   可以添加trigger 然后在代码添加OSCFunc({arg msg;if(msg[1]==XX,

-----🚴‍--//OSCFunc({arg msg;if(msg[1]==12,
//{Synth.new(\sine,[\freq,391.995436])})},'/trigger', ); 里面只能用Synth，不能全局变量~syn1,直接写一个声音进去也不行