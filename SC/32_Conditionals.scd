
s.options.sampleRate = 48000;
s.boot;

//Conditional Logic
//Reference: Control Structures
// they are methods/message: if如果, while当, for在……时, forBy除……之外 , do, switch, case, try, protect
//expr: boolean expression (to be evaluated)
//loop/iteration: while, for


//expr = expression
// if and while
(
var a = 10, z;
z = if(a < 500) { synth(\test1) } {  synth(\test2)  };
z.postln;
)

/*
data type:

integer
float
string
symbol
char
boolean  0 1

and
or
not

true = 1
false = 0
*/


(
var x;
if(x.isNil) { x = 99 };
x.postln;
)


(
i = 0;
while { i < 5 } { i = i + 1; "boing".postln };
)



/* C#
Operators
x = x + 10 ->  x += 10;
x = x  - 10 ->  x -= 10;
x = x  * 10 ->  x *= 10;
x = x / 10 ->  x /= 10;

x = x + 1 ->    ++x

*/
//do

[ 1, 2, "abc", (3@4) ].do { arg item, i; [i, item].postln; };

5.do { arg item; item.postln }; // iterates from zero to four

"you".do { arg item; item.postln }; // a String is a collection of characters

'they'.do { arg item; item.postln }; // a Symbol is a singular item

(8..20).do { arg item; item.postln }; // iterates from eight to twenty

(8,10..20).do { arg item; item.postln }; // iterates from eight to twenty, with stepsize two

Routine {
    var i = 10;
    while { i > 0 } {
        i.yield;
        i = i - 5.0.rand
    }
}.do { arg item; item.postln };  // 'do' applies to the Routine



//switch
(
var x = 1; //also try 1
switch(x, 0, { "hello" }, 1, { "goodbye" })
)
//Select

(
var x, z;
z = [0, 1, 1.1, 1.3, 1.5, 2];
switch (z.choose.postln,
    1,   { \no },
    1.1, { \wrong },
    1.3, { \wrong },
    1.5, { \wrong },
    2,   { \wrong },
    0,   { \true }
).postln;
)

for(3, 7) { arg i; i.postln };

forBy(0, 8, 2) { arg i; i.postln };
(
i = 0;
while { i < 5 } { i = i + 1; "boing".postln };
)





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
		 //如果
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








// check example file: ASA, SeminareMusical






































