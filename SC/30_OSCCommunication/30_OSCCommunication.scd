// OSC =  Open Sound Control
// Reference: OSC Communication
// https://opensoundcontrol.stanford.edu/spec-1_0.html



//"debug mode" - post all incoming OSC messages

OSCFunc.trace(true);
OSCFunc.trace(false);

// OSCfunc is  a class that allows you to respond to osc messages and this trace is a class method that allows us to go into debug mode and print everything that's coming in

//supercollider exists as this client application and the server application. and as long as the server is booted, these two are sort of constantly talking to each other

NetAddr.langPort;   // retrieve the current port SC is listening to
NetAddr.localAddr;   // retrieve the current IP and port



//rms = Root mean square or simply RMS watts refers to continuous power handling of a speaker or a subwoofer or how much continuous power an amplifier can output.

(
	s.waitForBoot{
		fork{
			~b1 = Buffer.read(s,"/Users/meiyanchen/Documents/Projects/told_hold/Bounces/Reversed Suitcase.aif", channels: [0]);
			~bus1 = Bus.control(s);
		    ~proc = NetAddr("127.0.0.1", 58945);

			SynthDef(\sampy, {
				arg buf = 0, kbs = 0;
				var sig, rms;
				sig = PlayBuf.ar(1, buf, loop:1);
				rms = Amplitude.kr(sig).ampdb.linlin(-60.0, 30.0, 0.0, 1.0); // linear amplitude zero to one and to the db scale. it's gonna convert from the linear 0 to 1 amp to a db scale. it gives more bounce to the visualizer
				Out.kr(kbs, rms);
				Out.ar(0, sig);
			}).add;

			OSCdef(\getamp, {
				~proc.sendMsg("/amp1", ~bus1.getSynchronous.asFloat);
			}, "/getamp"); // grab the data from that bus1 and send it out to processing

			0.1.wait;
			~s1 = Synth(\sampy, [\buf, ~b1, \kbus, ~bus1]);
		}
	}
)



~s1.free; 