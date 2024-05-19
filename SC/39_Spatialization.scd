s.options.sampleRate = 44100;
s.boot;




(
//basic setup
s = Server.local.boot;

s.doWhenBooted({
	SynthDef(\nicepoc, { |out = 0, freq = 440, amp = 0.1, dur = 0.3|
		Out.ar(out, SinOsc.ar(freq, mul:amp) * EnvGen.kr(
			Env.perc(0.05, 1), timeScale: dur, doneAction:2))
	}).add;
});
)

//mono, 1 channel:
(
p = Pbind(
	\degree, Pseq([0, 3, 5, 6, 7], 5),
	\dur, 0.2,
	\instrument, \nicepoc
).play;
)

p.stop;

//multiple mono;
//the melody gets played on the both channels, the second note in the pattern differs,
// so when listening to it, the space "spreads" out
(
p = Pbind(
	\degree, Pseq([0, [3,4], 5, 6, 7], 5),
	\out, [0, 1],
	\dur, 0.2,
	\instrument, \nicepoc
).play;
)

p.stop;


// 2 channel panners:
Pan2.ar(in, pos, level);
LinPan2.ar(in, pos, level);
Balance2.ar(left, right, pos, level);
Rotate2.ar(x, y, pos);

XFade2


//4-channel panner:
Pan4.ar(in, xpos, ypos, level);

//N-channel panner:

PanAz.ar(numChans, in, pos, level, width, orientation);

//spread M channels over a stereo field:
Splay.ar(inArray, spread, level, center, levelComp);

//spread M channels over N channels:
SplayAz.ar(numChans, inArray, spread, level, width, center, orientation, levelComp);




// single tap delay lines
DelayN.ar(in, madelaytime, delaytime, mul, add)
DelayL.ar(in, madelaytime, delaytime, mul, add)
DelayC.ar(in, madelaytime, delaytime, mul, add)

// allpass filters:
AllpassN.ar(in, maxdelaytime, delaytime, decaytime, mul, add)
AllpassL.ar(in, madelaytime, delaytime, decaytime, mul, add)
AllpassC.ar(in, madelaytime, delaytime, decaytime, mul, add)

// comb filters (delaylines with feedback):
CombN.ar (in, madelaytime, delaytime, decaytime, mul, add)
CombL.ar (in, madelaytime, delaytime, decaytime, mul, add)
CombC.ar(in, madelaytime, delaytime, decaytime, mul, add)

// buffer versions:
BufDelayN.ar(buf, in, delaytime, mul, add)
BufDelayL.ar (buf, in, delaytime, mul, add)
BufDelayC.ar(buf, in, delaytime, mul, add)
BufAllpassN.ar (buf, in, delaytime, decaytime, mul, add)
BufAllpassL.ar (buf, in, delaytime, decaytime, mul, add)
BufAllpassC.ar(buf, in, delaytime, decaytime, mul, add)
BufCombN.ar (buf, in, delaytime, decaytime, mul, add)
BufCombL.ar(buf, in, delaytime, decaytime, mul, add)
BufCombC.ar (buf, in, delaytime, decaytime, mul, add)

// special delay lines utilising PlayBuf:
Tap.ar (bufnum, numChannels, delaytime)
PingPong.ar(bufnum, inputArray, delayTime, feedback, rotate)

(
s = Server.local;
s.waitForBoot({

b = Buffer.alloc(s, 44100 * 2, 2);

SynthDef("help-PingPong", { |out = 0, bufnum = 0, feedback = 0.5, delayTime = 0.2|
    var left, right;
    left = Decay2.ar(Impulse.ar(0.7, 0.25), 0.01, 0.25,
        SinOsc.ar(SinOsc.kr(3.7,0,200,500)));
    right = Decay2.ar(Impulse.ar(0.5, 0.25), 0.01, 0.25,
        Resonz.ar(PinkNoise.ar(4), SinOsc.kr(2.7,0,1000,2500), 0.2));

    Out.ar(out ,
        PingPong.ar(bufnum, [left,right], delayTime, feedback, 1)
    )
}).play(s, [\out, 0, \bufnum, b.bufnum, \feedback, 0.5, \delayTime,0.1]);

})
)

b.free;



// Create a buffer.
b= Buffer.alloc(s, s.sampleRate, 1); //enough space for one second of mono audio


// Write to the Buffer with Bufwr, read using several taps and mix them together:
(
SynthDef(\helpTap, {|bufnum|
	var source, capture;
	source= Impulse.ar(1);
	capture= BufWr.ar(source, bufnum, Phasor.ar(0.1, 0, BufFrames.ir(bufnum), 1));
	Out.ar(0, Mix.new([1,0.95,0.94,0.93,0.8,0.4,0.4]*Tap.ar(bufnum, 1, [0.04,0.1,0.22,0.88,0.9,0.91,0.93])));
}).add;
)
x = Synth(\helpTap, [\bufnum, b.bufnum]);
x. free;


(// alternate source; use headphones to avoid feedback
SynthDef(\helpTap2, {|bufnum|
	var source, capture;
	source= SoundIn.ar(0);
	capture= BufWr.ar(source, bufnum, Phasor.ar(0, 1, 0,BufFrames.ir(bufnum), 1));
Out.ar(0, Mix.new([1,0.95,0.94,0.93,0.8,0.4,0.4]*Tap.ar(bufnum, 1, [0.04,
		0.1,0.22,0.88,0.9,0.91,0.93])));
}).add;
)
x = Synth(\helpTap2, [\bufnum, b.bufnum]);
x.free;

// free buffer:
b. free;

//https://zh.wikipedia.org/zh-cn/%E5%8D%B7%E7%A7%AF-------------------------------------------------


//The Convolution UGens and their arguments.

// convolving two signals with each other:
Convolution.ar( in, kernel, framesize, mul, add ) // kernel 核函数

// convolving one signal with a buffer:
Convolution2.ar( in, kernel, trigger, framesize, mul, add )

// as above with linear interpolation:
Convolution2L.ar(in, kernel, trigger, framesize, crossfade, mul, add)

// as above, with two buffers:
StereoConvolution2L.ar( in, kernelL, kernel, trigger, framesize, crossfade, mul, add)

// time based convolution (highly inefficient for audio rate)
Convolution3.ar(in, kernel, trigger, framesize, mul, add )
Convolution3.kr(in, kernel, trigger, framesize, mul, add )

// partitioned convolution
PartConv.ar(in, fftsize, irbufnum, mul, add)




//The Reverb UGens with their input arguments.-------------------------------

// one channel input:
FreeVerb.ar (in, mix, room, damp, mul, add)

// 2 channel input and output:
FreeVerb2.ar(in, in2, mix, room, damp, mul, add)

// stereo reverb
#left, right = GVerb.ar(in, roomsize, revtime, damping, inputbw, spread, drylevel, earlyreflevel, taillevel, maxroomsize, mul, add)


//HRTF--------------------------------------
//https://audioprogramming101.wordpress.com/2014/03/04/create-binaural-soundscapes-using-supercollider-and-hrtfs/

(

SynthDef (\binauralconvolver, {|out = 0, in = 0, bufL = 0, bufR = 1, t_trig= 0, amp = 1|
	Out.ar(out, StereoConvolution2L.ar(In.ar(in, 1), bufL, bufR, t_trig, 2048, 1,
amp)
// 2048 is the FIR size, 1 means that we crossfade over 1 block between buffers
);
}).add;
)

x = Synth.new(\binauralconvolver, [\bufL, ~HRTF.at(~sourceazi).at(~sourcelev)[0], \bufR, ~HRTF.at(~sourceazi).at(~sourcelev)[1]]);

~headtracker.action_({|azim,elev| x.setn(\bufL, ~HRTF.at(~source.azimuth - azim ).at(~source.elevation - elev ));});

~source.action_({|azim,elev| x.setn(\bufL, ~HRTF.at(~azim - ~headtracker.azimuth).at(~elev - ~headtracker.elevation)});



//2D and 3D VBAP speaker arrays.

// 5.1 array (subwoofer must be treated separately)
	VBAPSpeakerArray.new(2, [ -30, 30, 0, -110, 110 ]);

//16 channel partial dome
VBAPSpeakerArray.new(3, [[-22.5, 14.97], [22.5, 14.97], [-67.5, 14.97], [67.5, 14.97], [-112.5, 14.97], [112.5, 14.97], [-157.5, 14.97], [157.5, 14.97], [-45, 0], [45, 0], [-90, 0], [90, 01, [-135, 0], [135, 0], [0, 0], [180, 0]]);



//3D VBAP example.

a = VBAPSpeakerArray.new(3, [[-22.5, 14.97], [22.5, 14.97], [-67.5, 14.97], [67.5, 14.97], [-112.5, 14.97], [112.5, 14.97], [-157.5, 14.97], [157.5, 14.97], [-45, 0], [45, 0], [-90, 0], [90, 0], [-135,0], [135, 0], [0, 0], [180, 0]]); // zig zag partial dome
b = a.loadToBuffer; // send speaker config to the server


(
// pan around the circle up and down
x = {|azi = 0, ele = 0, spr = 10|
var source;
source = PinkNoise.ar(0.2);
VBAP.ar(16, source, b, LFSaw.kr(0.5, 0).range (-180, 180) * -1, SinOsc.kr(3, 0).range(0, 14.97), spr);
}.play;
)



// 3D encoding:
PanB.ar(in, azimuth, elevation, gain)
//2D encoding:
PanB2.kr(in, azimuth, gain)
// 2D encoding of a stereo signal:
BiPanB2.kr(inA, inB, azimuth, gain)
// decoding (2D):
DecodeB2.kr(numChans, w, x, y, orientation)

// rotating (in the horizontal plane):
Rotate2.kr(x, y, pos)

// From AmbisonicUGens in sc3-plugins:

//encoding (3D):
BFEncode1.ar(in, azimuth, elevation, rho, gain, wComp)
BFEncode2.ar(in, point_x, point_y, elevation, gain, wComp)

// encoding of a stereo signal (3D)
BFEncodeSter.ar(l, r, azimuth, width, elevation, rho, gain, wComp)
// decoding (3D):
BFDecode1.ar(w, x, y, z, azimuth, elevation, wComp, mul, add)

// manipulating (3D):
BFManipulate.ar(w, x, y, z, rotate, tilt, tumble)
// rotate is rotation around the z-axis, tilt around the x-axis, and tumble around the y-axis

{Array.fill(2, WhiteNoise.ar(0.1))}.play; // sounds like it comes from the center
{Array.fill(2, {WhiteNoise.ar(0.1)})}.play; // sounds wide

{LPF.ar(Array.fill(2, WhiteNoise.ar(0.8)), 300, 0.2)}.play;
{LPF.ar(Array.fill(2, {WhiteNoise.ar(0.8)}), 300, 0.2)}.play;





(
b = Buffer.alloc(s,2048,1);
c = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
d = Buffer.alloc(s,2048,1);
)

(
//make stereo from mono
// MouseX controls decorrelation
x = SynthDef("PV_DecorrelateStereo", { arg out=0, bufnum=0, bufnum2, soundBufnum=2;
 var in, chain, chain2;
 in = PlayBuf.ar(1, soundBufnum, BufRateScale.kr(soundBufnum), loop: 1);
 chain = FFT(bufnum, in);
 chain2 = PV_Copy(chain, bufnum2);
 chain = PV_Decorrelate([chain, chain2], 1,  MouseX.kr);
 Out.ar(out, 0.5 * IFFT(chain));
}).play(s,[\out, 0, \bufnum, b, \bufnum2, d, \soundBufnum, c]);
)

x.free; [b, c, d].do(_.free);



b = Buffer.read(s, "soundsla11wlk01.wav");
(
SynthDef("grain",{
arg i_out=0, i_sampbufnum, dur = 0.05, pointer, offset= 0.005, amp= 1.0, loop= 1;
var thisStart, thisDur, grain;
thisStart =pointer+ IRand(0, offset); // adds random time offset
grain= EnvGen.ar(Env.sine, 1.0, amp, 0.0, dur, 2) * PlayBuf.ar(1,i_sampbufnum, BufRateScale.ir(i_sampbufnum), 1, thisStart,loop);
OffsetOut.ar(i_out,grain); // use OffsetOut for precise sub-block timing
}).add;
)

(
X = {
var numGrains = 32; //approximate number of simultaneous grains
var numChannels = 2; // adjust for your setup
var dur = 0.05, durRand = 0.05, thisDur; var start, now;
var numGrainsRecip;
numGrainsRecip = numGrains.reciprocal; // save some divides by converting to reciprocal
start= Main.elapsedTime;
loop({
		now= Main.elapsedTime - start;
		thisDur = dur + durRand.rand;
        s.bind({Synth("grain", [i_out: numChannels.rand, i_sampbufnum: b, dur: thisDur, pointer: now* b.sampleRate, amp: numGrainsRecip]);
}); // send as a bundle for precise sub-block timing
(thisDur * numGrainsRecip).wait;
})
}.fork;
)

x.stop;
b.free;

