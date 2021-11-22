love.window.setFullscreen(true)

function love.load()
    W, H = love.graphics.getDimensions()
    
    -- 0 for start screen state; 1 for in-game state; and 2 for end screen state.
    state = 0
    score = 0
    highscore = 0
    -- If the highscore.txt file does not yet exist, create it and write 0.
    if not love.filesystem.getInfo("highscore.txt") then
        love.filesystem.write("highscore.txt", "0\n")
    end
    -- Read the highscore as the last line in the highscore.txt file.
    for line in love.filesystem.lines("highscore.txt") do
        highscore = tonumber(line)
    end

    -- Load in requirements.
    player = require("player")
    require("enemy")
    require("parallax")

    -- Load in and begin playing background music.
    soundtrack = love.audio.newSource("assets/audio/soundtrack.mp3", "static")
    soundtrack:setLooping(true)
    love.audio.play(soundtrack)

    -- Load in background images and set up parallax layers.
    layers = {}
    local path = "assets/images/background/"
    table.insert(layers, newParallaxLayer(path .. "1.png", 65))
    table.insert(layers, newParallaxLayer(path .. "2.png", 125))
    table.insert(layers, newParallaxLayer(path .. "3.png", 200))
    table.insert(layers, newParallaxLayer(path .. "4.png", 250))
    table.insert(layers, newParallaxLayer(path .. "5.png", 200))
    table.insert(layers, newParallaxLayer(path .. "6.png", 300))
    -- Load in moon images.
    moon = love.graphics.newImage("assets/images/moon.png")
    moonHalo = love.graphics.newImage("assets/images/moonHalo.png")
    -- Create spooky font in multiple sizes.
    fonts = {}
    fonts.xl = love.graphics.newFont("assets/fonts/halloweenFont.ttf", 96)
    fonts.md = love.graphics.newFont("assets/fonts/halloweenFont.ttf", 40)

end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.mousepressed()
    if state == 0 then
        -- Setup/reset game management variables.
        state = 1
        score = 0
        enemyMinSpeed = 150
        enemyMaxSpeed = 200
        tBtwnSpeedIncreases = 10
        tSinceLastSpeedIncrease = 0
                
        -- Create enemies at random positions offscreen.
        enemies = {}
        local enemy = newEnemy(W + love.math.random(50, 100))
        table.insert(enemies, enemy)
        for i = 2, 6 do
            enemy = newEnemy(enemies[i - 1].x + love.math.random(200, 400))
            table.insert(enemies, enemy)
        end

        -- Reset the position of the player.
        player.x = W * 0.05
        player.y = (H * 0.5) - (player.h * 0.5)
    elseif state == 2 then
        state = 0
    end
end

function love.update(dt)
    -- Update the parallax layers.
    for i = 1, #layers do
        layers[i].update(dt)
    end

    if state == 1 then
        -- If enough time has passed since the enemy speed was last increased,
        -- increase the minimum and maximum enemy speeds and reset the timer.
        tSinceLastSpeedIncrease = tSinceLastSpeedIncrease + dt
        if (tSinceLastSpeedIncrease >= tBtwnSpeedIncreases) then
            enemyMinSpeed = enemyMinSpeed + 50
            enemyMaxSpeed = enemyMaxSpeed + 50
            tSinceLastSpeedIncrease = 0
        end
        
        -- Update player and enemies.
        player.update(dt)
        for i = 1, #enemies do
            enemies[i].update(dt)
        end

        score = score + dt
        if score > highscore then
            highscore = math.floor(score + 0.5)
        end
    end
end

function love.draw()
    love.graphics.push()
    -- Scale the background images to fit the screen vertically.
    -- love.graphics.scale(layers[1].image:getHeight() / H)
    -- Draw deep background fog layer.
    layers[1].draw()
    -- Draw moon and moon halo.
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(moon, 850, 100)
    love.graphics.setColor(0.5, 0, 1)
    love.graphics.draw(moonHalo, 500, 25)
    -- Draw background trees and fog and midground trees.
    layers[2].draw()
    layers[3].draw()
    layers[4].draw()
    love.graphics.pop()

    -- Draw players and enemies between midground and foreground layers.
    if state == 1 then
        player.draw()
        for i = 1, #enemies do
            enemies[i].draw()
        end
    end

    love.graphics.push()
    -- Scale the background images again to fit the screen vertically.
    -- Draw midground fog and foreground trees.
    layers[5].draw()
    layers[6].draw()
    love.graphics.pop()
    
    love.graphics.setColor(1, 0.65, 0)
    if state == 0 then
        love.graphics.setFont(fonts.xl)
        love.graphics.printf("THE WITCHING HOUR!", 0, H * 0.25, W, "center")

        love.graphics.setFont(fonts.md)
        love.graphics.printf("USE ARROW KEYS TO MOVE", 0, H * 0.625, W, "center")        
        love.graphics.printf("DON'T LET THE GHOSTS TOUCH YOU!", 0, H * 0.675, W, "center")  
        
        love.graphics.printf("CLICK ANYWHERE TO START", 0, H * 0.8, W, "center")
        love.graphics.printf("PRESS ESC TO EXIT", 0, H * 0.85, W, "center")
    elseif state == 1 then
        love.graphics.setFont(fonts.md)
        love.graphics.print("SCORE: " .. math.floor(score + 0.5), 10, 10)
        love.graphics.print("HIGHSCORE: " .. highscore, 10, 55)
    elseif state == 2 then
        love.graphics.setFont(fonts.xl)
        love.graphics.printf("GAME OVER!", 0, H * 0.25, W, "center")

        love.graphics.setFont(fonts.md)
        love.graphics.printf("SCORE: " .. math.floor(score + 0.5), 0, H * 0.525, W, "center")
        love.graphics.printf("HIGHSCORE: " .. highscore, 0, H * 0.575, W, "center")

        love.graphics.printf("CLICK ANYWHERE TO RESTART", 0, H * 0.8, W, "center")
        love.graphics.printf("PRESS ESC TO EXIT", 0, H * 0.85, W, "center")
    end
end