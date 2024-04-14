//In many situations, duration and musical pitch are inseparably linked.If we reduce playback speed to two-thirds,  the duration of the sample increases,   but pitch is also affected. This happens because  pitch is a perceptual experience based primarily on frequency, and frequency is just a measure of  vibrational cycles per second.

//So, if we stretch the sample, cycles get longer, and therefore frequency and our sense of pitch decrease. But, we can unlink these two parameters  using the Fast Fourier Transform, or FFT,   to perform a spectral analysis and resynthesis of  a sound, allowing us to do phase vocoder things  like pitch-neutral, time-stretching and spectral freezing.

//Specifically, we'll use PV_PlayBuf and   PV_RecordBuf, these are two UGens that are  part of the SC3-plugins extension package,   which does need to be downloaded and installed  separately.

//These UGens behave a lot like  regular RecordBuf and PlayBuf, but the buffer they use contains FFT analysis data instead of data that directly represents the waveform.


s.boot;

b = Buffer.read(s, );

{PlayBuf.ar(2, b, rate:2/3)}.play;


//The FFT size is the number of samples in one analysis window, it has to be  a power of two. For time-stretching applications,  a relatively high value like 8192 usually  works well, but you can drop down to 4096   or 2048 and it'll probably still sound
//the hop size, means analysis windows overlap by a factor  of four which helps produce a smooth resynthesis.
//for the windowing envelope, 0 is a  sine window, 1 is a Hann window, slightly different but both reasonable choice.

(
~fftsize = 8182;
~hop = 0.25;  //中继段
~win = 0;
)



// allocate a buffer  that will hold the analysis data. The correct size for this buffer depends on the  duration of the original sample and also on the FFT parameters we chose, so we're gonna  apply 'calcPVRecSize' to the buffer duration,  and also provide the FFT size and hop size.

f = {Buffer.alloc(s, b.duration.calcPVRecSize(~fftsize, ~hop))} ! 2;

b.numChannels;


// two UGen functions, one with  PV_RecordBuf to analyze and record the FFT data, and the other with PV_PlayBuf to read and  resynthesize the audio signal from the data.
(
{
	var sig, chain, localbuf;
	sig = PlayBuf.ar(2, b, BufRateScale.kr(b), doneAction:2); //generating  an audio signal of the original sample
	localbuf = { LocalBuf.new(~fftsize)} ! 2; //LocalBuf provides space for the FFT class to actually perform the calculations
	chain = FFT(localbuf, sig, ~hop, ~win);
	chain = PV_RecordBuf(chain, f, run:1, hop: ~hop, wintype: ~win); // PV_RecordBuf records the analysis data into f
	0; // make sure the output is silent
}.play;
)


//If we plot f, we can see there's data, and  it does not directly represent the waveform, but instead indirectly represents  it as spectral analysis data.

f.do(_.plot(minval:0, maxval:100));


//In our second function, another pair of LocalBufs for FFT calculation, PV_PlayBuf reads the data from f, we include a rate argument for real-time  control, and IFFT is the inverse operation that  resynthesizes a waveform from the data, producing  a signal we can actually send to our speakers.

(
x = {
	var sig, chain, localbuf;
	localbuf = {LocalBuf, f, \rate.kr(1), loop:1};
	sig = IFFT(chain, ~win);
}.play;
)

x.set(\rate, 0); //Zero creates a spectral freeze effect

x.set(\rate, 1/10); //positive values that are close to zero will  creep slowly through the file, producing a smeared and dreamy effect

x.set(\rate, -2/3); //negative  numbers will play through the file backwards.

x.release(2);