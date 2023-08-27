//Conditional Logic
//Reference: Control Structures
// they are methods/message: if如果, while当, for在……时, forBy除……之外 , do, switch, case, try, protect
//expr: boolean expression (to be evaluated)
//loop/iteration: while, for

// if and while
(
var a = 1, z;
z = if(a < 5) { 100 } { 200 };
z.postln;
)

(
var x;
if(x.isNil) { x = 99 };
x.postln;
)

(
i = 0;
while { i < 5 } { i = i + 1; "boing".postln };
)

(
(
 SynthDef("example7b", {arg out = 0, freq = 440, amp = 0.1,
       dur = 1, pan = 0;

     var blip, env, panner;

     env = EnvGen.kr(Env.triangle(dur, 1), doneAction:2);
     blip = Blip.ar(freq, env * 3);
     panner = Pan2.ar(blip, pan, env * amp);
     Out.ar(out, panner);
  }).load(s);
)

(
  Task({
     var freq, synth_dur, high_freq;

     high_freq = 800;
      //当                  那么
     while({high_freq > 0}, {

        freq = 200 + high_freq.rand;
		 如果
        if((freq >= 600), {
          synth_dur = 0.1 + 1.0.rand; //Random number from zero up to the receiver, exclusive.
        } , {// 否则
          if ((freq <= 400), {  //如果， 那么
           synth_dur = 1 + 5.0.rand;
          },{  //否则
           synth_dur = 0.1+ 2.0.rand;
          });
        });
        Synth(\example7b, [\out, 0, \amp, 0.1, \freq, freq,
            \dur, synth_dur, \pan, 0.8.rand2]);

        high_freq = high_freq - 50.rand;
        (0.01 + 0.4.rand).wait;
     });
  }).play;
)
)



for(3, 7) { arg i; i.postln };



// check example file: ASA, SeminareMusical






































