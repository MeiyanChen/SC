s.boot;

//Buffer 是以用来保存样本音频的
//read--------------------------------------------------------

~b0 = Buffer.read(s,"/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Buffersound/1_kidlaugh.wav");


~b0.play; //听原本的音频

~b0.zero; //停止声音，但不消除声音在服务器上停留

~b0.read("/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Buffersound/1_kidlaugh.wav");

~b0.free; //消除音频停留在服务器上

Buffer.freeAll;


//


~b0 = Buffer.read(s,"/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Buffersound/1_kidlaugh.wav");
~b1 = Buffer.read(s,"/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Buffersound/2_raindrop.wav");
~b2 = Buffer.read(s,"/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Buffersound/3_waterpouring.wav");
~b3 = Buffer.read(s,"/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Buffersound/4_cryingchild.wav");

~b0.play;
~b1.play;
~b2.play;
~b3.play;

//Frames （帧） ->缓冲器（音频）的长度， 不同与sample样本 （按bit比特计算）The bit is the most basic unit of information in computing and digital communications.
~b0.numFrames;

//Channels
~b0.numChannels;

// numSamples = numFrames * numChannels

~b4 = Buffer.readChannel(s, "/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Buffersound/4_cryingchild.wav", channels:[1]);   //从双声道音频中，只读取单声道 0 左， 1 右

s.meter;

~b0.play;
~b4.play;

//Duration

~b2.duration; //按秒计算

//Buffer numbers (bufnums)  每个缓冲器（音频），在服务器上都会对应一个相应的整数，整数大小取决于执行先后顺序
~b0.bufnum;
~b1.bufnum;
~b2.bufnum;
~b3.bufnum;


//buffer sample rate  （https://en.wikipedia.org/wiki/44,100_Hz）
~b0.sampleRate;
s.sampleRate;

//summary
~b0.query; //可以提取以上所有音频的信息




//examples ---------------------------------------------------
//1.读取一个音频的部分内容  startFrame, numFrames
~b3.play;

~b3_part0 = Buffer.read(s,"/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Buffersound/4_cryingchild.wav", 0, s.sampleRate/2); // 0 -> startFrame,  s.sampleRate/2 -> numFrames

~b3_part0.play;

~b3.numFrames;

~b3_part1 = Buffer.read(s, "/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Buffersound/4_cryingchild.wav", 223555, ~b3.numFrames - 223556); // 随机数值

~b3_part1.play;


//2.同时读取多个音频

~bells = Array.new; //存储缓冲器（音频）为一个数列， 所有的音频都可以对应的索引提取

~folder = PathName.new("/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Buffersound/Bells/");
~folder.entries;

(
~folder.entries.do({
	arg path;
	~bells = ~bells.add(Buffer.read(s, path.fullPath));

});
)

~bells.at(0).play;
~bells.at(4).play;
~bells.at(7).play;
~bells.at(12).play;

~bells[12].play;

s.options.numBuffers;
s.options.numBuffers = 40000;


//UGens:  PlayBuf, BufRd------------------------------------------------------------

(
SynthDef.new(\playbuf_test, {
	arg amp = 1, out = 0, buf;
	var sig;
	sig = PlayBuf.ar(2, buf);
	sig = sig* amp;
	Out.ar(out, sig);
}).add;
)

Synth.new(\playbuf_test,[\buf, ~b0.bufnum]);
Synth.new(\playbuf_test,[\buf, ~b1.bufnum]);
Synth.new(\playbuf_test,[\buf, ~b2.bufnum]);
Synth.new(\playbuf_test,[\buf, ~b3.bufnum]);


//___- wrong 1
(
SynthDef.new(\playbuf_test, {
	arg amp = 1, out = 0, buf, chan = 2; //不能直接指定声道数量，因为音频声道不能直接随意改变
	var sig;
	sig = PlayBuf.ar(chan, buf);
	sig = sig* amp;
	Out.ar(out, sig);
}).add;
)


// wrong 2
(
SynthDef.new(\playbuf_test, {
	arg amp = 1, out = 0, buf;
	var sig;
	sig = PlayBuf.ar(1, buf); // 声道数量与音频实际声道数量不相符
	sig = sig* amp;
	Out.ar(out, sig);
}).add;
)



//

s.plotTree;


(
SynthDef.new(\playbuf_test, {
	arg amp = 1, out = 0, buf, rate = 1, da = 2;
	var sig;
	sig = PlayBuf.ar(2, buf, doneAction:da); //但音频播放完时，释放音频，以防占用cpu
	sig = sig* amp;
	Out.ar(out, sig);
}).add;
)

Synth.new(\playbuf_test,[\buf, ~b0.bufnum, \rate, 0.5]); //改变声音播放速度 大于1加速，小于1放慢

//-----------




~b0_96 = Buffer.read(s,"/Volumes/Meiyan_Chen/Teaching Materials/吴思齐/Buffersound/1_kidlaugh_96k.wav" );

~b0_96.query;
Synth.new(\playbuf_test,[\buf, ~b0_96.bufnum, \rate, 1.5]); // pitche and time shift


// browse -> UGens -> buffer -> info
(
SynthDef.new(\playbuf_test, {
	arg amp = 1, out = 0, buf, rate = 1, da = 2;
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf)*rate, doneAction:da); // 让音频按原速（样本率）播放
	sig = sig* amp;
	Out.ar(out, sig);
}).add;
)

Synth.new(\playbuf_test,[\buf, ~b0.bufnum, \rate, 1.5]);



//-----------// triger and startpos allows to specify a starting frame and give the option of jumping to that frame by sending a trigger

(
SynthDef.new(\playbuf_test, {
	arg amp = 1, out = 0, buf, rate = 1,t_trig= 1, start=0, da = 2;
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf)*rate, t_trig, start, doneAction:da);
	sig = sig* amp;
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\playbuf_test,[\buf, ~b0.bufnum, \start, s.sampleRate/2, \da, 0]); // half second after begining, and won't free itself until its gets end
x.set(\t_trig, 1); // jump to start position
x.free;

//------------

(
SynthDef.new(\playbuf_test, {
	arg amp = 1, out = 0, buf, rate = 1,t_trig= 1, start=0, loop = 0, da = 2; //loop 为1，音频会重复， 为0时，则只播放一次
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf)*rate, t_trig, start, doneAction:da);
	sig = sig* amp;
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\playbuf_test,[\buf, ~b3_part1.bufnum, \loop, 1]);
x.set(\loop, 0); //可以在播放时，改变参数
x.free;


Synth.new(\playbuf_test,[\buf, ~b0.bufnum, \rate, -1, \start, ~b0.numFrames - 2]); //反向播放， start at last frame, frame indices start with 0, starting at the last frame of buffer which play buffs queue to check its doneAction and that happens to be two. so when we instantiate the synth, it actually frees itself immediately. We can correct this by specifying the start position to be one frame earlier

12.midiratio; // converts a transposition in semitones into an equal tempered ratio, 往上8度
-12.midiratio;
7.midiratio; //5度

Synth.new(\playbuf_test,[\buf, ~bells[0].bufnum, \rate, -7.midiratio]); // 按半音改变音高
Synth.new(\playbuf_test,[\buf, ~bells[0].bufnum, \rate, -10.midiratio]);
Synth.new(\playbuf_test,[\buf, ~bells[0].bufnum, \rate, -13.midiratio]);
Synth.new(\playbuf_test,[\buf, ~bells[0].bufnum, \rate, -15.midiratio]);


//------------------------- 按组播放和调整音频

g = Group.new;

(
x = Synth.new(\playbuf_test,[\buf, ~b0.bufnum, \rate, 1.5, \loop, 1, \amp, 0.5, g]);
y = Synth.new(\playbuf_test,[\buf, ~b1.bufnum, \rate, 1.2, \loop, 1, \amp, 0.5, g]);
z = Synth.new(\playbuf_test,[\buf, ~b2.bufnum, \rate, 2.1, \loop, 1, \amp, 0.5, g]);
)

g.set(\rate, 0.5);

g.set(\buf, ~b3_part1.bufnum);

x.set(\rate, exprand(0.2,2,0));
y.set(\rate, exprand(0.2,2,0));
z.set(\rate, exprand(0.2,2,0));

g.set(\loop, 0); //停止循环
g.free;




//BufRd------------------------------

(
SynthDef.new(\bufrd_test,{
arg amp = 1, out = 0, buf;
var sig, ptr;
ptr = Line.ar(0, BufFrames.kr(buf)-1, BufDur.kr(buf), doneAction:2); //按原音频播放
sig = BufRd.ar(2, buf, ptr);
sig = sig* amp;
Out.ar(out, sig);
}).add;
)

Synth.new(\bufrd_test,[\buf, ~b2.bufnum]);




(
SynthDef.new(\bufrd_test,{
arg amp = 1, out = 0, buf, start, end;
var sig, ptr;
ptr = Line.ar(start, end, BufDur.kr(buf), doneAction:2); // line 不能循环播放
sig = BufRd.ar(2, buf, ptr);
sig = sig* amp;
Out.ar(out, sig);
}).add;
)

Synth.new(\bufrd_test,[\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1 ]);
Synth.new(\bufrd_test,[\buf, ~b2.bufnum, \start,~b2.numFrames-1,\end, 0]); //反向播放

//--------

(
SynthDef.new(\bufrd_loop,{
arg amp = 1, out = 0, buf, start, end;
var sig, ptr;
	ptr = Phaser.ar(0, BufRateScale.kr(buf)*rate, start, end);  // 可循环播放
sig = BufRd.ar(2, buf, ptr);
sig = sig* amp;
Out.ar(out, sig);
}).add;
)

Synth.new(\bufrd_loop,[\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1 ]);

x.set(\start, ~b2.numFrames/2, \end, ~b2.numFrames-1); //only read the second half of the file
x.set(\start, 2000, \end, ~b2.26000);
x.set(\rate, -3.midiratio);
x.free;

// 可尝试用sweep或 lFSaw

//---------------- 或其他ugens
(
SynthDef.new(\bufrd_sine,{
arg amp = 1, out = 0, buf, start, end, freq = 1;
var sig, ptr;
ptr = SinOsc.ar(freq, 3pi/2).range(start, end); //sine wave start at its lowest point
sig = BufRd.ar(2, buf, ptr);
sig = sig* amp;
Out.ar(out, sig);
}).add;
)

3pi/2;

x = Synth.new(\bufrd_sine,[\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1, \freq, 0.2 ]);

x.free;

//---------------------

(
SynthDef.new(\bufrd_noise,{
arg amp = 1, out = 0, buf, start, end, freq = 1;
var sig, ptr;
ptr = LFDNoise1.ar(freq).range(start, end);
sig = BufRd.ar(2, buf, ptr);
sig = sig* amp;
Out.ar(out, sig);
}).add;
)


Synth.new(\bufrd_noise,[\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1, \freq, 1]);


w= Synth.new(\bufrd_noise,[\buf, ~b0.bufnum, \start, 0, \end, ~b0.numFrames-1, \freq, 0.6, \amp. 0.5]);
x= Synth.new(\bufrd_noise,[\buf, ~b1.bufnum, \start, 0, \end, ~b1.numFrames-1, \freq, 0.8, \amp. 0.5]);
y= Synth.new(\bufrd_noise,[\buf, ~b2.bufnum, \start, 0, \end, ~b2.numFrames-1, \freq, 0.7, \amp. 0.5]);
z= Synth.new(\bufrd_noise,[\buf, ~b3.bufnum, \start, 0, \end, ~b3.numFrames-1, \freq, 0.5, \amp. 0.2]);

s.freeAll;

g.set(\freq, 200);


//RecordBuf
//BufWr





























