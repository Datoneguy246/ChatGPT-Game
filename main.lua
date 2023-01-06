function love.load()
    player = {
      x = love.graphics.getWidth() / 2,
      y = love.graphics.getHeight() - 50,
      radius = 20,
      speed = 300,
      lives = 3,
      bullets = {} -- table to store bullets
    }
  
    enemies = {}
    enemy_spawn_rate = 1 -- spawn one enemy per second
    enemy_spawn_timer = enemy_spawn_rate
    enemy_speed = 150 -- enemies move slightly slower than before
    enemy_acceleration = 0.5 -- enemy spawn rate increases by this amount per second
  
    game_over = false
  end
  
  function love.update(dt)
    if game_over then
        game_over_timer = game_over_timer - dt
        if game_over_timer <= 0 then
          -- reset game
          player.lives = 3
          player.x = love.graphics.getWidth() / 2
          player.bullets = {}
          enemies = {}
          enemy_spawn_timer = 0
          enemy_spawn_rate = 2
          enemy_speed = 100
          enemy_acceleration = 20
          game_over = false
        end
        return
      end
  
    -- move player based on keyboard input
    if love.keyboard.isDown("left") then
      player.x = player.x - player.speed * dt
    elseif love.keyboard.isDown("right") then
      player.x = player.x + player.speed * dt
    end
  
    -- move enemies based on their velocities
    for i, enemy in ipairs(enemies) do
      enemy.y = enemy.y + enemy.speed * dt
    end
  
    -- move bullets based on their velocities
    for i, bullet in ipairs(player.bullets) do
      bullet.y = bullet.y - bullet.speed * dt
  
      -- remove bullets that have gone off the screen
      if bullet.y < 0 then
        table.remove(player.bullets, i)
      end
    end
  
    -- check for collision between player bullets and enemies
    for i, enemy in ipairs(enemies) do
      for j, bullet in ipairs(player.bullets) do
        if checkCollision(enemy.x, enemy.y, enemy.width / 2, bullet.x, bullet.y, bullet.width / 2) then
          -- remove the enemy and bullet from the game
          table.remove(enemies, i)
          table.remove(player.bullets, j)
          break
        end
      end
    end
  
    -- check for collision between player and enemies
    for i, enemy in ipairs(enemies) do
      if checkCollision(player.x, player.y, player.radius, enemy.x, enemy.y, enemy.width / 2) then
        -- remove the enemy from the game
        table.remove(enemies, i)
        -- decrement player lives
        player.lives = player.lives - 1
      end
    end
  
    -- check if any enemies have reached the bottom of the screen
    for i, enemy in ipairs(enemies) do
      if enemy.y > love.graphics.getHeight() then
        -- remove the enemy from the game
        table.remove(enemies, i)
        -- decrement player lives
        player.lives = player.lives - 1
      end
    end
  
    -- update enemy spawn timer
    enemy_spawn_timer = enemy_spawn_timer - dt
    if enemy_spawn_timer <= 0 then
      -- reset timer and spawn a new enemy
      enemy_spawn_timer = enemy_spawn_rate
      enemy_spawn_rate = enemy_spawn_rate + enemy_acceleration * dt
      enemy = {
        x = math.random(0, love.graphics.getWidth() - 10), -- random x position, slightly smaller to fit within screen
        y = 50,
        width = 10,
        height = 40, -- slightly taller than before
        speed = enemy_speed
      }
      table.insert(enemies, enemy)
    end
  
    -- check if player has run out of lives
    if player.lives <= 0 then
      game_over = true
      game_over_timer = 5
    end
  end
  
  
  function love.draw()
    if game_over then
      -- draw "Game Over" in red text
      love.graphics.setColor(1, 0, 0) -- set color to red
      love.graphics.print("Game Over", love.graphics.getWidth() / 2 - 50, love.graphics.getHeight() / 2 - 20)
    else
      -- draw player as a circle
      love.graphics.setColor(1, 1, 1) -- set color to white
      love.graphics.circle("fill", player.x, player.y, player.radius)
  
      -- draw enemies as red triangles
      love.graphics.setColor(1, 0, 0) -- set color to red
      for i, enemy in ipairs(enemies) do
        love.graphics.polygon("fill", enemy.x, enemy.y, enemy.x + enemy.width, enemy.y, enemy.x + enemy.width / 2, enemy.y + enemy.height)
      end
  
      -- draw player bullets as yellow rectangles
      love.graphics.setColor(1, 1, 0) -- set color to yellow
      for i, bullet in ipairs(player.bullets) do
        love.graphics.rectangle("fill", bullet.x, bullet.y, bullet.width, bullet.height)
      end
  
      -- draw player lives in top left corner
      love.graphics.setColor(1, 1, 1) -- set color to white
      love.graphics.print("Lives: " .. player.lives, 10, 10)
    end
  end
  
  function love.keypressed(key)
    if key == "z" then
      -- create a new bullet and add it to the player's bullets table
      bullet = {
        x = player.x + player.radius / 2,
        y = player.y,
        width = 2,
        height = 10,
        speed = 500
      }
      table.insert(player.bullets, bullet)
    elseif key == "escape" then
      love.event.quit()
    end
  end
  
  -- function to check for collision between two circles
  function checkCollision(x1, y1, r1, x2, y2, r2)
    return (x1 - x2)^2 + (y1 - y2)^2 <= (r1 + r2)^2
  end
  
  function love.focus(f)
    if not f then
      print("LOST FOCUS")
    else
      print("GAINED FOCUS")
    end
  end
  
  function love.quit()
    print("Thanks for playing! Come back soon!")
  end
  
  