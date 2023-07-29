
s.options.sampleRate = 48000;
s.boot;

//"debug mode" - post all incoming OSC messages

OSCFunc.trace(true);
OSCFunc.trace(false);

//sclang listens for OSC messages on port 57120 by default
NetAddr.langPort; //confirm receiving port


//create an instance of NetAddr for sending OSC to TouchOSC
~touchosc = NetAddr.new("192.168.178.22", 9000);

//app address->    https://hexler.net/touchosc
// download: touchosc editor  https://hexler.net/touchosc-mk1#downloads

//touchOSC need to be in the same network with your computor
//the incoming port is relevant if you want to actually send osc from the computer to touchosc

(
OSCdef.new(\listener, {
	arg msg;
	msg.postln;
	//code that does the thing we want to happen goes here
}, '/1/fader5', nil, 57120); // /1/fader5 ( a symbol, can be writing as '1/fader5') is the name from touchosc, can see from trace information
)

s.boot;

(
SynthDef.new(\tone, {
	var sig, env;
	env = Env.adsr.kr(0, \gate.kr(0));
	sig = LFTri.ar(\freq.kr(300));
	sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.2));
	sig = sig * env;
	Out.ar(\out.kr(0), sig);
}).add;
)

x = Synth.new(\tone, [\gate, 1]);
x.set(\gate, 0);

(
x = Synth.new(\tone, [\gate, 0]); // control the sound on and off by gate

OSCdef.new(\listener, {
	arg msg;
	x.set(\gate, msg[1]); //the address is at index 0 and the value is at index 1,  msg[1] to locate the value
}, '/1/push1', nil, 57120);
)

(
~scale = [0,12,24,36,48].collect({
	arg n;
	n + 35 + Scale.minorPentatonic.degrees
}).flatten;

~synths = ~scale.collect({
	arg note;
	Synth(\tone, [\freq, note.midicps]);
});


//multipush , nesting iteration
(1..5).do({
	arg row;
	(1..5).do({
		arg col;
		var index = (row-1) * 5 + (col-1);
		OSCdef.new(("multi"++row++col).asSymbol, { //the name of each oscdef   multi11, multi12...
			arg msg;
			~synths.at(index).set(\gate, msg[1])
		}, "/1/multipush1/" ++ row ++ "/" ++ col, nil, 57120);
	});    //each button has its own address, generating a unique address for each one of these 25 osc
});
)

1 1 --> 0
1 2 --> 1
...
2 1 --> 5
2 2 --> 6
...
5 5 --> 24


~synth[7].set(\gate,0);

"hello"++3++"goodbye"

s.defaultGroup.set(\gate, 0);

OSCdef.freeAll;
OSCFunc.trace(false);

//sending OSC messages to TouchOSC
~touchosc.sendMsg('/1/fader4', rrand(0.0,1.0))