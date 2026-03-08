local function ResetPhysics(inst)
	inst.Physics:SetFriction(0.1)
	inst.Physics:SetRestitution(0.5)
	inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
	inst.Physics:SetCollisionMask(
		COLLISION.WORLD,
		COLLISION.OBSTACLES,
		COLLISION.SMALLOBSTACLES
	)
end

local function HasFriendlyLeader(inst, target, attacker)
    local target_leader = target.components.follower and target.components.follower:GetLeader()
    
    if target_leader ~= nil then

        if target_leader.components.inventoryitem then
            target_leader = target_leader.components.inventoryitem:GetGrandOwner()
        end

        local PVP_enabled = TheNet:GetPVPEnabled()
        return (target_leader ~= nil 
                and (target_leader:HasTag("player") 
                and not PVP_enabled)) or
                (target.components.domesticatable and target.components.domesticatable:IsDomesticated() 
                and not PVP_enabled) or
                (target.components.saltlicker and target.components.saltlicker.salted
                and not PVP_enabled)
    end

    return false
end

local function CanDamage(inst, target, attacker)
    if target.components.minigame_participator ~= nil or target.components.combat == nil then
		return false
	end

    --if attacker == target then -- NOTES(JBK): Uncomment this to able to hit yourself with physical damage.
    --    return true
    --end

    if target:HasTag("player") and not TheNet:GetPVPEnabled() then
        return false
    end

    if target:HasTag("playerghost") and not target:HasTag("INLIMBO") then
        return false
    end

    local leader = target.components.follower and target.components.follower:GetLeader()
    if target:HasTag("monster") and not TheNet:GetPVPEnabled() and 
       ((leader and leader:HasTag("player")) or target.bedazzled) then
        return false
    end

    if HasFriendlyLeader(inst, target, attacker) then
        return false
    end

    return true
end

local function OnThrownHit(inst, attacker, target)
    if inst.isfireattack then
        for i = 1, 3 do
            local fire = SpawnPrefab("houndfire")
            inst.components.lootdropper:FlingItem(fire)
        end
    end

	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 2.5, AOE_ATTACK_MUST_TAGS, AOE_ATTACK_NO_TAGS)

--local damage = inst.components.weapon.damage

    local olddamage = inst.components.weapon.damage

    inst.components.weapon.damage = function(inst, attacker, target)
        local damage = olddamage
        if attacker and attacker.components.skilltreeupdater and attacker.components.skilltreeupdater:IsActivated("wolfgang_dumbbell_throwing_2") then
            damage = damage * TUNING.SKILLS.WOLFGANG_DUMBELL_TOSS_2
        elseif attacker and attacker.components.skilltreeupdater and attacker.components.skilltreeupdater:IsActivated("wolfgang_dumbbell_throwing_1") then
            damage = damage * TUNING.SKILLS.WOLFGANG_DUMBELL_TOSS_1
        end
        return damage
    end

	for i, ent in ipairs(ents) do
        local canfreeze = false
	    if CanDamage(inst, ent, attacker) then
			if attacker ~= nil and attacker:IsValid() then
				attacker.components.combat.ignorehitrange = true
				attacker.components.combat:DoAttack(ent, inst, inst)
				attacker.components.combat.ignorehitrange = false
			else
				ent.components.combat:GetAttacked(attacker, inst.components.weapon.damage(inst, inst.components.complexprojectile.attacker, ent) )
			end
            canfreeze = true
        elseif attacker == ent then
            canfreeze = true -- NOTES(JBK): Allow the thrower to still freeze themselves for cooling benefits.
	    end
        if canfreeze then
            if inst.isiceattack and ent.components.freezable ~= nil and ent:IsValid() then -- NOTES(JBK): We need to check if ent is still valid for freezable:AddColdness after being attacked.
                ent.components.freezable:AddColdness(2)
            end
        end
	end
    
    inst.components.weapon.damage = olddamage

    attacker.components.hunger:DoDelta(-25)

    SpawnPrefab("round_puff_fx_sm").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.AnimState:PlayAnimation("land")
    inst.AnimState:PushAnimation("idle", true)

    inst:RemoveTag("NOCLICK")
    inst.persists = true

    inst.SoundEmitter:KillSound("spin_loop")
    inst.SoundEmitter:PlaySound(inst.impact_sound)

    inst.components.finiteuses:Use(inst.components.finiteuses.total/7)

    if inst.components.finiteuses:GetUses() > 0 then
        ResetPhysics(inst) 
        if attacker and attacker:IsValid() and attacker.components.inventory then
            attacker.components.inventory:Equip(inst)
        end
    end

end

local function onthrown(inst)
    inst:AddTag("NOCLICK")
    inst.persists = false

    local attacker = inst.components.complexprojectile.attacker
    if attacker then
        inst.components.mightydumbbell:DoAttackWorkout(attacker)
    end
    
    inst.AnimState:PlayAnimation("spin_loop", true)
    inst.SoundEmitter:PlaySound("wolfgang1/dumbbell/throw_twirl", "spin_loop")

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
	inst.Physics:SetCollisionMask(
		COLLISION.GROUND,
		COLLISION.OBSTACLES,
		COLLISION.ITEMS
	)
end

-- local function MakeTossable(inst)
--     if inst.components.complexprojectile == nil then
--         inst:AddComponent("complexprojectile")
--         inst.components.complexprojectile:SetHorizontalSpeed(60)
--         inst.components.complexprojectile:SetGravity(-35)
--         inst.components.complexprojectile:SetLaunchOffset(Vector3(1, 1, 0))
--         inst.components.complexprojectile:SetOnLaunch(inst.onthrown)
--         inst.components.complexprojectile:SetOnHit(inst.OnThrownHit)
-- 		inst.components.complexprojectile.ismeleeweapon = true
--     end
-- end

dumbbels = {
    -- "dumbbell",
    "dumbbell_golden",
    "dumbbell_marble",
    "dumbbell_gem",
    "dumbbell_heat",
    "dumbbell_redgem",
    "dumbbell_bluegem"
}

for _,bell in pairs(dumbbels) do
    AddPrefabPostInit(bell,function(inst)
        if not TheWorld.ismastersim then return end
        inst.onthrown = onthrown
        inst.OnThrownHit = OnThrownHit
        inst.task = nil
        inst.task = inst:DoPeriodicTask(1,function() 
            if inst.components.complexprojectile then
                inst.components.complexprojectile:SetHorizontalSpeed(50) 
                inst.components.complexprojectile:SetOnLaunch(inst.onthrown)
                inst.components.complexprojectile:SetOnHit(inst.OnThrownHit)
            else
                inst:AddComponent("complexprojectile")
                inst.components.complexprojectile:SetHorizontalSpeed(50)
                inst.components.complexprojectile:SetGravity(-35)
                inst.components.complexprojectile:SetLaunchOffset(Vector3(1, 1, 0))
                inst.components.complexprojectile:SetOnLaunch(inst.onthrown)
                inst.components.complexprojectile:SetOnHit(inst.OnThrownHit)
                inst.components.complexprojectile.ismeleeweapon = true
            end
        end)

        inst.components.equippable:SetOnEquip(function(inst, owner)
            owner.AnimState:OverrideSymbol("swap_object", inst.swap_dumbbell, inst.swap_dumbbell_symbol)
            owner.AnimState:Show("ARM_carry")
            owner.AnimState:Hide("ARM_normal")
        end)

        inst.components.equippable:SetOnUnequip(function(inst, owner)
            owner.AnimState:Hide("ARM_carry")
            owner.AnimState:Show("ARM_normal")
            
            if inst:HasTag("lifting") then
                owner:PushEvent("stopliftingdumbbell", {instant = true})
            end
        end)
    end)
end

-- AddPrefabPostInit("wolfgang",function(inst) 
--     inst:DoPeriodicTask(1,function()
--         if inst.components.hunger then
--             inst.components.hunger:DoDelta(-0.5)
--         end
--     end)
-- end)