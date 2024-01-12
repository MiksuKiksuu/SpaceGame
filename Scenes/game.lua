local composer = require("composer")

local scene = composer.newScene()

local player
local playerSpeed = 3
local playerXSpeed, playerYSpeed = 0, 0
local score = 0
local health = 100
local meteorLifeTime = 5000 -- Aikaraja millisekunneissa (esimerkiksi 5000 ms = 5 s)
local scoreText
local healthText
local enemy
local enemies = {}  -- Taulukko vihollisten tallentamiseen
local numEnemies = 2
local enemySpeed = 1


local bulletSpeed = 5
local bulletGroup = display.newGroup()-- Korvaa polku oikealla taustakuvan polulla



local function updateScore()
    if scoreText then
        scoreText.text = "Score: " .. score
    end
end

local function updateHealth()
    if healthText then
        healthText.text = "Health: " .. health
    end
end



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
    for i = bulletGroup.numChildren, 1, -1 do
        local bullet = bulletGroup[i]

        if bullet then
            bullet.x = bullet.x + bullet.xSpeed
            bullet.y = bullet.y + bullet.ySpeed

            local margin = 100
            if bullet.x < -margin or bullet.x > display.contentWidth + margin or bullet.y < -margin or bullet.y > display.contentHeight + margin then
                bullet:removeSelf()
            end

            for j = #enemies, 1, -1 do
                local enemy = enemies[j]

                if enemy and bullet then
                    local distance = math.sqrt((bullet.x - enemy.x)^2 + (bullet.y - enemy.y)^2)

                    if distance < 15 then
                        bullet:removeSelf()
                        enemy:removeSelf()
                        table.remove(enemies, j)
                        -- Lisää pisteitä tai muuta pelaajan tilaa tässä
                        score = score + 10
                        print("Score:", score)

                        -- Päivitä pistemäärä ja näyttö
                        updateScore()
                    end
                end
            end
        end
    end
end





local function createEnemy()
    for i = 1, numEnemies do
        enemy = display.newImage("Images/Player.png", math.random(display.contentWidth), math.random(display.contentHeight))
        table.insert(enemies, enemy)
    end
end



local function updateEnemies()
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        if enemy then
            -- Päivitä vihollisen sijainti kohti pelaajaa
            local deltaX = player.x - enemy.x
            local deltaY = player.y - enemy.y
            local angle = math.atan2(deltaY, deltaX)

            local enemyXSpeed = enemySpeed * math.cos(angle)
            local enemyYSpeed = enemySpeed * math.sin(angle)

            enemy.x = enemy.x + enemyXSpeed
            enemy.y = enemy.y + enemyYSpeed

            -- Päivitä vihollisen kääntyminen kohti pelaajaa
            local enemyRotation = math.deg(angle) + 90
            enemyRotation = enemyRotation % 360
            enemy.rotation = enemyRotation

            -- Tarkista törmäys pelaajaan
            local distanceToPlayer = math.sqrt((player.x - enemy.x)^2 + (player.y - enemy.y)^2)
            if distanceToPlayer < 20 then
                -- Törmäys pelaajaan, voit käsitellä sen mukaan (vähennä terveyttä, tee peli over jne.)
                health = health - 10
                print("Player hit! Health:", health)

                -- Voit myös poistaa vihollisen, jos haluat
                enemy:removeSelf()
                table.remove(enemies, i)

                -- Päivitä terveys ja näyttö
                updateHealth()
                end
            end
        end
    end




local function fireBullet()
    -- Ammuksen luominen ja liikkeen määrittäminen pelaajan suunnan perusteella
    local bullet = display.newRect(player.x, player.y, 10, 5)
    bullet:setFillColor(1, 1, 0)

    local a = math.rad(player.rotation - 90)
    local bulletXSpeed = bulletSpeed * math.cos(a)
    local bulletYSpeed = bulletSpeed * math.sin(a)

    bullet.xSpeed = bulletXSpeed
    bullet.ySpeed = bulletYSpeed

    bulletGroup:insert(bullet)

    print("Bullet created at", bullet.x, bullet.y)
end


local meteorGroup = display.newGroup()

local function spawnMeteor()
    local meteorImages = {
        "Images/meteor1.png",
        "Images/meteor2.png",
        "Images/meteor3.png",
        "Images/meteor4.png",
    }

    local randomMeteorImage = meteorImages[math.random(#meteorImages)] -- Valitse satunnaisesti kuva

    -- Luo ImageSheet meteorille
    local meteorWidth = 16
    local meteorHeight = 16

    local meteorSheetOptions = {
        width = meteorWidth,
        height = meteorHeight,
        numFrames = 1,  -- Koska käytetään yhtä kuvaa ilman animaatiota
    }

    local meteorImageSheet = graphics.newImageSheet(randomMeteorImage, meteorSheetOptions)

    -- Luo meteor käyttäen ImageSheetiä ja Spritea
    local meteor = display.newSprite(meteorImageSheet, { name = "meteor", start = 1, count = 1 })

    -- Aseta alkusijainti meteorille näytön ulkopuolelle
    local spawnSide = math.random(1, 4)
    if spawnSide == 1 then
        -- Ylhäältä
        meteor.x = math.random(display.contentWidth)
        meteor.y = -meteorHeight / 2
    elseif spawnSide == 2 then
        -- Oikealta
        meteor.x = display.contentWidth + meteorWidth / 2
        meteor.y = math.random(display.contentHeight)
    elseif spawnSide == 3 then
        -- Alhaalta
        meteor.x = math.random(display.contentWidth)
        meteor.y = display.contentHeight + meteorHeight / 2
    else
        -- Vasemmalta
        meteor.x = -meteorWidth / 2
        meteor.y = math.random(display.contentHeight)
    end

    -- Voit lisätä meteorille lisäasetuksia tarpeen mukaan, esimerkiksi meteor:toBack() jos haluat laittaa sen taustalle

    -- Lisää meteor näkyviin
    meteorGroup:insert(meteor)

    local deltaX = player.x - meteor.x
    local deltaY = player.y - meteor.y
    local a = math.atan2(deltaY, deltaX)

    local meteorSpeed = 2
    meteor.xSpeed = meteorSpeed * math.cos(a)
    meteor.ySpeed = meteorSpeed * math.sin(a)
end


local spawnThreshold = 500 -- Piste, jonka saavuttaminen aiheuttaa meteorin uudelleensijoittamisen
local meteorSpeed = 4

local function updateMeteors()
    for i = meteorGroup.numChildren, 1, -1 do
        local meteor = meteorGroup[i]

        if meteor then
            meteor.x = meteor.x + meteor.xSpeed
            meteor.y = meteor.y + meteor.ySpeed

            for j = bulletGroup.numChildren, 1, -1 do
                local bullet = bulletGroup[j]

                if bullet and meteor then
                    local distance = math.sqrt((bullet.x - meteor.x)^2 + (bullet.y - meteor.y)^2)

                    if distance < 15 then
                        bullet:removeSelf()
                        meteor:removeSelf()
                        -- score = score + 10
                        -- print("Score:", score)
                    end
                end
            end

            -- Tarkista, onko meteor saavuttanut spawnThresholdin
            if meteor.y > spawnThreshold then
                -- Siirrä meteor uuteen paikkaan
                meteor.x = math.random(display.contentWidth)
                meteor.y = -20

                -- Aseta uusi nopeus
                local deltaX = player.x - meteor.x
                local deltaY = player.y - meteor.y
                local a = math.atan2(deltaY, deltaX)
                meteor.xSpeed = meteorSpeed * math.cos(a)
                meteor.ySpeed = meteorSpeed * math.sin(a)
            end
        end
    end
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
    return scene
end

function scene:create(event)
    local sceneGroup = self.view
    scoreText = display.newText(sceneGroup, "Score: " .. score, display.contentCenterX, 20, native.systemFont, 16)
    healthText = display.newText(sceneGroup, "Health: " .. health, display.contentCenterX, 40, native.systemFont, 16)

    -- Päivitä tekstit alussa

    -- for i = 1, numEnemies do
    --     createEnemy()  -- Luo useita vihollisia
    -- end
    -- Pelaajan luominen
    player = display.newImage("Images/player.png", display.contentCenterX, display.contentCenterY)


    -- Kuuntelijoiden lisääminen tapahtumiin
    Runtime:addEventListener("mouse", trackPlayer)
    Runtime:addEventListener("key", handleKey)
    Runtime:addEventListener("enterFrame", updateMovement)
    Runtime:addEventListener("enterFrame", updateBullets)
    Runtime:addEventListener("enterFrame", updateMeteors)
    Runtime:addEventListener("touch", handleMouseClick)
    Runtime:addEventListener("enterFrame", updateEnemies)
    Runtime:addEventListener("enterFrame", createEnemy)

    timer.performWithDelay(2000, spawnMeteor, 0)

    sceneGroup:insert(player)
    -- sceneGroup:insert(enemy)
    sceneGroup:insert(meteorGroup)
    sceneGroup:insert(bulletGroup)
    -- sceneGroup:insert(enemies)

    updateScore()  -- Päivitä näytöllä näkyvä pistemäärä
    updateHealth()  -- Päivitä näytöllä näkyvä terveys

    scoreText:toFront()
    healthText:toFront()
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
