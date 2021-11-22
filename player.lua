local player = {}

-- Populate animation frames and set up animation variables.
player.animationFrames = {}
for i = 1, 4 do
    local frame = love.graphics.newImage("assets/images/player/" .. i .. ".png")
    table.insert(player.animationFrames, frame)
end
local currentFrame = 1
local tBtwnFrames = 0.1
local tSinceLastFrame = 0

-- The original size of the player image is too small, so we must scale its size.
-- (The negative x-value is so that the player is drawn facing to the right.)
player.scaleX = -3
player.scaleY = 3
-- Use the first animation frame to get the dimensions of the player.
player.w = player.animationFrames[currentFrame]:getWidth() * math.abs(player.scaleX)
player.h = player.animationFrames[currentFrame]:getHeight() * math.abs(player.scaleY)
player.x = W * 0.05
player.y = (H * 0.5) - (player.h * 0.5)
player.speed = 350

-- Specify values to constrain the movement of the player.
-- (The player is not allowed to move off the left or top edges of the screen,
-- into the right half of the screen, or too far into the roots and grass at 
-- the bottom of the screen.)
local minX = 0
local minY = 0
local maxX = W * 0.5
local maxY = H * 0.9

-------------------
-- PLAYER.UPDATE --
-------------------
function player.update(dt)
    -- If enough time has past since the last frame in the player animation, 
    -- switch to the next frame and reset the timer.
    tSinceLastFrame = tSinceLastFrame + dt
    if (tSinceLastFrame >= tBtwnFrames) then
        currentFrame = (currentFrame % 4) + 1
        tSinceLastFrame = 0
    end

    local dx, dy = 0, 0
    local isDown = love.keyboard.isDown
    if (isDown("right") or isDown("d")) and (player.x + player.w < maxX) then
        dx = 1
    end
    if (isDown("left") or isDown("a")) and player.x > minX then
        dx = -1
    end
    if (isDown("down") or isDown("s")) and (player.y + player.h < maxY) then
        dy = 1
    end
    if (isDown("up") or isDown("w")) and player.y > minY then
        dy = -1
    end

    local magnitude = math.sqrt(dx ^ 2 + dy ^ 2)
    if magnitude == 0 then
        dx, dy = 0, 0
    else
        dx, dy = dx / magnitude, dy / magnitude
    end

    player.x = player.x + (player.speed * dx * dt)
    player.y = player.y + (player.speed * dy * dt)
    player.LHS = player.x + (player.w * 0.375)
    player.RHS = player.x + (player.w * 0.825)
    player.top = player.y + (player.h * 0.15)
    player.bottom = player.y + (player.h * 0.85)
end

-----------------
-- PLAYER.DRAW --
-----------------
function player.draw()
    love.graphics.setColor(1, 1, 1)
    -- Since this image is flipped horizontally when drawn, we must offset its
    -- x position appropriately after scaling the image.
    love.graphics.draw(
        player.animationFrames[currentFrame], player.x, player.y, 0,
        player.scaleX, player.scaleY, player.w / math.abs(player.scaleX)
    )
    -- Draw player hitbox.
    -- love.graphics.rectangle("line", player.LHS, player.top, player.RHS - player.LHS, player.bottom - player.top)
end

return player
