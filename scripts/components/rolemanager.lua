local function QueenFn(inst,data)
    if not data.target:HasTag("player") or (data.target._p_team_num and data.target._p_team_num:value()~=inst._p_team_num:value()) then
        local rm = inst.components.rolemanager
        inst.components.health:DoDelta(5*rm.mult)
        rm.mult = rm.mult+(0.3^rm.mult)
        inst.components.combat.externaldamagemultipliers:SetModifier(inst, rm.mult)
    end
end

local function Defend(inst)
    if inst.defender~=nil then
        inst.defender.components.health:DoDelta(-1)
    end
end

local function TreeFn(inst)
    if inst and inst._p_team_num then
        for _,player in pairs(AllPlayers) do
            if player._p_team_num:value() == inst._p_team_num:value() and player~=inst and player.prefab~="wathgrithr" then
                player.defender = inst
                player.vinefx = SpawnPrefab("wormwood_vined_debuff")
                player.vinefx.entity:SetParent(player.entity)
                player.components.health:SetMinHealth(player.components.health.maxhealth/4)

                player:ListenForEvent("attacked",Defend)
            end
        end
    end
end

local function UnTreeFn(inst)
    if inst and inst._p_team_num then
        for _,player in pairs(AllPlayers) do
            if player._p_team_num:value() == inst._p_team_num:value() and player~=inst and player.defender == inst then
                player.defender = nil
                if player.vinefx~=nil then 
                    player.vinefx.AnimState:PlayAnimation("spike_pst")
                    player.vinefx:ListenForEvent("animover", inst.Remove)
                    player.components.health:SetMinHealth(0)

                    player:RemoveEventCallback("attacked",Defend)
                end
            end
        end
    end
end

local rolesfn = {
    mask_queenhat = function(inst)
        inst.components.rolemanager:ClearRoles()

        inst:DoTaskInTime(0.1,function() 
            inst.currentmask = "mask_queenhat"

            local fx = SpawnAt("crab_king_shine",inst)
            fx.Transform:SetScale(2,2,2)
            inst.crown.AnimState:SetAddColour(0.5,0,0,0.75)
            inst.components.locomotor.externalspeedmultiplier = 1.1

            inst._queentask = nil
            inst._queentask = inst:DoPeriodicTask(4,function()
                if inst:IsValid() and inst.components.health and inst.components.combat then
                    inst.components.health:DoDelta(-5*inst.components.rolemanager.mult)
                end
            end)
            inst:ListenForEvent("onattackother", QueenFn)
        end)
    end,
    mask_foolhat = function(inst)
        inst.components.rolemanager:ClearRoles()

        inst:DoTaskInTime(0.1,function() 
            inst.currentmask = "mask_foolhat"

            local fx = SpawnAt("pillowfight_confetti_fx",inst)
            fx.Transform:SetScale(2,2,2)
            inst.crown.AnimState:SetAddColour(0,0,0.75,0.75)
            

            local dodger = inst:AddComponent("attackdodger")
            dodger:SetCooldownTime(5)
            dodger:SetOnDodgeFn(function() SpawnAt("pillowfight_confetti_fx",inst) end)

            inst._fooltask = nil

            inst.components.locomotor.externalspeedmultiplier = 1.5
            inst.components.combat.externaldamagetakenmultipliers:SetModifier(inst, 2)
        end)
    end,
    mask_treehat = function(inst)
        inst.components.rolemanager:ClearRoles()

        inst:DoTaskInTime(0.1,function() 
            inst.currentmask = "mask_treehat"

            inst.components.combat.externaldamagemultipliers:SetModifier(inst, 0.75)
            
            TreeFn(inst)

            local fx = SpawnAt("plant_dug_large_fx",inst)
            fx.Transform:SetScale(2,2,2)
            inst.crown.AnimState:SetAddColour(0,0.5,0,0.75)
        end)
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

    self.owner.components.locomotor.externalspeedmultiplier = 1
    self.owner.components.combat.externaldamagetakenmultipliers:SetModifier(self.owner, 1)
    self.owner.components.combat.externaldamagemultipliers:SetModifier(self.owner, 1)
    self.owner.components.health:SetAbsorptionAmount(0)
    UnTreeFn(self.owner)
end

local COOLDOWN = 10

function RoleManager:SetRole(role)
    local fn = rolesfn[role]
    if fn and role~=self.owner.currentmask then
        fn(self.owner)
        self.owner.components.singinginspiration:DoDelta(100)
        self.owner.components.net_role.cooldown:set(true)
        local crown = self.owner.crown
        crown.AnimState:SetMultColour(0,0,0,0.75)
        crown.cooldown = crown:DoTaskInTime(COOLDOWN,function() 
            SpawnAt("crab_king_shine",crown)
            crown.AnimState:SetMultColour(1,1,1,0.75)
            crown.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/gem_place")
            self.owner.components.net_role.cooldown:set(false)
        end)
    else
        self.owner.components.talker:Say("на кой чёрт мне менять роль на ту же самую?")
    end
end

return RoleManager