// Iteration a repeating process 使某块代码重复执行

// 搜索参考资料：Collections -> collection -> iteration
// iterate a collection of items

//do------------------------
//Iterate over the elements in order, calling the function for each element. The function is passed two arguments, the element and an index. //0, 1, 2 , 3 ,4....

[6, 4, 0.5, 10, 7].do{"hello".postln} ;// "do" always return its receiver


(
[6, 4, 0.5, 10, 7].do{
	arg item;
	item.squared.postln; //对排列数据进行指令

	}
)

(
[6, 4, 0.5, 10, 7].do{
	arg item, count;
	[count, item.squared].postln;    // 代码没有直接作用，只是执行并显示出来

	}
)

//collect-------------------------
(
x = Array.newClear(5);      //如果想要存储或再次修改执行过的内容，因此需要创造一个空的排列以保存之前的计算结果

[6, 4, 0.5, 10, 7].do{
	arg item, count;
	x[count] = item.squared; // 存储每一个计算后的排列数据在对应的索引
	}
)

x;


(
z = [6, 4, 0.5, 10, 7].collect{  // 可以直接存储数据
	arg item;
	item.squared;
	}
)

//or
z = [6, 4, 0.5, 10, 7].collect(_.squared);



[0, 1, 2, 3, 4].do{arg item;  item.postln};
5.do{arg item;  item.postln};


// do with UGens -----------------------------

//example 1

x = {VarSaw.ar(40!2, 0, 0.5)}.play;
//Saw


(
SynthDef.new(\iter, {
	var temp, sum;  // temp 来保存临时声音信号， sum为最后的声音信号
	sum = 0; // 如果不设定初始为0， sum为nil（nil为没有数值的特殊数值）sc 不会知道如何给nil执行加法
	10.do{                   //方程会被执行10次， 每一次迭代，出现一次频率稍有不同的（在40hz左右上下浮动）varsaw的声音信号
		temp = VarSaw.ar(
			40 * {Rand(0.99, 1.02)}!2,
			0,  // {Rand(0.0, 1.0)}!2
			0.05
		);
		sum = sum + temp;    //在最后累计10个不同的声音信号在一起执行
	};

	sum = sum * 0.05; // 将累计信号弱化，以防破音
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter); //执行后，会在开始听到一个小的爆破音， 这是因为在执行时每一个varsaw的相位（phase）都是相同的
x.free;


(
SynthDef.new(\iter, {
	arg freq = 40; //可以随意调整音高
	var temp, sum, env;
	sum = 0;
	env = EnvGen.kr(
		Env.perc(0.01, 5, 1 , -2),    //让声音在特定时间内停止
		doneAction:2
	);
	10.do{
		temp = VarSaw.ar(
			freq * {Rand(0.99, 1.02)}!2,
			 {Rand(0.0, 1.0)}!2,  //因此可以使phase随机化
			{ExpRand(0.005, 0.05)}!2     //duty cycle
		);
		sum = sum + temp;
	};

	sum = sum * 0.05 * env;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter, [\freq, 400]);
x = Synth.new(\iter, [\freq, 300]);
x = Synth.new(\iter, [\freq, 200]);
x = Synth.new(\iter, [\freq, 100]);

//freq to midi:   https://musicinformationretrieval.com/midi_conversion_table.html

x = Synth.new(\iter, [\freq, 66.midicps]);
x = Synth.new(\iter, [\freq, 73.midicps]);
x = Synth.new(\iter, [\freq, 80.midicps]);
x = Synth.new(\iter, [\freq, 75.midicps]);


(
[53, 59, 63, 69].do{
	arg midinote;
	Synth.new(\iter, [\freq, midinote.midicps])
}
)
// 不建议用do来同时创建多个ugen，因为如果用当声音信号过于复杂时，会在执行过程中漏掉信号样本

// example 2 ------------------------------
//eg 2.1  泛音
(
SynthDef.new(\iter2,{
	arg freq = 200;
	var temp, sum;
	sum = 0;
	10.do{
		arg count;
		temp = SinOsc.ar(freq * (count + 1));   // 将索引计算植入声音信号中， count从0开始，freq不能为0，因此需要+1
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter2);
x = {Blip.ar(200, 10, 0.5)}.play; //与对象blip发出的声音信号是相同的
x.free;

//eg 2.2

(
SynthDef.new(\iter2,{
	arg freq = 200;
	var temp, sum;
	sum = 0;
	10.do{
		arg count;
		temp = SinOsc.ar(freq *
			(count + 1)*
			LFNoise1.kr({Rand(0.5, 0.2)}!2).range(0.98, 1.02)  //受lfnoise的影响，并使开出两个独立的通道
		);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

//eg 2.3
(
SynthDef.new(\iter2,{
	arg freq = 200;
	var temp, sum;
	sum = 0;
	10.do{
		arg count;
		temp = SinOsc.ar(freq *
			(count + 1)*
			LFNoise1.kr({Rand(0.5, 0.2)}!2).range(0.98, 1.02)   //对频率的影响
		);
		temp = temp* LFNoise1.kr({Rand(0.5, 8)}!2).range(0.01, 1); //对声音信号的影响
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter2);
x.set(\freq, 100);
x.free;

//eg 2.4

(
SynthDef.new(\iter2,{
	arg freq = 200, dev = 1.02;  //Deviation 离差
	var temp, sum;
	sum = 0;
	10.do{
		arg count;
		temp = SinOsc.ar(freq *
			(count + 1)*
			LFNoise1.kr({Rand(0.5, 0.2)}!2).range(dev.reciprocal, dev) // reciprocal倒数
		);
		temp = temp* LFNoise1.kr({Rand(0.5, 8)}!2).range(0.01, 1);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter2);
x.set(\dev, 1.05);
x.free;


//eg 2.5  no iteration

(
SynthDef.new(\iter2,{
	arg freq = 200, dev = 1.02, num = 10; //  receiver of "do"不再是整数值， 而是class: control-> not a collection ， 为ugen中自动生成的一个参数， 因此只会计算1次
	var temp, sum;
	sum = 0;
	num.do{
		arg count;
		temp = SinOsc.ar(freq *
			(count + 1)*
			LFNoise1.kr({Rand(0.5, 0.2)}!2).range(dev.reciprocal, dev)
		);
		temp = temp* LFNoise1.kr({Rand(0.5, 8)}!2).range(0.01, 1);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter2);
x.set(\num, 5.4);
x.free;