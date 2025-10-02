///=
function lobShot(_self, _spd, _direction, _xStart, _yStart, _targetDistance) {
    var radDirection = degtorad(_direction);
    
    // Calculate target endpoint
    var _outlineX = _xStart + _targetDistance * cos(radDirection);
    var _outlineY = _yStart - _targetDistance * sin(radDirection);
    
    // Infer progress based on the horizontal distance covered relative to the total distance
    var currentDistanceX = abs(_self.x - _xStart);
    var totalDistanceX   = abs(_outlineX - _xStart);
    var _progress		 = min(1, currentDistanceX / totalDistanceX);

    // Assuming a dynamic calculation for arcHeight based on _targetDistance
    var _arcHeight = _targetDistance * 0.25;

    if (_progress < 1) {
        _self.lobbed = true;
        var currentX = lerp(_xStart, _outlineX, _progress);
        var currentY = lerp(_yStart, _outlineY, _progress) - sin(pi * _progress) * _arcHeight * 2;

        _self.x = currentX;
        _self.y = currentY;
    } else {
        _self.lobbed = false;
    }
	
	// Calculate next position's progress
	var next_progress = min(1, (currentDistanceX + _spd) / totalDistanceX);

	// Calculate next position based on estimated next progress
	var nextX = lerp(_xStart, _outlineX, next_progress);
	var nextY = lerp(_yStart, _outlineY, next_progress) - sin(pi * next_progress) * _arcHeight * 2;

	// Calculate angle to next position
	var angleToNext = point_direction(_self.x, _self.y, nextX, nextY);

	// Update object's draw direction
	_self.drawDir = angleToNext;
	
	_self.outlineX = _outlineX;
	_self.outlineY = _outlineY;
	return _progress;
}


function Jump(_self, _spd, _direction, _xStart, _yStart, _targetDistance) {
    var radDirection = degtorad(_direction);
    
    // Calculate target endpoint
    var _outlineX = _xStart + _targetDistance * cos(radDirection);
    var _outlineY = _yStart - _targetDistance * sin(radDirection);
    
    // Infer progress based on the horizontal distance covered relative to the total distance
    var currentDistanceX = abs(_self.x - _xStart);
    var totalDistanceX   = abs(_outlineX - _xStart);
    var _progress		 = min(1, currentDistanceX / totalDistanceX);

    // Assuming a dynamic calculation for arcHeight based on _targetDistance
    var _arcHeight = _targetDistance * 0.25;

    if (_progress < 1) {
        _self.jumping = true;
        var currentX  = lerp(_xStart, _outlineX, _progress);
        var currentY  = lerp(_yStart, _outlineY, _progress) - sin(pi * _progress) * _arcHeight * 2;

        _self.x = currentX;
        _self.y = currentY;
    } else {
        _self.jumping = false;
    }
	
	// Calculate next position's progress
	var next_progress = min(1, (currentDistanceX + _spd) / totalDistanceX);

	// Calculate next position based on estimated next progress
	var nextX = lerp(_xStart, _outlineX, next_progress);
	var nextY = lerp(_yStart, _outlineY, next_progress) - sin(pi * next_progress) * _arcHeight * 2;

	// Calculate angle to next position
	var angleToNext = point_direction(_self.x, _self.y, nextX, nextY);
	
	_self.outlineX = _outlineX;
	_self.outlineY = _outlineY;
	return _progress;
}