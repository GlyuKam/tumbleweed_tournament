AddPrefabPostInit("wathgrithr",function(inst)
    inst:AddComponent("net_role")

    if TheWorld.ismastersim then
        inst:AddComponent("rolemanager")
        inst._queentask = nil
        inst._fooltask  = nil
        inst._treetask  = nil
        inst.components.rolemanager:SetCrown()

        if inst.currentmask == nil then
            inst.components.rolemanager:SetRole("mask_foolhat")
            inst.currentmask = "mask_foolhat"
        end

        inst:ListenForEvent("death",function()
            inst.components.rolemanager:SetRole("mask_foolhat")
        end)

        inst:ListenForEvent("ms_playerleft",function()
            inst.components.rolemanager:SetRole("mask_foolhat")
        end)

    end

    if inst.components.battleborn then
        inst.components.battleborn:SetHealthEnabled(false)
    end
    if inst.components.combat then
        inst.components.combat.damagemultiplier = 1
        inst.components.health:SetAbsorptionAmount(0)
    end

end)

AddPrefabPostInit("spear_wathgrithr_lightning",function(inst)
    inst:DoTaskInTime(0,function() inst:Remove() end)
end)

AddPrefabPostInit("spear_wathgrithr_lightning_charged",function(inst)
    inst:DoTaskInTime(0,function() inst:Remove() end)
end)