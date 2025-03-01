local rect = { x1 = 150, y1 = 150, x2 = 250, y2 = 250 }
local hovered, grabbed = {}, {}


-- Mark edges close to the given point.
function markRectangleEdges ( px, py )
	local limit = 5
	local edges = {}
	edges.x1 = math.abs( px - rect.x1) <= limit
	edges.x2 = math.abs( px - rect.x2) <= limit
	edges.y1 = math.abs( py - rect.y1) <= limit
	edges.y2 = math.abs( py - rect.y2) <= limit
	return edges
end


-- Draw all rectangle edges provided.
function drawEdges ( edges )
	local g = love.graphics
	local x1, x2, y1, y2 = rect.x1, rect.x2, rect.y1, rect.y2
	if edges.x1 then g.line( x1, y1, x1, y2 ) end
	if edges.x2 then g.line( x2, y1, x2, y2 ) end
	if edges.y1 then g.line( x1, y1, x2, y1 ) end
	if edges.y2 then g.line( x1, y2, x2, y2 ) end
end


-- Process input every frame.
function love.update ( dt )
	local px, py = love.mouse.getPosition()
	if love.mouse.isDown( 1 ) then
		if not pressedPos then
			pressedPos = { x = px, y = py }
			grabbed = markRectangleEdges( px, py )
		end
	else
		pressedPos = nil
		grabbed = {}
		hovered = markRectangleEdges( px, py)
	end

	-- Adjust grabbed rectangle edges.
	if grabbed.x1 then rect.x1 = px end;
	if grabbed.x2 then rect.x2 = px end;
	if grabbed.y1 then rect.y1 = py end;
	if grabbed.y2 then rect.y2 = py end;
end


-- Render every frame.
function love.draw ()
	local g = love.graphics
	local mx, my = love.mouse.getPosition()
	local x1, x2, y1, y2 = rect.x1, rect.x2, rect.y1, rect.y2
	local rw, rh = rect.x2 - rect.x1, rect.y2 - rect.y1

	-- Print rectangle position and size (for debug).
	g.setColor( 1, 1, 1, 1 )
	g.print( string.format( "( %d, %d) [ %d, %d]", x1, y1, rw, rh ), 24, 24)

	-- Print mouses current, and initial pressed positions.
	g.print( string.format( "Mouse at: ( %d, %d)", mx, my ), 24, 40)
	if pressedPos then
		g.setColor( 0, 1, 0.5 )
		local msg =
			string.format( "Pressed at: ( %d, %d)"
				, pressedPos.x, pressedPos.y )
		g.print( msg, 24, 56)
	end
			
	-- Draw the actual rectangle.
	g.setLineWidth( 1 )
	g.setColor( 0.2, 0.7, 0.5, 0.75 )
	g.rectangle( "line", x1, y1, rw, rh )
	g.setColor( 0.2, 0.7, 0.5, 0.25 )
	g.rectangle( "fill", x1, y1, rw, rh )

	-- Draw mouse drag.
	if pressedPos then
		g.setColor( 0, 1, 0.5 )
		g.line( mx, my, pressedPos.x, pressedPos.y )
	end

	-- Draw hovered and grabbed edges.
	g.setLineWidth( 3 )
	g.setColor( 0.5, 1.0, 0.0, 0.5 )
	drawEdges( hovered )
	g.setColor( 1.0, 1.0, 0.0 , 0.5)
	drawEdges( grabbed )
end
