function init()
  if not entity.entityType() == "player" then
    effect.expire()
  end
  animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
  animator.setParticleEmitterEmissionRate("healing", config.getParameter("emissionRate", 3))
  animator.setParticleEmitterActive("healing", true)

  script.setUpdateDelta(5)

  self.healingRate = config.getParameter("healAmount", 30) / effect.duration()
end

function update(dt)
  status.modifyResource("health", config.getParameter("healAmount"))
end

function uninit()
  
end
