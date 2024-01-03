local composer = require("composer")

local scene = composer.newScene()

local player
local playerSpeed = 2
local playerXSpeed, playerYSpeed = 0, 0

local bulletSpeed = 5
local bulletGroup = display.newGroup()

local function updateMovement()
    -- Pelaajan liikkeen päivitys
    player.x = player.x + playerXSpeed
    player.y = player.y + playerYSpeed
end

local function trackPlayer(event)
    -- Hiiren seuraus ja pelaajan suunnan päivitys
    local deltaX = event.x - player.x
    local deltaY = event.y - player.y
    local a = math.atan2(deltaY, deltaX)

    local playerRotation = math.deg(a) + 90
    playerRotation = playerRotation % 360

    player.rotation = playerRotation
end

local function updateBullets()
    -- Ammusten päivitys ja poistaminen, jos ne menevät näytön ulkopuolelle
    for i = bulletGroup.numChildren, 1, -1 do
        local bullet = bulletGroup[i]

        if bullet then
            bullet.x = bullet.x + bullet.xSpeed
            bullet.y = bullet.y + bullet.ySpeed

            if bullet.x < 0 or bullet.x > display.contentWidth or bullet.y < 0 or bullet.y > display.contentHeight then
                bullet:removeSelf()
            end
        end
    end
end



local function fireBullet()
    -- Ammuksen luominen ja liikkeen määrittäminen pelaajan suunnan perusteella
    local bullet = display.newRect(player.x, player.y, 10, 5)
    bullet:setFillColor(0, 1, 0)

    local a = math.rad(player.rotation - 90)
    local bulletXSpeed = bulletSpeed * math.cos(a)
    local bulletYSpeed = bulletSpeed * math.sin(a)

    bullet.xSpeed = bulletXSpeed
    bullet.ySpeed = bulletYSpeed

    bulletGroup:insert(bullet)

    print("Bullet created at", bullet.x, bullet.y)
end
local function handleMouseClick(event)
    -- Hiiren klikkauksen käsittely ja ammuksen laukaisu
    if event.phase == "began" then
        fireBullet()
        print("Bullet fired!")
    end
end
local function handleKey(event)
    -- Näppäinpainallusten käsittely pelaajan liikkumiseksi
    if event.phase == "down" or event.phase == "up" then
        local speedChange = (event.phase == "down") and playerSpeed or 0

        if event.keyName == "w" then
            playerYSpeed = -speedChange
        elseif event.keyName == "s" then
            playerYSpeed = speedChange
        elseif event.keyName == "a" then
            playerXSpeed = -speedChange
        elseif event.keyName == "d" then
            playerXSpeed = speedChange
        end
    end
    return true
end

function scene:create(event)
    local sceneGroup = self.view

    -- Pelaajan luominen
    player = display.newImage("Images/player.png", display.contentCenterX, display.contentCenterY)

    -- Kuuntelijoiden lisääminen tapahtumiin
    Runtime:addEventListener("mouse", trackPlayer)
    Runtime:addEventListener("key", handleKey)
    Runtime:addEventListener("enterFrame", updateMovement)
    Runtime:addEventListener("enterFrame", updateBullets)
    Runtime:addEventListener("touch", handleMouseClick)

end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Tapahtuu ennen kuin näkymä tulee näkyväksi
    elseif phase == "did" then
        -- Tapahtuu kun näkymä on kokonaan näkyvissä
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Tapahtuu ennen kuin näkymä poistuu näkyvistä
    elseif phase == "did" then
        -- Tapahtuu heti kun näkymä on kokonaan poissa näkyvistä
    end
end

function scene:destroy(event)
    local sceneGroup = self.view
    -- Tapahtuu ennen kuin näkymä tuhoutuu
end

-- Kuuntelijoiden lisääminen tapahtumiin
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
