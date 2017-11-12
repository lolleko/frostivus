function CDOTA_BaseNPC:Marshall()
  local saveData = {}
  saveData.origin = self:GetOrigin()
  saveData.angles = self:GetAnglesAsVector()
  saveData.unitName = self:GetUnitName()
  saveData.health = self:GetHealth()
end

function CDOTA_BaseNPC:Unmarshall(data)
  self:SetOrigin(data.origin)
  self:SetAngles(data.angles.x, data.angles.y, data.angles.z)
  self:SetHealth(data.health)
end

function CDOTA_BaseNPC:IsWall()
  return false
end

function CDOTA_BaseNPC:IsSpiritTree()
  return false
end

function CDOTA_BaseNPC:IsDefenseBuilding()
  return false
end
