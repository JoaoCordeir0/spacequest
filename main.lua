-- Apelidos
local LG = love.graphics
local LK = love.keyboard

-- Variáveis globais
player = { posX = 0, posY = 0, spead = 200, img = nil }

-- Timers para limitação de tiros
shotTrue = true
activateMax = 0.2
timeShot = activateMax

-- Controlar/Armazenar os disparos
imgProj = nil
shots = {}

-- Timers para controle de inimigos
dtMaxCreateEnemy = 0.4
dtActualEnemy = dtMaxCreateEnemy
marginEnemy = 10

-- Controlar/Armazenar os inimigos
imgEnemy = nil
enemys = {}

-- Controle game over e pontuação
alive = true
points = 0

function love.load()
    -- Carrega o background do jogo
    imgBackground = LG.newImage('Insumos/Espaco.png')

    -- Carrega as informações do jogador 
    player.img = LG.newImage('Insumos/Nave.png')
    midH = (LG.getWidth() - player.img:getWidth()) / 2
    midV = (LG.getHeight() - player.img:getHeight()) / 2
    player.posX = midH
    player.posY = midV * 1.6   

    -- Imagem do projetil
    imgProj = LG.newImage('Insumos/projetil.png')

    -- Imagem do inimigo
    imgEnemy = LG.newImage('Insumos/Nave-Inimiga.png')
    marginEnemy = imgEnemy:getWidth() / 2

    -- Som do tiro
    shotSound = love.audio.newSource('Insumos/tiro.wav', 'static')
end

function love.draw()
    -- Renderiza o background do jogo
    LG.draw(imgBackground, 0, 0)

    if alive then
        -- Renderiza o player
        LG.draw(player.img, player.posX, player.posY)
        LG.print("Pontos: " .. points, 0, 0)
    else 
        enemys = {}
        LG.print("Pressione R para reiniciar ou ESC para sair!", 120, 380)
    end

    -- Renderiza os disparos
    for i, actual in ipairs(shots) do
        LG.draw(actual.img, actual.x, actual.y)
    end

     -- Renderiza os inimigos
     for i, actual in ipairs(enemys) do
        LG.draw(actual.img, actual.x, actual.y)
    end
end

function love.update(dt)
    -- Detecção da colisão da mecânica do jogo
    for i, actual in ipairs(enemys) do
        for j, proj in ipairs(shots) do
            if showColision(actual.x, actual.y, actual.img:getWidth(), actual.img:getHeight(), proj.x, proj.y, proj.img:getWidth(), proj.img:getHeight()) then
                table.remove(shots, j)
                table.remove(enemys, i)
                points = points + 10
            end
        end
        
        -- Verifica se o inimigo colidiu com a nave do jogador
        if showColision(actual.x, actual.y, actual.img:getWidth(), actual.img:getHeight(), player.posX, player.posY, player.img:getWidth(), player.img:getHeight()) then
            table.remove(enemys, i)
            alive = false
        end
    end

    -- Controle para sair do jogo a qualquer momento
    if LK.isDown('escape') then
        love.event.push('quit')
    end

    -- Movimentação da nave para direita e esquerda
    if LK.isDown('left', 'a') then
        if player.posX > 0 then
            player.posX = player.posX - (player.spead * dt)
        end
    elseif LK.isDown('right', 'd') then
        if player.posX < (LG.getWidth() - player.img:getWidth()) then
            player.posX = player.posX + (player.spead * dt)
        end
    end

    -- Controle de temporização dos disparos
    timeShot = timeShot - (1 * dt)
    if timeShot < 0 then
        shotTrue = true
    end

    -- Controle do disparo
    if LK.isDown('space', 'lctrl', 'rctrl') and shotTrue and alive then
        -- Criar uma instância do projetil
        newProj = { x = player.posX + player.img:getWidth() / 2, y = player.posY, img = imgProj}

        -- Barulho do tiro
        shotSound:play()

        table.insert(shots, newProj)
        shotTrue = false
            
        timeShot = activateMax        
    end

    -- Atualizar constantemente a posição do disparo
    for i, actual in ipairs(shots) do
        actual.y = actual.y - (200 * dt)
        
        -- Verifica se o projetil saiu da tela
        if actual.y < 0 then
            table.remove(shots, i)
        end
    end

    -- Controle da temporização da criação dos inimigos
    dtActualEnemy = dtActualEnemy - (1 * dt)
    if dtActualEnemy < 0 then
        dtActualEnemy = dtMaxCreateEnemy

        -- Cria uma instância do inimigo
        posDinamic = math.random(10 + marginEnemy, LG.getWidth() - (10 + marginEnemy))

        newEnemy = { x = posDinamic, y = - 30, img = imgEnemy}

        table.insert(enemys, newEnemy)
    end

    -- Atualizar a posição dos inimigos que descem na tela
    for i, actual in ipairs(enemys) do
        actual.y = actual.y + (200 * dt)

        if actual.y > LG.getHeight() then
            table.remove(enemys, i)
        end
    end

    -- Reinicia o jogo se R for pressionado
    if not alive and LK.isDown('r') then
        -- Limpar a lista de inimigos e projeteis 
        shots = {}
        enemys = {}
        
        -- Reiniciar os temporizadores 
        timeShot = activateMax
        dtActualEnemy = dtMaxCreateEnemy

        -- Posiciona a nave main no centro
        player.posX = midH
        player.posY = midV * 1.6

        -- Reinicia o placar 
        points = 0
        alive = true
    end
end 

function showColision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x2 + w2 >= x1 and x2 <= x1 + w1 and y2 + h2 >= y1 and y2 <= y1 + h1
end