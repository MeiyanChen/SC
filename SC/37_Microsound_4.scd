
p = ProxySpace.push(s.boot);
b = Buffer.readNoUpdate(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
~timepitch = {arg sndbuf, pitchRatio = 1, pitchRd = 0.01, grainRate = 10, overlap = 2, posSpeed = 1, posRd = 0.01;

	var graindur = overlap/grainRate;
	var pitchrate = pitchRatio + LFNoise0.kr(grainRate, pitchRd);
	var position = LFSaw.kr(posSpeed/ BufDur.kr(sndbuf)).range(0, 1) + LFNoise0.kr(grainRate, posRd);

	GrainBuf.ar(2, Impulse.kr(grainRate), graindur, sndbuf, pitchrate, position, 4, 0, -1)

};
~timepitch.set(\sndbuf, b.bufnum);
~timepitch.play;
);















