PolarCoordinates = {
  origin = Vector(2.70, 0, -0.31),
  stretch = Vector(1.09, 1.0, 1.0)
}

function PolarCoordinates:FromWorld(world_pos)
  local vec = Vector(world_pos - self.origin)

  vec.x = vec.x / self.stretch.x
  vec.y = vec.y / self.stretch.y
  vec.z = vec.z / self.stretch.z

  return {
    radius = vec:magnitude(),
    theta = math.atan2(vec.z, vec.x)
  }
end

function PolarCoordinates:ToWorld(polar_pos)
  local vec = Vector(
    polar_pos.radius * math.cos(polar_pos.theta), 
    1.05,
    polar_pos.radius * math.sin(polar_pos.theta)
  )

  vec.x = vec.x * self.stretch.x
  vec.y = vec.y * self.stretch.y
  vec.z = vec.z * self.stretch.z

  return self.origin + vec
end

return PolarCoordinates