cyberbossLaserAttackPhase3 = {}

--------------------------------------------------------------------------------
function cyberbossLaserAttackPhase3.enter()
  if not hasTarget() then return nil end

  local direction = util.randomDirection()

  return {
    windupTimer = 0.6,
    timer = config.getParameter("cyberbossLaserAttackPhase3.skillTime", 12),
    rotateInterval = config.getParameter("cyberbossLaserAttackPhase3.rotateInterval", 12),
    angleRange = direction * math.pi * 4.0,
    initialAngle = direction * math.pi / 4,
    angleAdjustment = -math.pi/2, --Because beams point down at 0 angle
    winddownTimer = 0.6,
    damagePerSecond = config.getParameter("cyberbossLaserAttackPhase3.damagePerSecond", 1600),
    bobInterval = 0.5,
    bobHeight = 0.1
  }
end

--------------------------------------------------------------------------------
function cyberbossLaserAttackPhase3.enteringState(stateData)
  animator.setAnimationState("firstBeams", "windup")
  animator.setAnimationState("cyberboss", "laserwindup")
  animator.setAnimationState("beamglow", "on")

  cyberbossLaserAttackPhase3.rotateBeams(stateData.angleAdjustment + stateData.initialAngle, true)
end

--------------------------------------------------------------------------------
function cyberbossLaserAttackPhase3.update(dt, stateData)
  cyberbossLaserAttackPhase3.bob(dt, stateData)

  if stateData.windupTimer > 0 then
    stateData.windupTimer = stateData.windupTimer - dt
    return false
  end

  if stateData.timer > 0 then
    animator.setLightActive("beam1", true)
    animator.setLightActive("beam1-2", true)
    animator.setLightActive("beam2", true)
    animator.setLightActive("beam2-2", true)

    local angleFactor = math.max(0, (stateData.rotateInterval - stateData.timer)) / stateData.rotateInterval
    local angle = stateData.angleRange * angleFactor + stateData.initialAngle

    cyberbossLaserAttackPhase3.rotateBeams(stateData.angleAdjustment + angle, true)

    local powerMultiplier = root.evalFunction("monsterLevelPowerMultiplier", monster.level())
    cyberbossLaserAttackPhase3.spawnProjectiles(angle, stateData.damagePerSecond * powerMultiplier * dt)

    stateData.timer = stateData.timer - dt
    if stateData.timer < 0 then
      animator.setAnimationState("firstBeams", "winddown")
      animator.setAnimationState("cyberboss", "laserwinddown")
    end

    return false
  end

  if stateData.winddownTimer > 0 then
    stateData.winddownTimer = stateData.winddownTimer - dt
    return false
  end

  return true
end

function cyberbossLaserAttackPhase3.leavingState(stateData)
  animator.setAnimationState("firstBeams", "idle")
  animator.setAnimationState("secondBeams", "idle")
  animator.setAnimationState("beamglow", "off")

  animator.setLightActive("beam1", false)
  animator.setLightActive("beam1-2", false)
  animator.setLightActive("beam2", false)
  animator.setLightActive("beam2-2", false)
end

function cyberbossLaserAttackPhase3.rotateBeams(angle, instant)
  --Beam 1
  animator.rotateGroup("beam1", angle, instant)
  animator.setLightPosition("beam1", vec2.rotate({0, 32}, angle))
  animator.setLightPosition("beam1-2", vec2.rotate({0, 20}, angle))

  --Beam 2
  animator.rotateGroup("beam2", angle + math.pi, instant)
  animator.setLightPosition("beam2", vec2.rotate({0, 32}, angle + math.pi))
  animator.setLightPosition("beam2-2", vec2.rotate({0, 20}, angle + math.pi))
end

function cyberbossLaserAttackPhase3.spawnProjectiles(angle, power)
  for x = 0, 1 do
    local newAngle = angle + math.pi * x
    local aimVector = {math.cos(newAngle), math.sin(newAngle)}
    world.spawnProjectile("crystalbeamdamage", mcontroller.position(), entity.id(), aimVector, true, {power = power, damageRepeatGroup = "crystalbossbeam"})
  end
end

function cyberbossLaserAttackPhase3.bob(dt, stateData)
  local bobFactor = (stateData.bobInterval - (stateData.timer % stateData.bobInterval)) / stateData.bobInterval
  local bobOffset = math.sin(bobFactor * math.pi * 2) * stateData.bobHeight
  local targetPosition = {self.spawnPosition[1], self.spawnPosition[2] + bobOffset}
  local toTarget = world.distance(targetPosition, mcontroller.position())

  mcontroller.controlApproachVelocity(vec2.mul(toTarget, 1/dt), 30)
end
