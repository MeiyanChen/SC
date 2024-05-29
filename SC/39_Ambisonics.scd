/*Basic Theory-------------------------------
//Ambisonic  sound has applications in virtual reality, gaming,  and pretty much any situation where immersive  sound is valuable. One thing that makes this technique particularly unique and beneficial  is the fact that spatial information is encoded  into the Ambisonic signal itself, which means it's  theoretically possible to reproduce a soundfield on any type of loudspeaker system, from basic  stereo to massive multichannel speaker systems,  and everything in between. Generally, more  speakers means better spatial accuracy, but even if you're only working in stereo or on headphones,  you can still use Ambisonic techniques to achieve good results, and losses to the integrity of  the soundfield are usually pretty manageable.

m1. recording from Cardioid microphone -> output from stero loudspeaker
To capture a sense of width in a recording, a  common approach is to set up two cardioid mics with an angle of about 90 degrees between them.  One mic is focused on the left side, and the other on the right, and if these two signals are then  discretely reproduced on a pair of loudspeakers,  and we're sitting in the sweet spot, the result  is what's called a stereo image, which provides a listening experience that's more spacious and  realistic compared to what we'd get if we had just recorded the ensemble with only one microphone.

m2. recording from omni microphone -> output from stero loudspeaker
There are lots of variations on this technique,
but there's one in particular called Mid-Side  recording, which is fundamentally different. A Mid-Side recording involves two microphones,  the "Mid" is a central mic pointing forward with an omnidirectional pattern,( this could be cardioid but I'm making it omni for consistency with Ambisonics.) The "Side" is a bidirectional  mic, placed as close as possible to the omni, and positioned 90 degrees off-axis. So, the  omni is equally sensitive in all directions,  and the bidirectional is minimally sensitive to  sounds in the center, but increasingly sensitive to sounds originating from the far left and  right. And, it's important to recognize that a sound from the left will influence the diaphragm  of the bidirectional mic in some specific way, producing some specific signal, but the same sound  from the opposite side influences the diaphragm in the opposite way, producing the same signal, but  with an inverted polarity. So we conceptualize one half of the Side mic as being  positive, and the other, negative. So, we record, and we end up with two signals.  M from the omni, S from the bidirectional.

Decode/Matrix : To produce a stereo image, we need to convert from  Mid-Side to a left-right format using a process called matrixing or decoding

M + S, M - S
This result represents our left and right signals,  which produce a stereo image with a clear  sense of space and width when played back

the simplest type of Ambisonic signal is basically Mid-Side  recording in three dimensions instead of just one. The theoretical microphone setup would be an  omnidirectional mic in the middle of the space, and three bidirectional mics, angled  along each of the three axes, and in fact,  this Ambisonic logo on the Wikipedia page is  supposed to represent a top-down projection  of this microphone configuration. We call the  omni signal W, the axial signals are called X,  Y, and Z. And, collectively, this four channel  signal constitutes what’s called a first-order Ambisonic B-format signal, and it contains  all the information we need to reproduce a three-dimensional soundfield, we just need to  apply some decoding process that's appropriate for the number of speakers being used for  reproduction, and where those speakers are   relative to the listener. And, in many cases, this just boils down to matrix multiplication.

*/

//Install ATK ----------------------------------------
// download git  // terminal -> git version

Quarks.install("https://github.com/ambisonictoolkit/atk-sc3.git");

// recompile class library

// File -> Open user support directory

Atk.downloadKernels;
Atk.downloadMatrices;
Atk.downloadSounds;

Atk.userSupportDir;

/*Basics of the ATK Workflow-----------------------------
// search text: ABCs     // textbook

//encoding 编码 -> transforming 转换 -> decoding 解码
Encoding is the process of creating an Ambisonic B-format  signal, which could be virtually synthesized from mono or stereo recordings, or better yet,  directly created by recording with one of the many commercially available Ambisonic microphones out there.

Transforming refers to manipulations of the soundfield itself, achieved by applying  mathematical calculations to a B-format signal. Transformations include things like rotating the  soundfield, or focusing the soundfield toward a  point in space.

Decoding typically means converting from B-format to a more conventional
multichannel signal that contains individual feeds for some specific loudspeaker setup.

----------------------------
FOA -> First Order Ambisonics  一阶
which is a historically-informed collection  of utilities based on classic Ambisonic tools,  like this NRDC Ambisonic Decoder from the late 70s and many others.

HOA -> High Order Ambisonics 高阶
which represents a more modern approach to Ambisonics, capable of producing higher-order  soundfields, which essentially means capturing spatial information at a higher resolution  and with more precision.
--------------------------

In the FOA, the encoding process often begins  with FoaEncoderMatrix or FoaEncoderKernel. FoaEncoderMatrix uses matrix multiplication,
FoaEncoderKernel uses a frequency-domain multiplication process called convolution.

Common matrix creation  methods include things like newDirection,  newDirections, newStereo, newOmni.
Kernel options include newSpread,  newDiffuse and newSuper.

Regardless of whether  we choose a matrix-based or kernel-based encoder, the encoder itself is a static object

FoaEncode is the UGen that actually applies the encoder and calculates the Ambisonic signal.

Alternatively, in the specific case of converting from monophonic to B-format, we can use  FoaPanB, whose main advantage is the fact  that the directional encoding information is  dynamic, and can be modulated by other UGens.

FOA transformation UGens include FoaRotate, Tilt and Tumble for axial rotation.

FoaPush, Focus, Zoom, and Dominate, for various flavors of distorting or warping the soundfield in a particular direction.

For FOA decoding, we have a similar pair  of options with FoaDecoderMatrix and
FoaDecoderKernel.

Matrix options include  newStereo, newQuad, newPanto, newPeri, for pantophonic and periphoric decodin.
Kernel options include newUHJ for stereo decoding,
newListen and newCIPIC for binaural  decoding.

FoaDecode is the UGen that applies one of these decoders in order to calculate the output signal.
--------------------
HOA
For encoding, there are no kernel-based  options, so HoaMatrixEncoder is pretty much the
primary choice, methods include newDirection,  newDirections, and others.
HoaEncodeMatrix is the UGen that calculates the B-format signal,  basically the HOA equivalent of FoaEncode.
For  the specific case of encoding from monophonic to  B-format, we can use the UGen HoaEncodeDirection, which is equivalent to FoaPanB, and its  directional parameters can similarly be modulated.

Many transformations that exist in the FOA also  exist in the HOA, including HoaRotate, Tilt,  and Tumble, for axial rotation. and HoaFocus,  Zoom, and Dominate for directional distortion.
HoaMatrixDecoder is used to generate decoder  objects, creation methods include newProjection,  newModeMatch, newDirections

HoaDecodeMatrix  is the UGen that performs the signal  calculation, equivalent to FoaDecode.

A couple specific methods worth mentioning,  newHoa1 is an FOA transcoder creation method
that lets us convert between  FOA and HOA in either direction,  and newFormat is an HOA transcoder  method that provides the same ability.

there's a couple of fun utility  classes, like FoaXformDisplay and TDesign,
both of which can be helpful in visualizing  soundfields and their transformations.

FoaXformDisplay is tailored to the FOA toolset*/

// basic FOA examples-----------------------

s.options.sampleRate = 48000;

(
s.options.numOutputBusChannels_(24);  //expand the number  of hardware output channels
s.options.numWireBufs_(512);
s.boot;
)

b = Buffer.read(s,"/Users/meiyanchen/Documents/Max 8/Library/SoundSample/Advanced Orchestra/Bells/10 BL GLISDN/BL GLDN   -L.aif");
b.play;

// Encoding
~enc = FoaEncoderMatrix.newDirection(theta: 45.degrad, phi:0); //a simple  option that statically encodes the monophonic source as what's called a planewave平面波, originating  from an arbitrary direction in the soundfield.     this sound 45 degrees left  of center, with no elevation.

 /* Azimuth angle方位角 / Elevation angle仰角:
The convention is that X is the depth axis,  with forward being the positive  direction. Y is the width axis, with the positive direction going to the left,  and Z is height, with the positive direction going up.
Azimuth is the rotational angle on the  horizontal plane, and by convention,  0 degrees is straight ahead. Positive  angular rotation goes counter-clockwise,  so 45 degrees is halfway between front and left,  - 45 is halfway between front and right,  90 is left, -90 is right, + or - 180 is directly behind. A 0 degree  elevation is on the horizon, neither up nor down, an elevation of 45 degrees is halfway between horizontal and vertical, 90 degrees is  straight up, and negative 90 is straight down.*/

/*PS: the ATK expects all angular measurements in  radians弧度制, so if you prefer to think with degrees角度,  just make sure to use "degrad" to convert from  degrees to radians before supplying values to  ATK objects. You don't need to do this with  zero, because zero degrees equals zero radians.*/

//Decoding
~dec = FoaDecoderMatrix.newStereo(angle: 110.degrad/2, pattern:0.5); //a simple stereo decoder. This is basically  a simulation of recording the soundfield  using a virtual stereo microphone pair.

~dec.matrix;
// the "matrix" method returns the actual matrix used in the multiplication that  produces a stereo signal from the B-format  signal
~dec.matrix.round(0.01); //round these floats to the nearest hundredths place so they don't  take up as much space in the post window.
~dec.matrix.flop.round(0.01);   // what comes out is a  1-by-2 matrix that contains the two signals

/*
 the decoder matrix has four rows,  representing coefficients to be multiplied  by W, X, Y and Z. The Z coefficients are zero because the decoder represents two microphones  that are flat and on the horizontal plane, but when using FOA tools and everything  is contained within the horizontal plane,   the ATK just drops the Z coefficients entirely  for reasons related to DSP efficiency.
*/

~enc = FoaEncoderMatrix.newOmni;
~enc = FoaEncoderMatrix.newDirection(theta: 135.degrad, phi:0);
~enc = FoaEncoderMatrix.newStereo(angle: 110.degrad/2, pattern: 3 - sqrt(3)/2);


(
SynthDef(\ambi,{
	var sig;
	sig = PlayBuf.ar(1, b, BufRateScale.ir(b), loop:1); // PlayBuf will generate the  initial monophonic source
	//sig.numChannels.postln;
	sig = FoaEncode.ar(sig, ~enc); // encode the source
	sig = FoaDecode.ar(sig, ~dec); // decode the source
	Out.ar(0, sig);
}).play;
)
//So, just to be clear, immediately after  PlayBuf, sig is a normal, run-of-the-mill  monophonic signal, just one channel. After  encoding, sig is a first-order Ambisonic  B-format signal, which has four channels, WXYZ,  carrying full-sphere spatial information. After  decoding, sig becomes a stereo signal, which  represents the two channels we'd capture if  we were to set up a pair of cardioids  into the middle of this soundfield,   as specified in the decoder.



(
SynthDef(\ambi,{
	var sig;
	azim = LFSaw.kr(1/12).bipolar(180);
	sig = PlayBuf.ar(1, b, BufRateScale.ir(b), loop:1);
	sig = FoaEncode.ar(sig, ~enc);
	sig = FoaRotate.ar(sig, azim.degrad);
	FoaThetaPhiA.ar(sig).raddeg.poll;
	sig = FoaDecode.ar(sig, ~dec);
	Out.ar(0, sig);
}).play;
)



(
SynthDef(\ambi,{
	var sig, azim;
	azim = LFSaw.kr(1/12).bipolar(180).poll;
	sig = PlayBuf.ar(1, b, BufRateScale.ir(b), loop:1);
	sig = FoaPanB.ar(sig, azim.degrad, 0);
    sig = FoaDecode.ar(sig, ~dec);
	Out.ar(0, sig);
}).play;
)


(
SynthDef(\ambi,{
	var sig, azim;
	push = SinOsc.kr(1/8, 3pi/2).unipolar(pi/4).poll;
	sig = PlayBuf.ar(1, b, BufRateScale.ir(b), loop:1);
	sig = FoaEncode.ar(sig, ~enc);
	sig = FoaPush.ar(sig, push, 45.degrad, 0);
	sig = FoaRotate.ar(sig, azim.degrad);
    sig = FoaDecode.ar(sig, ~dec);
	Out.ar(0, sig);
}).play;
)


(
~enc = FoaEncodeMatrix.newDirections(
	{[rrand(-pi, pi), rrand(-pi/2, pi/2)]} ! 24
)
)


(
SynthDef(\ambi,{
	var sig, azim;
	push = Dust.ar(20 ! 24);
	sig = Decay.ar(sig, 0.01);
	sig = BPF.ar(sig, {ExpRand(100, 10000).round(50)} ! 24, 0.003, 10);
	sig = FoaEncode.ar(sig, ~enc);
	sig = FoaRTT.ar(
		in: sig,
		rotAngle:LFNoise2.kr(0.5).bipolar(pi),
		tilAngle:LFNoise2.kr(0.5).bipolar(pi),
		tumAngle:LFNoise2.kr(0.5).bipolar(pi),
	)
    sig = FoaDecode.ar(sig, ~dec);
	Out.ar(0, sig);
}).play;
)


~enc = FoaEncodeKernel.newSpread(6, 2048);
~dec = FoaDecodeKernel.newListen(1002);



(
SynthDef(\ambi,{
	var sig, azim;
	push = SinOsc.kr(1/8, 3pi/2).unipolar(pi/4).poll;
	sig = PlayBuf.ar(1, b, BufRateScale.ir(b), loop:1);
	sig = FoaEncode.ar(sig, ~enc);
	sig = FoaPush.ar(sig, pi/3, 0, 0);
	sig = FoaRotate.ar(sig, azim.degrad);
    sig = FoaDecode.ar(sig, ~dec);
	Out.ar(0, sig);
}).play;
)


// decoding FOA for surround systems

~dec = FoaDecoderMatrix.newPanto(4, 'flat', 'energy');

~dec.directions.raddeg;

~sig = [\a, \b, \c, \d];
~sig = ~sig[[0, 3, 1, 2]];



~dec = FoaDecoderMatrix.newPeri(4, 35.degrad, 'flat', 'energy');
~dec.directions.raddeg;

(
SynthDef(\ambi,{
	var sig, azim;
	azim = LFSaw.kr(1/12).bipolar(180).poll;
	sig = PlayBuf.ar(1, b, BufRateScale.ir(b), loop:1);
	sig = FoaPanB.ar(sig, azim.degrad, 0);
	sig = FoaTumble.ar(sig, 20.degrad);
    sig = FoaDecode.ar(sig, ~dec);
	Out.ar(0, sig);
}).play;
)


//HOA examples

~enc = HoaMatrixEncoder.newDirection(0, 0, \basic, 3);

AtkHoa.defaultOrder;
AtkHoa.setDefaultOrder(3);
~enc = HoaMatrixEncoder.newDirection(0, 0, \basic);
~enc.order;




(
~enc = HoaMatrixEncoder.newDirection(0, 0, \basic, 3);
~dec = HoaMatrixDecoder.newModeMatch(
	directions: [
		[36, 54], [108, 54], [108, 54], [-108, 54], [-36, 54],
		[36, 18], [108, 18], [108, 18], [-108, 18], [-36, 18],
		[0, -18], [72, -18], [144, -18], [-144, -18],[-72, -18],
		[0, -54], [72, -54], [144, -54], [-144, -54], [-72, -54],
	].degrad,
	beamShape: \energy,
	match: \rms
);
)

~dec = HoaDecoderMatrix.newDirections([65, -65].degrad, \controlled, \beam);

(
SynthDef(\ambi,{
	var sig, azim;
	sig = PlayBuf.ar(1, b, BufRateScale.ir(b), loop:1);
	sig = HoaEncodeMatrix.ar(sig, ~enc);
	sig = HoaRTT.ar(
		in: sig,
		rotate:LFNoise2.kr(0.5).bipolar(pi),
		tilt:LFNoise2.kr(0.5).bipolar(pi),
		tumble:LFNoise2.kr(0.5).bipolar(pi),
	);
    sig = HoaDecodeMatrix.ar(sig, ~dec);
	Out.ar(0, sig);
}).play;
)


(
SynthDef(\ambi,{
	var sig, azim;
	sig = PlayBuf.ar(1, b, BufRateScale.ir(b), loop:1);
	sig = HPF.ar(sig, 20);
	sig = HoaEncodeMatrix.ar(
		in: sig,
		theta:LFNoise2.kr(0.5).bipolar(pi),
		phi:LFNoise2.kr(0.5).bipolar(pi/2),
		radius: MouseX.kr(0.3, 1.5).max(0.3).poll;
	);
    sig = HoaDecodeMatrix.ar(sig, ~dec);
	Out.ar(0, sig);
}).play;
)


//HOA -> FOA conversion

AtkFoa.defaultOrder;
AtkHoa.defaultOrder;

// FOA
'fuma' // WXYZ

// HOA
'acn' // WYZX

AtkFoa.format;
AtkHoa.format;



AtkFoa.refRadius;
AtkHoa.refRadius;



(
~hoaToFoa = FoaEncoderMatrix.newHoa1(\acn. \n3d);
~dec = FoaDecoderMatrix.newStereo(angle: 110.degrad/2, pattern: 3 - sqrt(2) / 2);
)


(0..9).keep(4)


(
SynthDef(\ambi,{
	var sig;
	sig = PlayBuf.ar(1, b, BufRateScale.ir(b), loop:1);
	sig = HoaEncodeMatrix.ar(
		in: sig,
		theta:LFSaw.kr(1/12).bipolar(pi),
		phi:0,
		radius: 1.5;
	);
	sig = sig.keep(4);
	Out.ar(0, sig);
}).play;
)









































































