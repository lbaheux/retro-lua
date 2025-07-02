local paddle
local ball
local bricks = {}
local brickWidth = 50
local brickHeight = 20
local rows = 5
local cols = 8
local isPlaying = false

function love.load()
    love.window.setMode(400, 600)
    resetGame()
end

function resetGame()
    -- Raquette
    paddle = {x = 150, y = 550, width = 100, height = 10, speed = 300}

    -- Balle
    ball = {x = 200, y = 300, size = 10, dx = 150, dy = -150}
    ball.speed = 200
    ball.dx = ball.speed
    ball.dy = -ball.speed

    -- Briques
    bricks = {}
    for i = 1, rows do
        for j = 1, cols do
            local brick = {
                x = (j - 1) * brickWidth,
                y = (i - 1) * brickHeight + 30,
                width = brickWidth - 2,
                height = brickHeight - 2,
                destroyed = false
            }
            table.insert(bricks, brick)
        end
    end
    isPlaying = false

--[[ DEBUG

    for i, brick in ipairs(bricks) do
        brick.destroyed = true
    end
    bricks[1].destroyed = false
]]

end

function love.update(dt)
    if isPlaying then
        -- Déplacement de la balle
        ball.x = ball.x + ball.dx * dt
        ball.y = ball.y + ball.dy * dt

        -- Collision mur gauche/droit
        if ball.x < 0 or ball.x + ball.size > 400 then
            ball.dx = -ball.dx
        end

        -- Collision mur haut
        if ball.y < 0 then
            ball.dy = -ball.dy
        end

        -- Collision raquette
        if checkCollision(ball, paddle) then
            ball.dy = -ball.dy
            ball.y = paddle.y - ball.size
            ball.speed = ball.speed * 1.025
        end

        -- Collision briques
        for _, brick in ipairs(bricks) do
            if not brick.destroyed and checkCollision(ball, brick) then
                brick.destroyed = true
                ball.dy = -ball.dy

                ball.speed = ball.speed * 1.025

                local angle = math.atan2(ball.dy, ball.dx)
                ball.dx = ball.speed * math.cos(angle)
                ball.dy = ball.speed * math.sin(angle)
                break
            end

        end

        -- Perdu
        if ball.y > 600 then
            resetGame()
        end

        -- Vérifie si toutes les briques sont détruites
        local win = true
        for _, brick in ipairs(bricks) do
            if not brick.destroyed then
                win = false
                break
            end
        end

        if win then
            isPlaying = false
        end
    end

    -- Déplacer la raquette
    if love.keyboard.isDown('left') then
        paddle.x = paddle.x - paddle.speed * dt
    elseif love.keyboard.isDown('right') then
        paddle.x = paddle.x + paddle.speed * dt
    end

    -- Contrainte des bords
    if paddle.x < 0 then paddle.x = 0 end
    if paddle.x + paddle.width > 400 then paddle.x = 400 - paddle.width end
end

function love.draw()
    -- Dessiner la raquette
    love.graphics.rectangle('fill', paddle.x, paddle.y, paddle.width, paddle.height)

    -- Dessiner la balle
    love.graphics.rectangle('fill', ball.x, ball.y, ball.size, ball.size)

    -- Dessiner les briques
    for _, brick in ipairs(bricks) do
        if not brick.destroyed then
            love.graphics.rectangle('fill', brick.x, brick.y, brick.width, brick.height)
        end
    end

    if not isPlaying then
        love.graphics.printf("Appuyez sur ESPACE pour commencer", 0, 300, 400, 'center')

        local allDestroyed = true
        for _, brick in ipairs(bricks) do
            if not brick.destroyed then
                allDestroyed = false
                break
            end
        end
        if allDestroyed then
            love.graphics.printf("Victoire", 0, 260, 400, 'center')
        end
    end
end

function love.keypressed(key)
    if key == 'space' and not isPlaying then
        isPlaying = true
    end
end

function checkCollision(a, b)
    return a.x < b.x + b.width and
           b.x < a.x + a.size and
           a.y < b.y + b.height and
           b.y < a.y + a.size
end



