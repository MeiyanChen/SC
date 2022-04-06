// GUI => Graphical user interface
//参考资料：Introduction to GUI
//Examples -> GUI examples

w = Window.new; // 不可见
w.front; // 将窗口显现出来
w.alwaysOnTop = true; // 使窗口始终前置
//w.alwaysOnTop_(false);
w.alwaysOnTop_(true); //可以连续使用多个method在一条代码中  // 参考资料：Syntax Shortcuts  (calling an instance variable setter method)

w.close;//关闭后，窗口无法重启，除非重新执行窗口代码


(
w = Window.new
.front
.alwaysOnTop_(true);
)

// what is Qwindow?
// List of GUI classes

GUI.current; // 显示正在使用的GUI kit(配套元件)， 因此只能使用这一类的配套元件/对象
GUI.cocoa;

(
w = SCWindow.new   // error  // 因此永远使用generic（通用）类名， supercollider会自行分配系统类别
.front
.alwaysOnTop_(true);
)

w.close;   // 只适用与最近创建的窗口
Window.closeAll;

//size and placement 尺寸和位置------------------------------------------------------------

w.bounds; //指示尺寸和位置
w.bounds_(Rect.new(1000, 400, 200, 200)); // Rect => Rectangle 长方形  （x position, y position, width, height）measured in pixels
//一个画素通常被视为影像的最小的完整取样。用来表示一幅影像的画素越多，结果更接近原始的影像。
w.bounds_(Rect.new(0, 0, 200, 200)); //x 为 0表示最左， y 为 0表示最下

(
w = Window.new("gui", Rect.new(750, 50, 500, 200))
.front
.alwaysOnTop_(true);
)

Window.screenBounds;  //屏幕的窗口大小
Window.screenBounds.height;  //屏幕高度

(
w = Window.new("gui", Rect.new(
	Window.screenBounds.width/2,  //左下角为中心
	Window.screenBounds.height/2,
	200,
	200
))
.front
.alwaysOnTop_(true);
)

(
w = Window.new("gui", Rect.new(
	Window.screenBounds.width/2 -100,  //整个窗口为中心
	Window.screenBounds.height/2 -100,
	200,
	200
))
.front
.alwaysOnTop_(true);
)

//其他功能-------------------------------------------------
// View is the parent class of all gui objects including knobs，sliders, buttons, menus, any visile element is a subclass of view, except for window

(
Window.closeAll;
w = Window.new("gui", Rect.new(750, 50, 500, 200))
.front
.alwaysOnTop_(true);

~slider = Slider.new(w.view, Rect.new(20, 20, 150, 30) )  // x 为 0表示最左， y 为 0表示最上
)

w.view; // 已创建画面

~slider.parent; // returns the instance of the parent view -> the top view that occupies our window 母窗口

w.view.children; // returns an arry containing all the views have been placed on it  子窗口

//children is a convenient way to address every view within a given space rather than adress them all individually

~slider.visible_(true);
~slider.visible_(false); //隐藏

~slider.bounds_(Rect.new(40, 40, 200, 20)); //改变slider尺寸和位置
~slider.enabld_(true); //决定用户是否能使用slider
~slider.enabled_(false);
~slider.remove; //消除



w.close;

//不同的编程句法 ---------------
(
Window.closeAll;
w = Window("gui", Rect(750, 50, 500, 200))      //可以略写new method， 系统会默认该method
.front
.alwaysOnTop_(true);

~slider = Slider(w, Rect(20, 20, 150, 30) )  //但涉及到母窗口时， 可省略 .view
)



//get （收获) and set(设置) ->//https://www.w3schools.com/cs/cs_properties.php
~slider.value; // get
~slider.value_(0.8); // set

// sliders and other number based objects have a range of 0 to 1



~slider.action; //no action is performed
~slider.action_({"I am a slider".postln}); // a function that is evaluated whenever the user interacts with the object 每次移动时， 方程都会被执行




(
~slider.action_({
	arg obj;  // obj -> slider
	obj.value.postln;
});
)


~slider.value_(rrand(0.0, 1.0)); // only gets per sets the value, not perform the action


~slider.valueAction_(rrand(0.0, 1.0)); // set new value + performs the action



//Color---------------------------------------

// RGB: https://zh.wikipedia.org/wiki/%E4%B8%89%E5%8E%9F%E8%89%B2%E5%85%89%E6%A8%A1%E5%BC%8F
//0 -> 1,  1表示更接近，0表示远离 ， alpha：1表示不透明 0表示透明

~slider.background;

~slider.background_(Color(1, 0.5, 0)); // full red, half green, no blue
~slider.background_(Color(219/255, 83/255, 83/255));   // https://www.colorspire.com/rgb-color-wheel/   随意选择颜色
~slider.background_(Color.green);
~slider.background_(Color.magenta);
~slider.background_(Color.magenta(0.0));
~slider.background_(Color.rand);

(
~slider.action_({
	arg obj;
	w.view.background_(Color.rand); //但移动时，让背景颜色随机变化
	obj.value.postln;
});
)


(
~slider.action_({
	arg obj;
	w.view.background_(Color.(obj.value*0.3 + 0.7, 0.8, 0.4)); //加一些限制
	obj.value.postln;
});
)


(
Window.closeAll;
w = Window("gui", Rect(750, 50, 500, 200))
.front
.alwaysOnTop_(true);

~slider = Slider(w.view, Rect(20, 20, 150, 30) )
.background_(Color(0.2, 0.75, 0.95));
)


~slider.knobColor_(Color.black); //把手颜色
~slider.thumbSize_(20); //把手大小
//注意不是所有对象都有 把手 去调整






//GUI and Ugens--------------------------------------

(
SynthDef.new(\simplebpf,{
	arg freq = 440;
	var sig;
	sig = PinkNoise.ar(1!2);
	sig = BPF.ar(sig, freq, 0.2);
	//sig = BPF.ar(sig, freq.lag(0.5), 0.2);
	Out.ar(0, sig);
}).add;
)

(
Window.closeAll;
w = Window.new("gui", Rect.new(750, 50, 500, 200))
.front
.alwaysOnTop_(true);

~slider = Slider(w, Rect(20, 20, 150, 30) )
.background_(Color(0.2, 0.75, 0.95))
.action_({
	arg obj;
	var cf;
	cf = obj.value.linexp(0, 1, 100, 4000).postln;  //设置频率范围    ControlSpec // linexp, linlin, explin
	x.set(\freq, cf);
});
)


x = Synth.new(\simplebpf);
x.free;

//问题1 ：使用这个例子时，如果快速移送slider, 会出现砰的响声
// continuous signal with discrete values （不连续值） that are not necessarily continuous， a filter problem

//问题2 ：slider初始值位置与频率不想符合


(
x = Synth.new(
	\simplebpf,
	[
		\freq, ~slider.value.linexp(0.1, 100, 4000)  // 使频率与slider初始值相对应
	]

);
)


//----
(
SynthDef.new(\simplebpf,{
	arg freq = 440;
	var sig;
	sig = PinkNoise.ar(1!2);
    sig = BPF.ar(sig, freq.lag(0.5), 0.2);   //lagging （滞后）  the frequency values，  lag causes the signal to interpolate（插入） between succesive values over a give time interval （时间间隔）which translates the discrete data （间断数据） into a smoother stream of values   注意恰当的滞后时间
	Out.ar(0, sig);
}).add;
)

(
Window.closeAll;
w = Window.new("gui", Rect.new(750, 50, 500, 200))
.front
.alwaysOnTop_(true);

~slider = Slider.new(w, Rect(20, 20, 150, 30) )
.background_(Color(0.2, 0.75, 0.95))
.action_({
	arg obj;
	var cf;
	cf = obj.value.linexp(0, 1, 100, 4000).postln;
	x.set(\freq, cf);
});


~button = Button(w, Rect(430, 20, 50, 30))       //~button.value_(0);     加入按钮来开始或停止声音
.states_([ //状态
	["OFF", Color.black, Color.gray(0.8)], // string, string color, background color
	["ON", Color.white, Color(0.2, 0.75, 0.95)]
])
.font_(Font("Monaco", 18))  // 所有类似于 button中可包含文字的对象，都可以调整字体， 注意选择你的电脑系统有的字体
.action_({
	arg obj;
	if(                 //如果
		obj.value == 1,  //按钮打开
		{
			x = Synth.new(   //声音响起
				\simplebpf,
				[
					\freq, ~slider.value.linexp(0.1, 100, 4000)
				]
			).register;
		},
		{x.free}   //否则关闭声音
	);
})
)

//Problem:  move the slider while the button in the off position -> node not found
// node watcher: 参考资料  register -> Node -> isPlaying ,  isRunning
//-----
(
SynthDef.new(\simplebpf,{
	arg freq = 440, rq;
	var sig;
	sig = PinkNoise.ar(1!2);
	sig = BPF.ar(
		sig,
		freq.lag(0.5),
		rq.lag(0.5),
		1/rq.sqrt.lag(0.5)); // quality control, when a filters bandpass narrows, the amplitude decreases and multiplying by this value whill ensure that the amplitude will remain more or less constant regardless  of filter quality

	Out.ar(0, sig);
}).add;
)

(
Window.closeAll;
w = Window.new("gui", Rect.new(750, 50, 500, 200))
.front
.alwaysOnTop_(true);

~slider = Slider(w, Rect(20, 20, 150, 30) )
.background_(Color(0.2, 0.75, 0.95))
.action_({
	arg obj;
	var cf;
	cf = obj.value.linexp(0, 1, 100, 4000).postln;
	if(
		x.isPlaying,           // 1.  make sure that the synth exists before attempting to update its parameters
		{x.set(\freq, cf)}
	);
	~numberBox.value_(obj.value.linexp(0, 1, 100, 4000)); // update the value of the number box, making sure to rescale the values corectly  ->contoling cound
});

~numberBox = NumberBox(w, Rect(180, 20, 80, 30)) // 3. one GUI object affect one or more other GUI onjects, control frequency
.value_(100)
.clipLo_(100)
.clipHi_(4000)
.font_(Font("Monaco", 16))
.decimals_(2)
.action_({
	arg obj;
	~slider.valueAction_(obj.value.explin(100, 4000, 0.1)) // evaluates action, if the value has changed
});

~freqLabel = StaticText(w, Rect(180, 50, 80, 20)) // 4.文字
.string_("freq")
.font_(Font("Monaco", 14))
.align_(\center)
.background_(Color.white)
.stringColor_(Color.red);

~knob = Knob(w, Rect(270, 20, 30, 30))      // 2. control the quality of the filter
.action_({
	arg obj;
	var qual;
	qual = obj.value.linexp(0, 1, 1, 100).reciprocal;
	if(
		x.isPlaying,
		{x.set(\rq, qual)}
	);
});



~button = Button(w, Rect(350, 20, 50, 30))       //~button.value_(0);
.states_([
	["OFF", Color.black, Color.gray(0.8)],
	["ON", Color.white, Color(0.2, 0.75, 0.95)]
])
.font_(Font("Monaco", 18))
.action_({
	arg obj;
	if(
		obj.value == 1, //打开开关
		{
			x = Synth.new(
				\simplebpf,
				[
					\freq, ~slider.value.linexp(0.1, 100, 4000),
					\rq, ~knob.value.linexp(0, 1, 1, 100).reciprocal
				]
			).register;  // registering with NodeWatcher 确保每次移动slider都有声音
		},
		{x.free}
	);
})
)

//------ Focusing 光标: mouse or tab
// slider, cknob : C : center position, X: maximum, N: minimum, R: random value
// arrow keys, incrementing, decrementing the object
// alt + shift modify the arrow key or mouse behavior
// buttion, clicking with mouse


//其他GUI对象----------------------------------------------------------------------------

(
~obj.remove;
~obj = PopUpMenu(w, Rect(20, 100, 120, 30))  //下拉菜单
.items_("one", "two", "three");
)

(
~obj.remove;
~obj = RangeSlider(w, Rect(20, 100, 120, 30)) //双向滑动条
)

(
~obj.remove;
~obj = TextField(w, Rect(20, 100, 120, 30)) //单行文字输入
)

(
~obj.remove;
~obj = TextView(w, Rect(20, 100, 120, 100)) //多行文字输入
)

(
~obj.remove;
~obj = Slider2D(w, Rect(20, 100, 120, 100))
)

(
~obj.remove;
~obj = MultiSliderView(w, Rect(20, 100, 120, 80))
.size_(9);
)

//SoundFileView, LevelIndicator





//Decorator -> FlowLayout------------------------------------------------------
// a decorator can be assigned to a parent view and will govern how and where child views are positioned on it
//flowlayout puts the next object to the right of the previous one and goes to the next line when it runs out of horizontal space

(
Window.closeAll; // 避免多窗口重叠
w = Window.new("flow", Rect.new(850, 50, 400, 400))
.front
.alwaysOnTop_(true);

// decorator as the main view
w.view.decorator_(FlowLayout(w.bounds, Point(15, 15), Point(7, 7)));  // rect, margin, gap (pixel)
//w.view.decorater_(FlowLayout(w.bounds, 15@15, 7@7)); (x@y)
)


Knob(w, 100@100); //执行一次，建一个滑钮
20.do{Knob(w, 40@40)}; //执行一次，创建多个


w.view.children.collect(_.value_(rrand(0.0, 1.0))); // 设置滑钮成随机数值
w.view.children.collect(_.remove); //消除所有对象

w.view.decorator.reset;//////////
w.view.decorator.nextLine; //换行



// example

(
Window.closeAll;
w = Window.new("nested", Rect.new(750, 50, 500, 500))
.front
.alwaysOnTop_(true);

w.view.decorator_(FlowLayout(w.bounds, 30@30, 30@30));

c = Array.fill(4, {  //设置四个compositeview
	arg view;
	view = CompositeView(w, 200@200)  // parent view
	.background_(Color.rand);

	view.decorator_(FlowLayout(view.bounds, 5@5, 5@5));  // subview
});

Array.fill(5, {Slider(c[0], 30@150)});  //数列1
Array.fill(5, {Knob(c[1], 40@40)});  //数列2
)

 //可明确指定某一对象数据，或同时指定同一decorator中的多个对象
c[0].children[2].value_(0.5);
c[1].children.collect(_.value_(0.75));













































































