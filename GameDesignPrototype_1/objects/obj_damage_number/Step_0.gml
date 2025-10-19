/// @description
age++;
depth++;
// Float upward with deceleration
currentSpeed += floatAccel;
currentSpeed = max(currentSpeed, 0.5); // Minimum float speed
y -= currentSpeed;

// Horizontal drift
x += driftX;
driftX *= driftDecay;

// Scale effect (grows slightly)
if (isCrit) {
    // Critical hits pulse
    scale = critScale + sin(age * 0.3) * 0.1;
    critShake = sin(age * 0.5) * 2;
} else {
    scale += scaleSpeed;
    scaleSpeed *= 0.95; // Scale growth slows
}

// Fade out over time
if (age > lifetime * 0.5) { // Start fading halfway through
    currentAlpha -= fadeSpeed;
    currentAlpha = max(0, currentAlpha);
}

// Destroy when fully faded or too old
if (currentAlpha <= 0 || age > lifetime) {
    instance_destroy();
}


if (owner != noone)
{
	if (instance_exists(owner))
	{
			x = owner.x;
	        y = owner.y - currentSpeed *age;
	}

}