-- [[ Minimal VN interface using coroutines as control flow. ]]
--
-- Naming convention: field names use lower camel case, with underscore for prefix and suffix categorization.


-- Global state (sue me, or don't).
queuedUiElements = {}
activeUiElements = {}


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


-- Enqueue UI element.
function push_uiElement ( element )
	table.insert( queuedUiElements, element )
end


-- Show all elements (assumes coroutine).
function show_uiElements ()
	coroutine.yield( queuedUiElements )
	queuedUiElements = {}
end


-- Present additional info.
function push_infoBox ( msg )
	log_info( msg )
	push_uiElement { type = "info", text = msg }
end


-- Present message in the typical VN way.
function push_messageBox ( msg )
	log_info( msg )
	push_uiElement { text = msg }
end


-- Display a text message (without options) along with everything pushed.
function show_messageBox( msg )
	push_messageBox( msg )
	show_uiElements()
end


-- Coroutine used to forward monologue.
plot = coroutine.wrap( function ()
	log_info( "Hello, Coroutine!")

	show_messageBox( "Greetings!" )
	show_messageBox( "How do you do?" )
	push_infoBox( "You suspect they're just being polite." )
	show_messageBox( "That's good to hear!" )

	log_info( "That's it!")
end)


-- Forward plot one step (i.e. handle player key press)
function forwardPlot ()
	if  not plot then
		log_info( "We're done here" )
		return
	end

	local ok, result = pcall( plot )
	if not ok then
		log_error( result )
	elseif result then
		log_info( string.format("Progress: '%s'", result ) )
		activeUiElements = result
	else
		log_info( "Concluded!")
		activeUiElements = {}
		plot = nil
	end
end


-- Render additional information at the top of the screen.
function draw_infoBox_ui( message )
	local g = love.graphics
	local win_w, win_h = g.getDimensions()
	local box_left, box_top, box_right, box_bottom =
		64, 32, win_w - 64, 32 + 64
	local text_x, text_y =
		box_left + 24, box_top + 24

	-- Box back
	g.setLineWidth( 6 )
	g.setColor( 0.3, 0.6, 0.9, 0.5 )
	g.rectangle( "line"
		, box_left, box_top
		, box_right - box_left, box_bottom - box_top )
	g.setColor( 0.1, 0.4, 0.8, 0.5 )
	g.rectangle( "fill"
		, box_left, box_top
		, box_right - box_left, box_bottom - box_top )

	-- Text message
	g.setColor( 1, 1, 1, 1)
	g.push()
	g.translate( text_x, text_y )
	g.scale( 1.5 )
	g.print( message, 0, 0 )
	g.pop()
end


-- Render text box at the bottom of the application window.
function draw_messageBox_ui ( message )
	local g = love.graphics
	local win_w, win_h = g.getDimensions()
	local box_left, box_top, box_right, box_bottom =
		64, win_h - 192, win_w - 64, win_h - 32
	local text_x, text_y =
		box_left + 24, box_top + 24

	-- Box back
	g.setLineWidth( 6 )
	g.setColor( 0.1, 0.8, 0.4, 0.5 )
	g.rectangle( "fill"
		, box_left, box_top
		, box_right - box_left, box_bottom - box_top )

	-- Text message
	g.setColor( 1, 1, 1, 1 )
	g.push()
	g.translate( text_x, text_y )
	g.scale( 2 )
	g.print( message, 0, 0 )
	g.pop()
end


-- Draw whatever UI element was provided.
function draw_uiElement ( element )
	if element.type == "info" then
		draw_infoBox_ui( element.text )
	else
		draw_messageBox_ui( element.text )
	end
end

------------------------------------------------------------
---- ---- ----     Löve2D framework hooks     ---- ---- ----
--------- (may be left blank - save for later) -------------
------------------------------------------------------------


-- Initial initialization.
function love.load ()
	forwardPlot()
end


-- Handle key press input as stream of event.
function love.keypressed( key, scancode, isrepeat )
	log_info( string.format("Key pressed: %s\t%s\t%s", key, scancode, isrepeat ) )

	if  key == "space" and not isrepeat then
		forwardPlot()
	end
end


-- Update every frame.
function love.update ( dt )

end


-- Render every frame.
function love.draw ()
	for _, element in ipairs( activeUiElements ) do
		draw_uiElement( element )
	end
end
