local assets={
	Asset("ANIM", "anim/lavaarena_lucy.zip"),
}

local function DoSpecial(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    local targets = TheSim:FindEntities(pos.x, pos.y, pos.z, 1.1)
    if inst.quality == 2 then
        inst.rt = 1
        inst:DoPeriodicTask(0.5,function() 
            inst.thrower = nil
            inst.Transform:SetRotation(inst.Transform:GetRotation()-math.random(1,360))
        end)
    elseif inst.quality == 3 then
                local proj1 = SpawnAt("throwable_lucy",inst)
                local proj2 = SpawnAt("throwable_lucy",inst)
                proj1.thrower = inst.thrower
                proj1.Transform:SetRotation(inst.Transform:GetRotation()+7.5)
                proj2.thrower = inst.thrower
                proj2.Transform:SetRotation(inst.Transform:GetRotation()-7.5)
                proj1.AnimState:SetAddColour(0.5,1,0,0.8)
                proj1.AnimState:SetMultColour(0.5,1,0,0.8)
                proj2.AnimState:SetAddColour(0.5,1,0,0.8)
                proj2.AnimState:SetMultColour(0.5,1,0,0.8)

                proj1:DoPeriodicTask(0.1,function() 
                    proj1:ArmorShread(proj1)
                end)
                proj2:DoPeriodicTask(0.1,function() 
                    proj2:ArmorShread(proj2)
                end)

                
                proj1:DoTaskInTime(5,function() SpawnAt("lucy_transform_fx",proj1) proj1:Remove() end)
                proj2:DoTaskInTime(5,function() SpawnAt("lucy_transform_fx",proj2) proj2:Remove() end)
    elseif inst.quality == 4 then
                local proj1 = SpawnAt("throwable_lucy",inst)
                local proj2 = SpawnAt("throwable_lucy",inst)
                proj1.Physics:SetMotorVel(14,0,0)
                proj2.Physics:SetMotorVel(14,0,0)
                proj1.rt = 1
                proj2.rt = -1
                proj1.thrower = inst.thrower
                proj1.Transform:SetRotation(inst.Transform:GetRotation()+30)
                proj2.thrower = inst.thrower
                proj2.Transform:SetRotation(inst.Transform:GetRotation()-30)
                proj1.AnimState:SetAddColour(0,0.5,1,0.8)
                proj1.AnimState:SetMultColour(0,0.5,1,0.8)
                proj2.AnimState:SetAddColour(0,0.5,1,0.8)
                proj2.AnimState:SetMultColour(0,0.5,1,0.8)

                proj1:DoPeriodicTask(0.1,function() 
                    proj1:ArmorShread(proj1)
                end)
                proj2:DoPeriodicTask(0.1,function() 
                    proj2:ArmorShread(proj2)
                end)

                inst:DoPeriodicTask(0.5,function() 
                    proj1.Transform:SetRotation(proj1.Transform:GetRotation()-60*proj1.rt)
                    proj2.Transform:SetRotation(proj2.Transform:GetRotation()-60*proj2.rt)
                    proj1.rt = proj1.rt*-1
                    proj2.rt = proj2.rt*-1
                end)

                proj1:DoTaskInTime(5,function() SpawnAt("lucy_transform_fx",proj1) proj1:Remove() end)
                proj2:DoTaskInTime(5,function() SpawnAt("lucy_transform_fx",proj2) proj2:Remove() end)
    elseif inst.quality == 5 then
        for _,target in pairs(targets) do
            if not target:HasTag("player") 
            and not target:HasTag("playerghost") 
            and not target:HasTag("FX")
            and not target:HasTag("INLIMBO")
            and not target:HasTag("NOTARGET")
            and target:IsValid()
            and not target:HasTag("EPIC")
            and target.prefab~= "resurrectionstone"
            and target.prefab~= "thulecite" then
                local gold = SpawnAt("thulecite",target)
                SpawnAt("crab_king_shine",gold)
                target:Remove()
            end
        end
    elseif inst.quality == 6 then
        for _,target in pairs(targets) do
            if target.components.health and target ~= inst.thrower then
                target.components.health:Kill()
            end
        end
    end
end

local function ArmorShread(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    local targets = TheSim:FindEntities(pos.x, pos.y, pos.z, 1.1)
    local damage = 13.5
    if inst.thrower and inst.thrower.components.combat then
        damage = 13.5*(inst.thrower.components.combat.damagemultiplier or 1)
    end

    for _,target in pairs(targets) do
        if target.components.health and target.components.combat and target ~= inst.thrower then
            if target:HasTag("player") then
                target.components.combat:GetAttacked(inst, damage)
            else
                target.components.combat:GetAttacked(inst, damage*4)
            end
        end
        if target.components.inventory and target ~= inst.thrower then
            local armor = {}
                if target:IsValid() then
                    for slot,equip in pairs(target.components.inventory.equipslots) do
                        if equip.components.armor and equip:IsValid() then
                            table.insert(armor,equip)
                        end
                    end
                    if #armor > 0 then
                        for _,equip in pairs(armor) do
                            equip.components.armor:SetPercent(equip.components.armor:GetPercent()-0.03/#armor)
                        end
                    end
                end
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.thrower = nil
    inst.quality = nil 

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_lucy")
    inst.AnimState:SetBuild("lavaarena_lucy")
    inst.AnimState:PlayAnimation("spin_loop",true)
    inst.AnimState:SetDeltaTimeMultiplier(4)
	
	inst.Transform:SetSixFaced()

    local phys = inst.entity:AddPhysics()
    phys:SetSphere(1)
    phys:SetCollisionGroup(COLLISION.OBSTACLES)
	phys:SetCollisionMask(
		COLLISION.CHARACTERS
	)
    phys:SetMotorVel(12,0,0)

    MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.canbepickedup=false

    inst.ArmorShread = ArmorShread
    inst.DoSpecial = DoSpecial
    -- inst.StartTargeting = StartTargeting
	
	return inst
end

return Prefab("throwable_lucy",fn,assets)