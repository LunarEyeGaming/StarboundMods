--------------------------------------------------------------------------------
dieState = {}

function dieState.enterWith(params)
  if not params.die then return nil end
  
  rangedAttack.setConfig(config.getParameter("projectiles.deathexplosion.type"), config.getParameter("projectiles.deathexplosion.config"), 0.2)

  return {
    timer = 3,
    rotateInterval = 0.1,
    rotateAngle = 0.05,
    deathSound = true
  }
end

function dieState.enteringState(stateData)
  world.objectQuery(mcontroller.position(), 50, { name = "lunarbaselaser", callScript = "openLunarBaseDoor" })

  animator.setAnimationState("crystalhum", "off")
  
  animator.setAnimationState("cyberbossdamage", "stage"..currentPhase())
  
  animator.playSound("shatter")
  animator.playSound("death")

  --Spawn some initial shards
  for i = 1, 10 do
    local randAngle = math.random() * math.pi * 2
    local spawnPosition = vec2.add(mcontroller.position(), vec2.rotate({8, 0}, randAngle))
    local aimVector = {math.cos(randAngle), math.sin(randAngle)}
    local projectile = "invisibleprojectile"
    world.spawnProjectile(projectile, spawnPosition, entity.id(), aimVector, false, {
      speed = 10 + math.random() * 30,
      power = 0, 
      timeToLive = 3 + math.random() * 3
    })
  end
end

function dieState.update(dt, stateData)
  stateData.timer = stateData.timer - dt

  local angle = dieState.angleFactorFromTime(stateData.timer, stateData.rotateInterval) * stateData.rotateAngle - stateData.rotateAngle / 2
  animator.rotateGroup("all", angle, true)

  stateData.timer = stateData.timer - dt

  if stateData.timer < 0.2 and stateData.deathSound then
    animator.playSound("shatter")
    stateData.deathSound = false
  end

  if stateData.timer < 0 then
    self.dead = true

    --Explode into shards
    for i = 1, 1 do
      local randAngle = math.random() * math.pi * 0
      local spawnPosition = vec2.add(mcontroller.position(), vec2.rotate({math.random() * 0.2, 0}, randAngle))
      local aimVector = {math.cos(randAngle), math.sin(randAngle)}
      local projectile = "cyberbossdeath"
      local speed = math.random() * 0
      world.spawnProjectile(projectile, spawnPosition, entity.id(), aimVector, false, {
        speed = speed,
        power = 0
      })
  local cyberminis = world.entityQuery(mcontroller.position(), 60, { includedTypes = {"monster"} })
  for _,cybermini in pairs(cyberminis) do
    if world.monsterType(cybermini) == "cybermini" then
      world.callScriptedEntity(cybermini, "monster.setDropPool", nil)
      world.callScriptedEntity(cybermini, "status.setResource", "health", 0)
    end
  end
  return false
  end 
  end
end

--basic triangle wave
function dieState.angleFactorFromTime(timer, interval)
  local modTime = interval - (timer % interval)
  if modTime < interval / 2 then
    return modTime / (interval / 2)
  else
    return (interval - modTime) / (interval / 2) 
  end
end
