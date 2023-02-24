s.options.sampleRate = 48000;
s.boot;
//Binary Operators 二进制算符
// .x   -> adverb
// reference:  Operators, J concepts in SC

play{GVerb.ar(VarSaw.ar(Duty.ar(1/5, 0, Dseq(x = [[4,4,5],[2,3,5,6]];flat(x*.x allTuples(x*.x x)*4).clump(2)++0)),0, 0.9)*LFPulse.ar(5), 99, 5)/5}

(
var freq;
z = [[4,4,5],[2,3,5,6]];
freq = z *.x z; //
freq = allTuples(freq);
freq = z *.x freq;
freq = freq * 4;
freq = freq.flat;
freq = freq.clump(2);
freq = freq ++ 0;



{
	var demand, sig;
	demand = Duty.kr(1/5, 0, Dseq(freq));
	sig = VarSaw.ar(demand, 0, 0.9);
	sig = sig * LFPulse.ar(5);
	sig = GVerb.ar(sig, 99, 5);
	sig = sig / 5;
}.play;

)

17**3 // 指数


100 + [1, 2, 3, 4, 5, 6, 7];
//binary operation with a number and an array is defined such that the operation is applied to the number and each item in the array resulting in a new array of the same size



[100, 200, 300] + [1, 2, 3, 4, 5, 6, 7];
//for an operation with two arrays, the default behavior is to apply the operation to corresponding pairs of items and if the sizes of the arrays are different wrap to the beginning of the short array and start over as many times as needed to accommodate the longer array



[100, 200, 300] +.s [1, 2, 3, 4, 5, 6, 7]; // short
// the shorter array determines the length of the result

[100, 200, 300] +.f [1, 2, 3, 4, 5, 6, 7];
// folding, so when we get to the end of the short array we bounce back and go the opposite direction bouncing back and forth as many times as needed to accommodate the long array

[100, 200, 300] +.t [1, 2, 3, 4, 5, 6, 7];
// table, the result is a multi-dimensional多维 array.
//so in this case an array containing three arrays,  each containing seven numbers and the operation is applied for every possible pair of values from the first and second array

[100, 200, 300] +.x [1, 2, 3, 4, 5, 6, 7]; //-----------------------
// cross,   almost the same as table, except it removes the inner brackets and the result is just one large array


//this syntax works for any binary operator with a symbolic representation like subtraction, division, modulo
[100, 200, 300] -.x [1, 2, 3, 4, 5, 6, 7];
[100, 200, 300] /.x [1, 2, 3, 4, 5, 6, 7];
[100, 200, 300] %.x [1, 2, 3, 4, 5, 6, 7]; //余数

lcm(6, 8);  // least common multiple  最小公倍数
//https://baike.baidu.com/item/%E6%9C%80%E5%B0%8F%E5%85%AC%E5%80%8D%E6%95%B0/6192375

[100, 200, 300] lcm:.x [1, 2, 3, 4, 5, 6, 7];
//same
[100, 200, 300].lcm([1, 2, 3, 4, 5, 6, 7], \x);




//---------------------------------------
//generate a list of all the midi notes on the 88 key piano keyboard that belong to the key of a minor  (and note numbers on the piano range from 21 to 108.)

Scale.minor.degrees;

(
f = (0, 12..96) +.x Scale.minor.degrees + 21;
f = f.reject({|n| n > 108});
)

//start with an array of a bunch of octave transpositions,  and cross add with the minor scale,  and then add 21 to start on the correct note 127 is higher than we need,  so we can use reject to iterate and remove anything greater than 108.




































