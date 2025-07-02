local windowWidth = 800
local windowHeight = 600


local paddleWidth = 10
local paddleHeight = 100
local paddleSpeed = 300

local leftPaddle = { x = 30, y = 250 }
local rightPaddle = { x = windowWidth - 40, y = 250 }

local ball = { x = 400, y = 300, size = 10, dx = 220, dy = 220 }

local leftScore = 0
local rightScore = 0

local singlePlayer = true -- solo (contre "IA") si true, 2 joueurs (ZQSD vs Flèches directionnelles) si false

local gamePaused = true



function love.load()
    love.window.setMode(windowWidth, windowHeight)
    love.graphics.setFont(love.graphics.newFont(30))
end

function love.update(dt)
    if not gamePaused then
        -- Déplacement balle
        ball.x = ball.x + ball.dx * dt
        ball.y = ball.y + ball.dy * dt

        -- Rebond haut/bas
        if ball.y < 0 or ball.y + ball.size > windowHeight then
            ball.dy = -ball.dy
        end

        -- Collision raquettes
        if checkCollision(ball, leftPaddle) then
            ball.dx = math.abs(ball.dx * 1.05)
        elseif checkCollision(ball, rightPaddle) then
            ball.dx = -math.abs(ball.dx * 1.05)
        end

        -- Point marqué
        if ball.x < 0 then
            rightScore = rightScore + 1
            ball.dx = 220
            ball.dy = 220
            resetBall()
        elseif ball.x > windowWidth then
            leftScore = leftScore + 1
            ball.dx = 220
            ball.dy = 220
            resetBall()
        end
    end

    -- Déplacement raquettes
    if love.keyboard.isDown("z") then
        leftPaddle.y = leftPaddle.y - paddleSpeed * dt
    elseif love.keyboard.isDown("s") then
        leftPaddle.y = leftPaddle.y + paddleSpeed * dt
    end

    if singlePlayer then
        -- IA : suit la balle
        local aiCenter = rightPaddle.y + paddleHeight / 2
        if ball.y < aiCenter - 10 then
            rightPaddle.y = rightPaddle.y - paddleSpeed * dt
        elseif ball.y > aiCenter +10 then
            rightPaddle.y = rightPaddle.y + paddleSpeed * dt
        end
    else
        if love.keyboard.isDown("up") then
            rightPaddle.y = rightPaddle.y - paddleSpeed * dt
        elseif love.keyboard.isDown("down") then
            rightPaddle.y = rightPaddle.y + paddleSpeed * dt
        end
    end

    -- Limites
    leftPaddle.y = math.max(0, math.min(windowHeight - paddleHeight, leftPaddle.y))
    rightPaddle.y = math.max(0, math.min(windowHeight - paddleHeight, rightPaddle.y))

    
end

function love.draw()

    local modeText = singlePlayer and "Mode : Solo (Tab pour changer)" or "Mode : 2 Joueurs (Tab pour changer)"
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(modeText, 0, windowHeight - 40, windowWidth, "center")

    -- Raquettes
    love.graphics.rectangle("fill", leftPaddle.x, leftPaddle.y, paddleWidth, paddleHeight)
    love.graphics.rectangle("fill", rightPaddle.x, rightPaddle.y, paddleWidth, paddleHeight)

    -- Balle
    love.graphics.rectangle("fill", ball.x, ball.y, ball.size, ball.size)

    -- Score
    love.graphics.print(leftScore, windowWidth / 4, 20)
    love.graphics.print(rightScore, 3 * windowWidth / 4, 20)

    if gamePaused then
        love.graphics.printf("Appuyez sur ESPACE pour jouer", 0, windowHeight / 2 - 30, windowWidth, "center")
    end
end

function love.keypressed(key)
    if key == "space" and gamePaused then
        gamePaused = false
    elseif key == "tab" then
        singlePlayer = not singlePlayer
        resetBall()
    end
end

function resetBall()
    ball.x = windowWidth / 2
    ball.y = windowHeight / 2
    ball.dx = -ball.dx
    ball.dy = (math.random(2) == 1 and 1 or -1) * 200

    leftPaddle.y = (windowHeight - paddleHeight) / 2
    rightPaddle.y = (windowHeight - paddleHeight) / 2
    gamePaused = true
end

function checkCollision(b, p)
    return b.x < p.x + paddleWidth and
           b.x + b.size > p.x and
           b.y < p.y + paddleHeight and
           b.y + b.size > p.y
end

