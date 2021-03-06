require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.positionSelectionInterval = config.getParameter("positionSelectionInterval")
  self.selectionCount = config.getParameter("selectionCount")
  self.timer = self.positionSelectionInterval
  self.bounds = probeBoundaries()
end

function update(dt)
  self.timer = math.max(0, self.timer - dt)
  if self.timer == 0 then
    for i = 0, self.selectionCount do
      rotMaterial()
    end
    self.timer = self.positionSelectionInterval
  end
end

function rotMaterial()
  local offset = {
    util.randomIntInRange({self.bounds[1], self.bounds[3]}), 
    util.randomIntInRange({self.bounds[2], self.bounds[4]})
  }
  if math.sqrt(offset[1] ^ 2 + offset[2] ^ 2) <= 2 then return end
  world.spawnProjectile("worldrot_es", vec2.add(mcontroller.position(), offset), nil)
end

function probeBoundaries()
  local minX = getSectorLimit({-1, 0})
  local minY = getSectorLimit({0, -1})
  local maxX = getSectorLimit({1, 0})
  local maxY = getSectorLimit({0, 1})
  return {-minX, -minY, maxX, maxY}
end

function getSectorLimit(direction)
  local distance = 0
  local position = mcontroller.position()
  while world.material(position, "foreground") ~= nil do
    position = vec2.add(position, direction)
    distance = distance + 1
  end
  
  return distance
end

function uninit()
  
end
