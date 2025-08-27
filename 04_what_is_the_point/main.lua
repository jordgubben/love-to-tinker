-- [[ Vector tool vaugly inspired by 'Sketchpad']]
--
-- Naming convention:
-- Field names use lower camel case.
-- Underscore for prefix and suffix categorization.
-- (it somwhow made sense at the time)


----------------------------------------------------------------
---- Configuration
selectionLimit = 16


----------------------------------------------------------------
---- Global state (sue me not, I'm not Sue)
points = { }
selectedPoint = nil


----------------------------------------------------------------
---- Logging

-- Where are we?
--
-- Debug function that returns where it's caller
-- (or callers caller etc.) is defined in code.
-- Although that's be practical it does not return
-- the line of the actual call site, but the line
-- where the calling function is initially declared.
--
function funcLocation ( depth )
	local info = debug.getinfo( (depth or 0) + 2 )
	return string.format( "%s:%d\t%s()", info.source, info.linedefined, info.name or "<anonymous>" )
end


-- Print log message
function log_internal ( level, msg )
	print( level, funcLocation( 2 ), msg )
end
function log_info( msg ) log_internal( "INFO", msg ) end
function log_error( msg ) log_internal( "ERROR", msg ) end


----------------------------------------------------------------
---- Points

-- Set up a grid of points just to get going
function make_initialPoints()
	for x = 50, 750, 100 do
		for y = 50, 550, 100 do
			table.insert( points, { x, y } )
		end
	end
end


-- Select the point among the points closest to the given position.
--
-- Limit selection to point close enough,
-- and clear selction if nothing was close enough.
--
function select_closestPoint( sx, sy)
	local bestDistance = selectionLimit * selectionLimit
	selectedPoint = nil

	for _, point in ipairs( points ) do
		local px, py = unpack( point )
		local dx, dy = sx - px, sy - py
		local l2 = dx * dx + dy * dy
		if l2 < bestDistance then
			selectedPoint = point
			bestDistance = l2
		end
	end
end


-- Draw a single point in a way that makes it clearly visble.
function draw_point( center )
	local g = love.graphics
	local x, y = unpack( center )
	g.rectangle("line", x - 5, y - 5, 11, 11 )
	g.rectangle("fill", x - 3, y - 3, 7, 7 )
end


------------------------------------------------------------
---- Löve2D framework hooks
---- (may be left empty for easy access)

-- Initial initialization.
function love.load ()
	log_info( "Starting up.." )

	make_initialPoints()
end


-- Handle mouse press
function love.mousepressed( x, y, button, touch, presses )
  log_info(
		string.format( "Mouse button pressed: (%i,%i) [%i]", x, y, button) )

	select_closestPoint( x, y )
end


-- Handle key press input as stream of event.
function love.keypressed( key, scancode, isrepeat )
	log_info(
		string.format( "Key pressed: %s\t%s\t%s", key, scancode, isrepeat ) )
end


-- Update every frame.
function love.update ( dt )

end


-- Render every frame.
function love.draw ()
	local g = love.graphics

	-- Draw all the points.
	g.setColor( 1, 1, 1, 0.75 )
	for _, point in ipairs( points ) do
		draw_point( point )
	end

	-- Draw selected point (if any) in a different color.
	g.setColor( 1, 1, 0.75, 1 )
	if selectedPoint then
		draw_point( selectedPoint )
	end
end
