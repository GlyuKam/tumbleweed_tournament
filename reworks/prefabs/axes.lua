local function ReticuleTargetFn()
	return Vector3(ThePlayer.entity:LocalToWorldSpace(6.5, 0, 0))
end

local function ReticuleMouseTargetFn(inst, mousepos)
	if mousepos ~= nil then
		local x, y, z = inst.Transform:GetWorldPosition()
		local dx = mousepos.x - x
		local dz = mousepos.z - z
		local l = dx * dx + dz * dz
		if l <= 0 then
			return inst.components.reticule.targetpos
		end
		l = 6.5 / math.sqrt(l)
		return Vector3(x + dx * l, 0, z + dz * l)
	end
end

local function ReticuleUpdatePositionFn(inst, pos, reticule, ease, smoothing, dt)
	local x, y, z = inst.Transform:GetWorldPosition()
	reticule.Transform:SetPosition(x, 0, z)
	local rot = -math.atan2(pos.z - z, pos.x - x) / DEGREES
	if ease and dt ~= nil then
		local rot0 = reticule.Transform:GetRotation()
		local drot = rot - rot0
		rot = Lerp((drot > 180 and rot0 + 360) or (drot < -180 and rot0 - 360) or rot0, rot, dt * smoothing)
	end
	reticule.Transform:SetRotation(rot)
end

-- NON reticule

local colours = {
    {"Патапон"},
    {0.8,0.8,0.8,0.8},
    {0.5,1,0,0.8},
    {0,0.5,1,0.8},
    {0.9,0.7,0,0.8},
    {0,0,0,1},
}

post_init_axes = {
    "lucy",
    "axe",
    "goldenaxe",
    "moonglassaxe",
    "multitool_axe_pickaxe",
    "shadow_battleaxe"
}

local function throwLucy(staff, doer, pos)
    local owner = staff.components.inventoryitem.owner or nil
    if owner:HasTag("axe_thrower") then
        if staff.components.rechargeable:IsCharged() then
            staff.components.rechargeable:Discharge(5)
            local proj = SpawnAt("throwable_lucy",staff)
            proj.thrower = owner
            proj:ForceFacePoint(pos.x,0,pos.z)
            
            proj.quality = staff.mult

            if staff.mult~=1 then
                proj.AnimState:SetAddColour(colours[staff.mult][1],colours[staff.mult][2],colours[staff.mult][3],colours[staff.mult][4])
                proj.AnimState:SetMultColour(colours[staff.mult][1],colours[staff.mult][2],colours[staff.mult][3],colours[staff.mult][4])
            end

            proj:DoPeriodicTask(0.1,function() 
                proj:ArmorShread(proj)
                if proj.quality~=3 and proj.quality~=4 then
                    proj:DoSpecial(proj)
                end
            end)
            if proj.quality==3 or proj.quality==4 then
                proj:DoSpecial(proj)
            end
           
            if proj.quality == 1 or proj.quality == 2 then
                proj:DoTaskInTime(2.5,function() SpawnAt("lucy_transform_fx",proj) if owner:IsValid() then proj:ForceFacePoint(owner.Transform:GetWorldPosition()) end end)
                proj:DoTaskInTime(5,function() SpawnAt("lucy_transform_fx",proj) proj:Remove() end)
            else 
                proj:DoTaskInTime(5,function() SpawnAt("lucy_transform_fx",proj) proj:Remove() end)
            end

            if staff.components.finiteuses then
                staff.components.finiteuses:Use(staff.components.finiteuses.total/10)
            end

        else
            if owner~= nil and owner.components.talker then
                owner.components.talker:Say("nuh uh")
            end
        end
    end
end

local function chop_anim(inst, chopper, target)
    if not TheWorld.ismastersim then return end
    local armorpenetration = chopper.armorpen or 1
    if chopper:IsValid() then
        chopper.AnimState:PlayAnimation("chop_loop")
    end

    local armor = {}
    if target.components.inventory and target:IsValid() then
        for slot,equip in pairs(target.components.inventory.equipslots) do
            if equip.components.armor and equip:IsValid() then
                table.insert(armor,equip)
            end
        end
        if #armor > 0 then
            for _,equip in pairs(armor) do
                equip.components.armor:SetPercent(equip.components.armor:GetPercent()-0.05*inst.mult*armorpenetration/#armor)
            end
        end
    end
end

local function NoSpellClient(inst)
    inst:RemoveComponent("spellcaster")
end

local function shouldhide(inst)
    if inst:HasTag("canthrow") then
        return false
    else
        return true
    end
end

for mult,axe in pairs(post_init_axes) do
    AddPrefabPostInit(axe,function(inst)
            
            inst.mult = mult

            if inst.components.weapon then
                inst.components.weapon:SetOnAttack(chop_anim)
            end

            inst:AddTag("throwable_axe")

            inst:AddComponent("rechargeable")

            inst:AddComponent("reticule")
            inst.components.reticule.reticuleprefab = "reticulelong"
            inst.components.reticule.pingprefab = "reticulelongping"
            inst.components.reticule.targetfn = ReticuleTargetFn
            inst.components.reticule.mousetargetfn = ReticuleMouseTargetFn
            inst.components.reticule.updatepositionfn = ReticuleUpdatePositionFn
            inst.components.reticule.validcolour = { 0.5, 0.5, 0, 1 }
            inst.components.reticule.invalidcolour = { .5, 0, 0, 1 }
            inst.components.reticule.ease = true
            inst.components.reticule.mouseenabled = true
            inst.components.reticule.ispassableatallpoints = true
            inst.components.reticule.shouldhidefn = shouldhide
 
            local spellcaster = inst:AddComponent("spellcaster")
            spellcaster.veryquickcast = true
            spellcaster.canuseontargets = false
            spellcaster.canuseonlocomotors = false
            spellcaster.canuseondead = false
            spellcaster.canuseonpoint = true
            spellcaster.canusefrominventory = false
            spellcaster:SetSpellFn(throwLucy)

            if inst.components.equippable then
                local e = inst.components.equippable
                local old = e.onequipfn
                local old_un = e.onunequipfn

                local function onequip(inst,owner)
                    old(inst,owner)
                    if owner:HasTag("axe_thrower") then
                        inst:AddTag("canthrow")
                    else
                        inst:RemoveTag("canthrow")
                        SendModRPCToClient(GetClientModRPC("CLIENT","NOSPELLCLIENT"),owner.userid,inst)
                    end
                end

                local function onunequip(inst,owner)
                    old_un(inst,owner)
                    inst:RemoveTag("canthrow")
                end

                e:SetOnEquip(onequip)
                e:SetOnUnequip(onunequip)
            end
    end)
end

AddClientModRPCHandler("CLIENT","NOSPELLCLIENT",NoSpellClient)