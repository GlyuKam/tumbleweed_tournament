local spiders = {
    "warrior",
    "dropper",
    "hider",
    "spitter",
    "moon",
    "healer",
    "water"
}

AddPrefabPostInit("webber",function(inst) 
    if inst.components.builder then
        for _,name in pairs(spiders) do
            inst.components.builder:UnlockRecipe("mutator_"..name)
        end
    end
end)

for _,name in pairs(spiders) do
    AddPrefabPostInit("spider_"..name,function(inst)
        if inst.components.health then
            inst.components.health:SetMaxHealth(150)
        end
    end)
    AddPrefabPostInit("mutator_"..name,function(inst) 
        if not TheWorld.ismastersim then return end
        local function SpawnSpiders(cookie)
            local eater = cookie.components.inventoryitem.owner 
            local spidertype = "spider_"..name
            local pos = Vector3(cookie.Transform:GetWorldPosition())
            for i = 1,math.random(1,2) do
                local spider = SpawnPrefab(spidertype)
                spider.Transform:SetPosition(pos.x,pos.y,pos.z)
                if eater and eater.prefab == "webber" then
                    eater.components.leader:AddFollower(spider)
                end
            end
            SpawnAt("poopcloud",cookie)
        end
        if inst.components.edible then
            inst.components.edible:SetOnEatenFn(SpawnSpiders)
        end
    end)
end