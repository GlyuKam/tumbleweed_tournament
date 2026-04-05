local function kill_fx(inst)
    inst.AnimState:PlayAnimation("close")
    inst:DoTaskInTime(.6, inst.Remove)
end

local SelfHarmer = Class(function(self,inst)
    self.inst = inst
    self.dmgmult = 1
end)

function SelfHarmer:ClearEffects()
    local inst = self.inst
    if inst.shield ~= nil then
        kill_fx(inst.shield)
        inst:RemoveTag("NOTARGET")
		inst.components.health.invincible = false
    end
    inst:DoTaskInTime(0.1,function() 
        inst.components.combat.externaldamagemultipliers:SetModifier(inst, 1)
    end)
end

function SelfHarmer:UpdateDamage(value)
    local inst = self.inst
    if self.dmgmult<2.5 then 
        self.dmgmult = self.dmgmult+value
        inst.components.combat.externaldamagemultipliers:SetModifier(inst, self.dmgmult)
    end
end

function SelfHarmer:SetShield()
    local inst = self.inst
    inst.shield = SpawnPrefab("forcefieldfx")
	inst.shield.entity:SetParent(inst.entity) 
    inst.shield.AnimState:SetMultColour(0,0,0.5,0.8)
	inst.shield.entity:AddFollower()
	inst:AddTag("NOTARGET")
	inst.components.health.invincible = true

    inst:DoTaskInTime(10,function()
        kill_fx(inst.shield)
        inst:RemoveTag("NOTARGET")
		inst.components.health.invincible = false
    end)
end

return SelfHarmer