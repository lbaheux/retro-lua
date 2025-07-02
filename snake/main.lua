local cellSize = 20
local gridWidth = 20
local gridHeight = 20

local snake
local direction
local timer
local speed = 0.1

local food

local gameState = 'start'
local score = 0

function love.load()
    love.window.setMode(gridWidth * cellSize, gridHeight * cellSize)
    resetGame()
end

-- Réinitialise la partie
function resetGame()
    snake = {
        {x = math.floor(gridWidth / 2), y = math.floor(gridHeight / 2)}
    }
    direction = 'right'
    timer = 0
    spawnFood()
    score = 0
end

function love.update(dt)
    if gameState == 'playing' then
        timer = timer + dt
        if timer >= speed then
            timer = 0
            moveSnake()
            checkCollision()
        end
    end
end

function love.draw()
    if gameState == 'start' then
        -- Message d'acceuil
        love.graphics.printf("Appuyez sur une touche pour commencer", 0, gridHeight * cellSize / 2, gridWidth * cellSize, "center")
    elseif gameState == 'playing' then
        -- Dessine le snake
        for _, segment in ipairs(snake) do
            love.graphics.rectangle('fill', (segment.x - 1) * cellSize, (segment.y - 1) * cellSize, cellSize - 1, cellSize - 1)
        end

        -- Dessine la pomme
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle('fill', (food.x - 1) * cellSize, (food.y - 1) * cellSize, cellSize - 1, cellSize - 1)
        love.graphics.setColor(1, 1, 1)

        -- Affiche le score 
        love.graphics.print("Score: " .. score, 10, 10)
    end
end

function love.keypressed(key)
    if gameState == 'start' then
        -- Lance la partie au premier appui de touche
        gameState = 'playing'
        resetGame()
    else
        -- Change la direction du serpent
        if key == 'up' and direction ~= 'down' then direction = 'up' end
        if key == 'down' and direction ~= 'up' then direction = 'down' end
        if key == 'left' and direction ~= 'right' then direction = 'left' end
        if key == 'right' and direction ~= 'left' then direction = 'right' end
    end
end

function love.mousepressed(x, y, button)
    if gameState == 'start' then
        gameState = 'playing'
        resetGame()
    end
end

function moveSnake()
    local head = {x = snake[1].x, y = snake[1].y}

    -- Déplace la tête en fonction de la direction
    if direction == 'up' then head.y = head.y - 1 end
    if direction == 'down' then head.y = head.y + 1 end
    if direction == 'left' then head.x = head.x - 1 end
    if direction == 'right' then head.x = head.x + 1 end

    table.insert(snake, 1, head)

    -- Mange la pomme ou avance normalement
    if head.x == food.x and head.y == food.y then
        score = score + 1
        spawnFood()
    else
        table.remove(snake)
    end
end

function spawnFood()
    food = {
        x = math.random(1, gridWidth),
        y = math.random(1, gridHeight)
    }
end

function checkCollision()
    local head = snake[1]

    -- Collision murs
    if head.x < 1 or head.x > gridWidth or head.y < 1 or head.y > gridHeight then
        gameState = 'start'
        return
    end

    -- Collision corps
    for i = 2, #snake do
        if head.x == snake[i].x and head.y == snake[i].y then
            gameState = 'start'
            return
        end
    end
end






