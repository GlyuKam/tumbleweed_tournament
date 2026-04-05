AddStategraphPostInit("wilson",function(sg)
    --Wendy
    sg.states.summon_abigail.tags = {"nodangle","canrotate"}
    sg.states.unsummon_abigail.tags = {"nodangle","canrotate"}
end)

local function OnGetItem(inst, data)
    local item = data ~= nil and data.item or nil

    if item ~= nil then
        item.components.inventoryitem.keepondeath = item.prefab ~= ("amulet" or "reviver")
        item.components.inventoryitem.keepondrown = true
    end
end

local function OnLoseItem(inst, data)
    local item = data ~= nil and (data.prev_item or data.item)
    if item and item:IsValid() then
		item.components.inventoryitem.keepondeath = false
		item.components.inventoryitem.keepondrown = false
    end
end

AddPrefabPostInit("wendy",function(inst)
    if not TheWorld.ismastersim then return end
    
    inst.components.builder:UnlockRecipe("resurrectionstatue")
    inst:AddComponent("selfharmer")

    inst.components.combat.damagemultiplier = 1 

    inst:ListenForEvent("death",function()
        inst:DoTaskInTime(0.1,function() 
            inst.components.selfharmer:ClearEffects()
        end)
    end)

    inst:ListenForEvent("respawnfromghost",function()
        inst:DoTaskInTime(0.1,function() 
            for i =1,25 do 
                inst.components.selfharmer:UpdateDamage(0.01)
            end
            inst.components.selfharmer:SetShield()
        end)
    end)

	inst:ListenForEvent("itemget", OnGetItem)
    inst:ListenForEvent("equip", OnGetItem)
    inst:ListenForEvent("itemlose", OnLoseItem)
    inst:ListenForEvent("unequip", OnLoseItem)
end)

AddComponentPostInit("avengingghost", function(self)
    local oldStartAvenging = self.StartAvenging
    self.StartAvenging = function(...)
        oldStartAvenging(...)
        self._avengetime:set(7.5)
    end
end)