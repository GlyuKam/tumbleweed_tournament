local function QueenFn(inst)
    if inst.components.health and inst.components.rolemanager then
        local rm = inst.components.rolemanager
        inst.components.health:DoDelta(5*rm.mult*(inst.components.combat.damagemultiplier or 1))
        rm.mult = rm.mult+(0.075^rm.mult)
        inst.components.combat.externaldamagemultipliers:SetModifier(inst, rm.mult)
    end
end

-- local function FoolFn(inst)
-- end

local function TreeFn(inst)
    if inst.components.combat and inst.components.rolemanager then

        local pos = inst:GetPosition()
        local attackers = TheSim:FindEntities(pos.x, pos.y, pos.z, 16) 
        for i, attacker in ipairs(attackers) do
            if attacker.components.combat and attacker.sg and attacker~=inst then
                SpawnAt("lucy_transform_fx",attacker)
                attacker.components.combat:SetTarget(inst)
            end
        end

    end
end

local function onattacked(inst,data)
    local fx = SpawnPrefab("bramblefx_armor")
    fx.entity:SetParent(inst.entity)
    if data.attacker and data.attacker.components.locomotor then
        local attacker = data.attacker
        if attacker.slowfn~=nil then
            attacker.slowfn:Cancel()
            attacker.vinefx:Remove()
        end
        local speed = attacker.components.locomotor.externalspeedmultiplier
        attacker.vinefx = SpawnPrefab("wormwood_vined_debuff")
        attacker.components.locomotor.externalspeedmultiplier = speed*0.5
        attacker.vinefx.entity:SetParent(attacker.entity)
        attacker.slowfn = attacker:DoTaskInTime(10,function()
            attacker.components.locomotor.externalspeedmultiplier = speed
            attacker.vinefx.AnimState:PlayAnimation("spike_pst")
            attacker.vinefx:ListenForEvent("animover", inst.Remove)
        end)
    end
end

local rolesfn = {
    mask_queenhat = function(inst)
        inst.components.rolemanager:ClearRoles()

        inst.currentmask = "mask_queenhat"

        local fx = SpawnAt("crab_king_shine",inst)
        fx.Transform:SetScale(2,2,2)
        inst.crown.AnimState:SetAddColour(0.5,0,0,0.75)
        inst.components.locomotor.externalspeedmultiplier = 1.1

        inst._queentask = nil
        inst._queentask = inst:DoPeriodicTask(2,function()
            if inst:IsValid() and inst.components.health and inst.components.combat then
                inst.components.health:DoDelta(-5*inst.components.rolemanager.mult*(inst.components.combat.damagemultiplier or 1))
            end
        end)
        inst:ListenForEvent("onattackother", QueenFn)
    end,
    mask_foolhat = function(inst)
        inst.components.rolemanager:ClearRoles()

        inst.currentmask = "mask_foolhat"

        local fx = SpawnAt("pillowfight_confetti_fx",inst)
        fx.Transform:SetScale(2,2,2)
        inst.crown.AnimState:SetAddColour(0,0,0.75,0.75)
        

        local dodger = inst:AddComponent("attackdodger")
        dodger:SetCooldownTime(5)
        dodger:SetOnDodgeFn(function() SpawnAt("pillowfight_confetti_fx",inst) end)

        inst._fooltask = nil

        inst.components.locomotor.externalspeedmultiplier = 1.3
        inst.components.combat.externaldamagetakenmultipliers:SetModifier(inst, 4)
        
    end,
    mask_treehat = function(inst)
        inst.components.rolemanager:ClearRoles()

        inst.currentmask = "mask_treehat"

        inst.armorpen = 2
        inst.components.combat.externaldamagemultipliers:SetModifier(inst, 0.85)
        
        inst:ListenForEvent("attacked", onattacked)
        TreeFn(inst)
        inst._treetask = inst:DoPeriodicTask(5,function()
            TreeFn(inst)
        end)

        local fx = SpawnAt("plant_dug_large_fx",inst)
        fx.Transform:SetScale(2,2,2)
        inst.crown.AnimState:SetAddColour(0,0.5,0,0.75)
        
    end, 
}

local RoleManager = Class(function(self, inst)
    self.owner = inst
    self.currentrole = nil

    self.mult = 1

end)

function RoleManager:SetCrown()
    self.owner.crown = SpawnPrefab("cotl_trinket")
    self.owner.crown.entity:AddSoundEmitter()
    self.owner.crown.entity:SetParent(self.owner.entity)
    self.owner.crown.Transform:SetPosition(0,3.5,0)
    self.owner.crown.AnimState:SetMultColour(0,0,0,0.75)
    self.owner.crown:AddTag("FX")
    self.owner.crown:AddTag("NOCLICK")
    self.owner.crown:RemoveComponent("inventoryitem")
end

function RoleManager:ClearRoles()
    if self.owner._queentask~=nil then
        self.owner._queentask:Cancel()
    end
    if self.owner._fooltask~=nil then
        self.owner._fooltask:Cancel()
    end
    if self.owner._treetask~=nil then
        self.owner._treetask:Cancel()
    end
    self.owner:RemoveComponent("attackdodger")
    self.owner.components.combat.externaldamagemultipliers:SetModifier(self.owner, 1)
    self.owner:RemoveEventCallback("onattackother", QueenFn)
    self.mult = 1

    self.owner:RemoveEventCallback("attacked", onattacked)
    self.owner.components.locomotor.externalspeedmultiplier = 1
    self.owner.components.combat.externaldamagetakenmultipliers:SetModifier(self.owner, 1)
    self.owner.components.combat.externaldamagemultipliers:SetModifier(self.owner, 1)
    self.owner.armorpen = 1
    self.owner.components.health:SetAbsorptionAmount(0)
end

local COOLDOWN = 20

function RoleManager:SetRole(role)
    local fn = rolesfn[role]
    if fn then
        fn(self.owner)
        self.owner.components.net_role.cooldown:set(true)
        local crown = self.owner.crown
        crown.AnimState:SetMultColour(0,0,0,0.75)
        crown.cooldown = crown:DoTaskInTime(COOLDOWN,function() 
            SpawnAt("crab_king_shine",crown)
            crown.AnimState:SetMultColour(1,1,1,0.75)
            crown.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/gem_place")
            self.owner.components.net_role.cooldown:set(false)
        end)
    end
end

return RoleManager