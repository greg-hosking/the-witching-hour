function newParallaxLayer(imageFilename, speed) 
    local parallaxLayer = {}

    parallaxLayer.image = love.graphics.newImage(imageFilename)
    parallaxLayer.width = parallaxLayer.image:getWidth()
    parallaxLayer.x1 = 0
    parallaxLayer.x2 = parallaxLayer.width
    parallaxLayer.speed = speed

    function parallaxLayer.update(dt)
        parallaxLayer.x1 = parallaxLayer.x1 - (parallaxLayer.speed * dt)
        parallaxLayer.x2 = parallaxLayer.x2 - (parallaxLayer.speed * dt)

        if (parallaxLayer.x1 + parallaxLayer.width < 0) then
            parallaxLayer.x1 = parallaxLayer.x2 + parallaxLayer.width
        end
        if (parallaxLayer.x2 + parallaxLayer.width < 0) then
            parallaxLayer.x2 = parallaxLayer.x1 + parallaxLayer.width
        end
    end

    function parallaxLayer.draw()
        love.graphics.push()
        love.graphics.setColor(0.5, 0, 1)
        love.graphics.scale(1, 960/1080)
        love.graphics.draw(parallaxLayer.image, parallaxLayer.x1)
        love.graphics.draw(parallaxLayer.image, parallaxLayer.x2)
        love.graphics.pop()
    end

    return parallaxLayer
end