local ings = {
    'wormlight',
    "wormlight_lesser",
    'carrot',
    'carrot',
    'carrot',
    'berries',
    'berries',
    "berries_juicy",
    "berries_juicy",    
    'red_cap', 
    'blue_cap', 
    'green_cap', 
    'cactus_meat',
    'cactus_flower',
    'meat', 
    'cookedmeat', 
    'monstermeat', 
    'cookedmonstermeat', 
    'smallmeat',
    "honey",
    "honey",
    "honey",
    "honey",
    "honey",
    "pepper",
    "garlic",
    "fish",
    "eel",
    "barnacle",
    "egg", 
    "butterflywings", 
    "butter", 
    "ice",
    "ice",
    "dragonfruit",
    "dragonfruit",
    "mole",
    "rabbit",
    "plantmeat",
    "kelp",
    "moon_cap",
    "moon_cap",
    "moon_cap",
    "bird_egg",
    "cave_banana",
    "pomegranate",
    "durian",
    "watermelon",
    "trunk_summer",
    "trunk_winter",
    "fishmeat",
    "batnose",
    "potato",
    "tomato",
    "onion",
    "forgetmelots",
}

local rareings = {
    "lightninggoathorn",
    "spice_chili",
    "spice_garlic",
    "royal_jelly",
}

AddPrefabPostInit("warly",function(inst)
    local function GiveIngs(warly,data)
        if not data.target:HasTag("player") then
            local pos = Vector3(warly.Transform:GetWorldPosition())
            if math.random(1,100) >= 80 then
                local ing = SpawnPrefab(rareings[math.random(1,#rareings)])
                if ing then
                    ing.Transform:SetPosition(pos.x,10,pos.z)
                    -- for k, v in pairs(warly.components.inventory.itemslots) do
                    --     if ing.prefab == v.prefab and ing.prefab ~= "rabbit" and ing.prefab ~= "mole" then 
                    --         warly.components.inventory:GiveItem(ing)
                    --     end
                    -- end
                end
            else
                local ing = SpawnPrefab(ings[math.random(1,#ings)])
                if ing then
                    ing.Transform:SetPosition(pos.x,10,pos.z)
                    if ing.prefab == "mole" or ing.prefab == "rabbit" then
                        inst.sg:Stop()
                        ing.sg:GoToState("stunned", true)
                        ing.Transform:SetPosition(pos.x,3,pos.z)
                        inst.sg:Start()
                    end
                    -- for k, v in pairs(warly.components.inventory.itemslots) do
                    --     if ing.prefab == v.prefab and ing.prefab ~= "rabbit" and ing.prefab ~= "mole" then 
                    --         warly.components.inventory:GiveItem(ing)
                    --     end
                    -- end
                end
            end
        end
    end
    inst:ListenForEvent("onattackother",GiveIngs)
end)

AddPrefabPostInit("portablecookpot",function(inst)
    if inst.components.stewer then 
        inst.components.stewer.cooktimemult = 0
    end
    if inst.components.burnable then
        inst:RemoveComponent("burnable")
    end
end)

AddPrefabPostInit("portablespicer",function(inst)
    if inst.components.stewer then 
        inst.components.stewer.cooktimemult = 0
    end
    if inst.components.burnable then
        inst:RemoveComponent("burnable")
    end
end)