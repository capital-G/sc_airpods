AirPodsQuat : MultiOutUGen {
	*kr {
		^this.multiNew('control');
	}

	init { |... theInputs|
		inputs = theInputs;
		^this.initOutputs(4, 'control');
	}
}

// pseudo ugen
AirPodsEuler : MultiOutUGen {
	*kr {
		// from https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
		var q = AirPodsQuat.kr;

		// roll (x-axis rotation)
		var sinr_cosp = 2 * ((q[3] * q[0]) + (q[1] * q[2]));
		var cosr_cosp = 1 - (2 * ((q[0] * q[0]) + (q[1] * q[1])));
		var roll = atan2(sinr_cosp, cosr_cosp);

		// pitch (y-axis rotation)
		var sinp = sqrt(1 + (2 * ((q[3] * q[1]) - (q[0] * q[2]))));
		var cosp = sqrt(1 - (2 * ((q[3] *q[1]) - (q[0] * q[2]))));
		var pitch = (2 * atan2(sinp, cosp)) - (pi/2);

		// yaw (z-axis rotation)
		var siny_cosp = 2 * ((q[3] * q[2]) + (q[0] * q[1]));
		var cosy_cosp = 1 - (2 * ((q[1] * q[1]) + (q[2] * q[2])));
		var yaw = atan2(siny_cosp, cosy_cosp);

		^[roll, pitch, yaw];
	}
}

AirPodsAcc : MultiOutUGen {
	*kr {
		^this.multiNew('control');
	}

	init { |... theInputs|
		^this.initOutputs(3, 'control');
	}
}

AirPodsStatus : UGen {
	*kr {
		^this.multiNew('control');
	}
}
