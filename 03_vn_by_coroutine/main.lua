-- [[ Minimal VN interface using coroutines as control flow. ]]
--
-- Naming convention: field names use lower camel case, with underscore for prefix and suffix categorization.


-- Global state (sue me, or don't).
message = ""


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



-- Display a text message (without options).
function showMessage( msg )
	log_info( msg )
	coroutine.yield( msg )
end


-- Coroutine used to forward monologue.
plot = coroutine.wrap( function ()
	log_info( "Hello, Coroutine!")

	showMessage( "Greetings!" )
	showMessage( "How do you do?" )
	showMessage( "That's good to hear!" )

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
		message = result
	else
		log_info( "Concluded!")
		message = ""
		plot = nil
	end
end


-- Redner text box at the bottom of the application window.
function drawMessageBox()
	local g = love.graphics
	local winWidth, winHeight = g.getDimensions()
	local boxLeft, boxTop, boxRight, boxBottom =
		64, winHeight - 192, winWidth - 64, winHeight - 32
	local textLeft, textTop =
		boxLeft + 24, boxTop + 24

	-- Box back
	g.setLineWidth( 6 )
	g.setColor( 0.5, 0.8, 0.8, 0.5)
	g.rectangle( "fill"
		, boxLeft, boxTop
		, boxRight - boxLeft, boxBottom - boxTop )

	-- Text message
	g.setColor( 1, 1, 1, 1)
	g.push()
	g.translate( textLeft, textTop )
	g.scale( 2 )
	g.print( message, 0, 0 )
	g.pop()
end


------------------------------------------------------------
---- ---- ----     Löve2D framework hooks     ---- ---- ----
--------- (may be left blank - save for later) -------------
------------------------------------------------------------


-- Inital initalizatons.
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
	drawMessageBox()
end
