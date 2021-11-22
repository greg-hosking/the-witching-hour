function newEnemy(x)
    local enemy = {}

    enemy.x = x

    -- Populate animation frames and set up animation variables.
    -- (Effectively the same as in the player module.)
    enemy.animationFrames = {}
    for i = 1, 4 do
        local frame = love.graphics.newImage("assets/images/enemy/" .. i .. ".png")
        table.insert(enemy.animationFrames, frame)
    end
    local currentFrame = 1
    local tBtwnFrames = 0.1
    local tSinceLastFrame = 0

    -- The original size of the player image is too small, so we must scale its size.
    -- (The positive x-value is so that the player is drawn facing to the left.)
    enemy.scaleX = 2.5
    enemy.scaleY = 2.5
    -- Use the first animation frame to get the dimensions of the enemy.
    enemy.w = enemy.animationFrames[currentFrame]:getWidth() * math.abs(enemy.scaleX)
    enemy.h = enemy.animationFrames[currentFrame]:getHeight() * math.abs(enemy.scaleY)
    enemy.y = love.math.random(0, H - enemy.h)
    enemy.speed = love.math.random(enemyMinSpeed, enemyMaxSpeed)

    function enemy.update(dt)
        -- If enough time has past since the last frame in the player animation, 
        -- switch to the next frame and reset the timer.
        tSinceLastFrame = tSinceLastFrame + dt
        if (tSinceLastFrame >= tBtwnFrames) then
            currentFrame = (currentFrame % 4) + 1
            tSinceLastFrame = 0
        end

        enemy.x = enemy.x - (enemy.speed * dt)
        -- If the enemy moves off the left edge of the screen, send it back to 
        -- the other side and randomize its y-position and speed. 
        if (enemy.x + enemy.w < 0) then
            enemy.x = W + love.math.random(50, 100)
            enemy.y = love.math.random(0, (H * 0.9) - enemy.h)
            enemy.speed = love.math.random(enemyMinSpeed, enemyMaxSpeed)
        end
        -- Check if the enemy is colliding with the player.
        enemy.LHS = enemy.x + (enemy.w * 0.2)
        enemy.RHS = enemy.x + (enemy.w * 0.75)
        enemy.top = enemy.y + (enemy.h * 0.1)
        enemy.bottom = enemy.y + (enemy.h * 0.85)
        if ((player.LHS <= enemy.RHS and player.RHS >= enemy.LHS) and 
            (player.top <= enemy.bottom and player.bottom >= enemy.top)) then
            state = 2
            -- Store the highscore in a .txt file to save the highscore across sessions.
            love.filesystem.write("highscore.txt", highscore)
        end
    end

    function enemy.draw()
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(
            enemy.animationFrames[currentFrame], enemy.x, enemy.y, 0, 
            enemy.scaleX, enemy.scaleY
        )
        -- Draw enemy hitbox.
        -- love.graphics.rectangle("line", enemy.LHS, enemy.top, enemy.RHS - enemy.LHS, enemy.bottom - enemy.top)
    end

    return enemy
end
