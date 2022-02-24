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

//16:29






































