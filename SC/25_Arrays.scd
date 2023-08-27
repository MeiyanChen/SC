//arrays so an array just to recap is an object which is an ordered collection of things

x = [3, 7, 12, -4.5, 0, 101]; //we have an array stored in the interpreter variable x and it doesn't have to be numbers in  整数和小数的混合

x.size; // 大小

x.at(2);//access an item by index, 0, 1, 2 ,3
x[2];

x.at([1,3,4]); //request an array of indices
x[[1,3,4]];




x = (0..1000); //all of the numbers from zero to a thousand
x = (0,2..1000);

x = (0..100);
x = (0,2..100); //所有偶数
x = (100,98..0);//逆行
x = (100,98..200);// 错误写法

x.size;
x = Array.series(1001, 0, 1); //大小，开始，计数方法 （加法）
x = Array.series(1001, 1000, -7);
x = Array.series(7, 260, 20);

x = Array.geom(7, 2, 2); //乘法
x = Array.geom(10, 2, 0.5);  // 可 用于调整音量

x = Array.rand(7, 100, 200); //10 random values between 100 and 200

rrand(0, 10);
//we use arrays to represent multi-channel signals like a stereo signal is an array of two signals and when we want to scale the amplitude we might multiply it by some value like 0.5 and we want that to apply to both channels so this is a very useful way to define this type of operation

x = [100, 200, 300];
x + 5;
x * 5;

x = [100, 200, 300];
y = [5, 6, 7, 8];
x + y; // wrapping



// dupilication
"hi".dup(4); //4 copies of hi
4.dup(9);  // 9 copies of 4
4 ! 9 //it's a great way to take a mono signal and just turn it into a two channel signal









































