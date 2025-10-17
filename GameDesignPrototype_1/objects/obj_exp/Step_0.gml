if (settled) exit;

if (speed > 0.1 && !settled) 
{
	speed *= 0.9;
}
else
{
	settled = true;
}