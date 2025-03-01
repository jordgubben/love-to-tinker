-- Create our shader at load time.
function love.load()
	customShader = love.graphics.newShader( "shader.glsl" )
	print( "Made a Shader: ", customShader:type() )
end

-- Draw rectangle and greeting every frame.
function love.draw()
	local g = love.graphics
	
	-- Polite greating (without any shady stuff).
	g.setColor( 1, 1, 1, 1 )
	g.setShader( nil )
	g.print('Hello, Shady Löve!', 100, 75)

	-- Draw rectangle with shader.
	g.setColor( 0.5, 0.5, 0.5, 1 )
	g.setShader( customShader )
	customShader:sendColor( "tint", { 0, 0.5, 0, 0 } )
	g.rectangle( "fill", 100, 100, 200, 200 )
end
