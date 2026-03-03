local books = {
    book_tentacles             =   "point",
    book_brimstone             =   "point",
    book_sleep                 =   "point",
    book_temperature           =   "point",
    book_fish                  =   "point",
    book_fire                  =   "point",
    book_horticulture          =   "point",
    book_horticulture_upgraded =   "point",
    book_birds                 =  "target",
    book_silviculture          =  "target",
    book_light                 =  "target",
    book_light_upgraded        =  "target",
    book_research_station      =  "target",
    book_web                   =  "attack",
    book_rain                  =  "attack",
    -- book_moon                  =  "target",
    book_bees                  =  "attack",
    
}

local armor = {
    "armorwood",
    "footballhat",
    "woodcarvedhat",
    "cookiecutterhat",
    "hivehat",
    "wathgrithrhat",
    "armordragonfly",
    "armormarble",
    "armor_sanity"
}

local fishes = {}

for i = 1,9 do
    table.insert(fishes,"oceanfish_medium_"..i.."_inv")
    table.insert(fishes,"oceanfish_small_"..i.."_inv")
end

local goodfires = {
    "firestaff",
    "firepen",
    "armordragonfly",
    "lighter",
    "torch",
    "yellowamulet",
    "campfire",
    "firepit",
}

local goodcoldfires = {
    "icestaff",
    "icestaff2",
    "icestaff3",
    "icehat",
    "blueamulet",
    "coldfire",
    "coldfirepit",
}

local weapons = {
    "fence_rotator",
    "spear",
    "whip",
    "spear_wathgrithr",
    "tentaclespike",
    "hambat",
    "glasscutter",
    "nightstick",
    "boomerang",
    "rabbitkingspear",
    "trident",
}

local moonitems = {
    "bomb_lunarplant",
    "lunarplanthat",
    "alterguardianhat",
    "armor_lunarplant",
    "houndstooth_blowpipe",
    "wagpunkhat",
    "scraphat",
    "armorwagpunk",
    "glasscutter",
}

local plants = {
     "watermelon",
         "tomato",
        "pumpkin",
         "potato",
    "pomegranate",
         "pepper",
          "onion",
         "garlic",
       "eggplant",
    "dragonfruit",
           "corn",
         "carrot",
      "asparagus",
}

local spiders = {
    "warrior",
    "dropper",
    "hider",
    "spitter",
    "moon",
    "healer",
    "water"
}

local function toall(inst)
    if inst.components.finiteuses then
        inst.components.finiteuses:Use(1)
    end
    local owner = inst.components.inventoryitem.owner
    if owner then
        owner.components.sanity:DoDelta(-25)
    end
end

local function createinst(pos)
    local inst = SpawnPrefab("tophat_shadow_fx")
    inst.Transform:SetPosition(pos.x,pos.y,pos.z)
    inst:Hide()
    return inst
end

local fns = {
    book_tentacles = function(book,hz,pos)
        if not book:HasTag("canread") then return end
        local inst = createinst(pos)

        SpawnAt("fx_tentacles_under_book",book)
        inst:DoTaskInTime(2,function() 
            local tentacle = SpawnPrefab("tentacle")
            tentacle.Transform:SetPosition(pos.x,pos.y,pos.z)
            tentacle.sg:GoToState("attack_pre")
            toall(book)
            inst:Remove()
        end)
    end,

    book_brimstone = function(book,hz,pos)
        if not book:HasTag("canread") then return end
        local inst = createinst(pos)

        SpawnAt("fx_lightning_over_book",book)
        inst:DoTaskInTime(2,function() 
            local task = nil
            task = inst:DoPeriodicTask(0.5,function()
                local offset = FindWalkableOffset(pos,  math.random() * PI2, math.random(1,5), 8, false, true)
                if offset then
                    local lightning = SpawnPrefab("lightning")
                    lightning.Transform:SetPosition(pos.x+offset.x,0,pos.z+offset.z)
                    local ents = TheSim:FindEntities(pos.x+offset.x,pos.y,pos.z+offset.z, 3, AOE_ATTACK_MUST_TAGS, AOE_ATTACK_NO_TAGS)
                    for _,target in pairs(ents) do
                        if target.components.health then
                            if target.components.inventory then
                                local need_to_damage = true
                                for slot,equip in pairs(target.components.inventory.equipslots) do
                                    if not equip.components.armor and equip:HasTag("waterproofer") then
                                        need_to_damage = false
                                    end
                                end
                                if need_to_damage and target.prefab~="wx78" then
                                    target.components.health:DoDelta(-10)
                                end
                            end
                        end
                    end
                end
            end)
            inst:DoTaskInTime(5,function() task:Cancel() inst:Remove() end)

            toall(book)
        end)
    end,

    book_sleep = function(book,hz,pos)
        if not book:HasTag("canread") then return end
        local inst = createinst(pos)

        inst:DoTaskInTime(2,function() 
            SpawnAt("fx_book_sleep",book)
            local bomb = SpawnPrefab("sleepbomb")
            bomb.Transform:SetPosition(pos.x,pos.y,pos.z)
            bomb.components.complexprojectile:Launch(pos, book)
            toall(book)
            inst:Remove()
        end)
    end,

    book_silviculture = function(book,target,pos)
        if not book:HasTag("canread") then return end
        book:DoTaskInTime(2,function() 
            if target:IsValid() and target.components.inventory then
                local armor = SpawnPrefab(armor[math.random(#armor)])
                if armor then
                    armor.components.armor:SetPercent(math.random(25,75)*0.01)
                    target.components.inventory:Equip(armor)
                    SpawnAt("round_puff_fx_hi",target)
                end
            end
            toall(book)
        end)
    end,

    book_fish = function(book,hz,pos)
        if not book:HasTag("canread") then return end
        local inst = createinst(pos)
        
        SpawnAt("fx_fish_under_book",book)
        book:DoTaskInTime(2,function() 
            SpawnAt("fx_book_fish",inst)
            
            local task = nil
            task = inst:DoPeriodicTask(0.5,function()
                local offset = FindWalkableOffset(pos,  math.random() * PI2, math.random(1,5), 8, false, true)
                if offset then
                    if math.random(1,100)<80 then
                        local fish = SpawnPrefab(fishes[math.random(#fishes)])
                        fish.Transform:SetPosition(pos.x+offset.x,pos.y,pos.z+offset.z)
                        if fish.components.perishable then 
                            fish.components.perishable:ReducePercent(0.99)
                        end
                        local fx = SpawnAt("hermitcrab_fx_small",fish)
                        fx.Transform:SetScale(0.5,0.5,0.5)
                    else
                        local fish = SpawnPrefab("shark")
                        fish.Transform:SetPosition(pos.x+offset.x,pos.y,pos.z+offset.z)
                        SpawnAt("hermitcrab_fx_med",fish)
                    end
                end
            end)
            inst:DoTaskInTime(5,function() task:Cancel() inst:Remove() end)
            
            toall(book)

        end)
    end,

    book_fire = function(book,hz,pos)
        if not book:HasTag("canread") then return end
        local inst = createinst(pos)

        book:DoTaskInTime(2,function() 
            SpawnAt("fx_book_fire",book)
            SpawnAt("stafflight",book)
            
            local task = nil
            task = inst:DoPeriodicTask(0.5,function()
                local offset = FindWalkableOffset(pos,  math.random() * PI2, math.random(1,5), 8, false, true)
                if offset then
                    if math.random(1,100)<80 then
                        local fire = SpawnPrefab("stafflight")
                        fire.Transform:SetPosition(pos.x+offset.x,pos.y,pos.z+offset.z)
                        local fx = SpawnAt("round_puff_fx_hi",fire)
                        fx.Transform:SetScale(0.5,0.5,0.5)
                    else
                        local fire = SpawnPrefab(goodfires[math.random(#goodfires)])
                        fire.Transform:SetPosition(pos.x+offset.x,pos.y,pos.z+offset.z)
                        local fx = SpawnAt("round_puff_fx_hi",fire)
                    end
                end
            end)
            inst:DoTaskInTime(5,function() task:Cancel() inst:Remove() end)

            toall(book)

        end)
    end,

    book_birds = function(book,target,pos)
        if not book:HasTag("canread") then return end
        local pos = Vector3(target.Transform:GetWorldPosition())
        local inst = createinst(pos)
        SpawnAt("fx_book_bird",book)
        book:DoTaskInTime(2,function() 

            
            local task = nil
            task = inst:DoPeriodicTask(0.5,function()
                local offset = FindWalkableOffset(pos,  math.random() * PI2, math.random(1,5), 8, false, true)
                if offset then
                    local smallbird = SpawnPrefab("smallbird")
                    smallbird.Transform:SetPosition(pos.x+offset.x,pos.y,pos.z+offset.z)
                    local fx = SpawnAt("round_puff_fx_hi",smallbird)
                end
            end)
            inst:DoTaskInTime(2.5,function() task:Cancel() inst:Remove() end)

            toall(book)

        end)
    end,

    book_temperature = function(book,hz,pos)
        if not book:HasTag("canread") then return end
        local inst = createinst(pos)

        book:DoTaskInTime(2,function() 
            SpawnAt("fx_book_fire",book)
            SpawnAt("staffcoldlight",book)
            
            local task = nil
            task = inst:DoPeriodicTask(0.5,function()
                local offset = FindWalkableOffset(pos,  math.random() * PI2, math.random(1,5), 8, false, true)
                if offset then
                    if math.random(1,100)<80 then
                        local fire = SpawnPrefab("staffcoldlight")
                        fire.Transform:SetPosition(pos.x+offset.x,pos.y,pos.z+offset.z)
                        local fx = SpawnAt("round_puff_fx_hi",fire)
                        fx.Transform:SetScale(0.5,0.5,0.5)
                    else
                        local fire = SpawnPrefab(goodcoldfires[math.random(#goodcoldfires)])
                        fire.Transform:SetPosition(pos.x+offset.x,pos.y,pos.z+offset.z)
                        local fx = SpawnAt("round_puff_fx_hi",fire)
                    end
                end
            end)
            inst:DoTaskInTime(5,function() task:Cancel() inst:Remove() end)

            toall(book)

        end)
    end,

    book_horticulture = function(book,hz,pos)
        if not book:HasTag("canread") then return end
        book:DoTaskInTime(2,function() 
            local delta_theta = PI2 / 12
            for i = 1, 12 do
                local plant = SpawnPrefab("farm_plant_"..plants[math.random(#plants)])
                if math.random(0,100)<95 then
                    plant.components.growable:SetStage(5)
                else
                    plant.components.growable:SetStage(6)
                end
                if plant then
                    plant.Transform:SetPosition(pos.x + 2.1 * math.cos( i*delta_theta ), 0, pos.z - 2.1 * math.sin( i*delta_theta ))
                    local fx = SpawnAt("round_puff_fx_hi",plant)
                end
            end
            toall(book)
        end)
    end,

    book_horticulture_upgraded = function(book,hz,pos)
        if not book:HasTag("canread") then return end
        book:DoTaskInTime(2,function() 
            local delta_theta = PI2 / 12
            for i = 1, 12 do
                local plant
                if math.random(0,100)<95 then
                    plant = SpawnPrefab(plants[math.random(#plants)].."_oversized")
                else
                    plant = SpawnPrefab(plants[math.random(#plants)].."_oversized_rotten")
                end
                if plant then
                    plant.Transform:SetPosition(pos.x + 2.1 * math.cos( i*delta_theta ), 0, pos.z - 2.1 * math.sin( i*delta_theta ))
                    local fx = SpawnAt("round_puff_fx_hi",plant)
                end
            end
            toall(book)
        end)
    end,

    book_light = function(book,target,pos)
        if not book:HasTag("canread") then return end
        book:DoTaskInTime(2,function() 
            if target:IsValid() and target.components.inventory then
                local weapon = SpawnPrefab(weapons[math.random(#weapons)])
                if weapon then
                    if weapon.components.finiteuses then
                        weapon.components.finiteuses:SetPercent(math.random(25,75)*0.01)
                    elseif weapon.components.fueled then
                        weapon.components.fueled:SetPercent(math.random(25,75)*0.01)
                    end
                    target.components.inventory:Equip(weapon)
                    SpawnAt("round_puff_fx_hi",target)
                end
            end
            toall(book)
        end)
    end, 

    book_light_upgraded = function(book,target,pos)
        if not book:HasTag("canread") then return end
        book:DoTaskInTime(2,function() 
            if target:IsValid() and target.components.inventory then
                local item = SpawnPrefab(moonitems[math.random(#moonitems)])
                if item then
                    if item.components.armor then
                        item.components.armor:SetPercent(math.random(25,75)*0.01)
                    elseif item.components.finiteuses then
                        item.components.finiteuses:SetPercent(math.random(25,75)*0.01)
                    end
                    target.components.inventory:Equip(item)
                    SpawnAt("round_puff_fx_hi",target)
                end
            end
            toall(book)
        end)
    end, 

    book_bees = function(book,attacker,target)
        if target.slowtask ~= nil then
            target.slowtask:Cancel()
        end
        if target.canceltask ~= nil then
            target.canceltask:Cancel()
        end
        target.slowtask = nil
        target.canceltask = nil
        target.slowtask = target:DoPeriodicTask(1,function()
            local fx = SpawnAt("honey_trail",target)
            fx:SetVariation(math.random(1,7),math.random(10,17)*0.1,3)
        end)
        target.canceltask = target:DoTaskInTime(5,function()
            target.slowtask:Cancel()
        end)
        if target:HasTag("player") and not attacker:HasTag("noknockback") then
            target.sg:GoToState("knockback")
            target.Physics:SetMotorVel(20,0,0)
            target:DoTaskInTime(0.5,function() target.Physics:Stop() end)
            target.Transform:SetRotation(attacker.Transform:GetRotation())
            attacker:AddTag("noknockback")
            attacker:DoTaskInTime(5,function() attacker:RemoveTag("noknockback") end)
        end
    end,

    book_web = function(book,attacker,target)
        if target.spidertask ~= nil then
            target.spidertask:Cancel()
        end
        if target.canceltask ~= nil then
            target.canceltask:Cancel()
        end
        target.spidertask = nil
        target.canceltask = nil
        if target.components.inventory then
            local hat = SpawnPrefab("spiderhat")
            target.components.inventory:Equip(hat)
        end
        target.spidertask = target:DoPeriodicTask(0.5,function()
            local pos = Vector3(target.Transform:GetWorldPosition())
            local offset = FindWalkableOffset(pos,  math.random() * PI2, math.random(1,5), 8, false, true)
            if offset then
                local spider = SpawnPrefab("spider_"..spiders[math.random(#spiders)])
                spider.Transform:SetPosition(pos.x+offset.x,0,pos.z+offset.z)
                SpawnAt("round_puff_fx_hi",spider)
            end    
        end)
        target.canceltask = target:DoTaskInTime(1.5,function()
            target.spidertask:Cancel()
        end)
        if target:HasTag("player") and not attacker:HasTag("noknockback") then
            target.sg:GoToState("knockback")
            target.Physics:SetMotorVel(20,0,0)
            target:DoTaskInTime(0.5,function() target.Physics:Stop() end)
            target.Transform:SetRotation(attacker.Transform:GetRotation())
            attacker:AddTag("noknockback")
            attacker:DoTaskInTime(5,function() attacker:RemoveTag("noknockback") end)
        end
    end,

    book_rain = function(book,attacker,target)
        if target:HasTag("player") and not attacker:HasTag("noknockback") then
            target.sg:GoToState("knockback")
            target.Transform:SetRotation(attacker.Transform:GetRotation())
            target.Physics:SetMotorVel(30,0,0)
            RemovePhysicsColliders(target)
            target:DoTaskInTime(0.5,function() target.Physics:Stop() ChangeToCharacterPhysics(target) end)
            attacker:AddTag("noknockback")
            attacker:DoTaskInTime(10,function() attacker:RemoveTag("noknockback") end)
        end
    end,

    book_research_station = function(book,target,pos)
        if not book:HasTag("canread") then return end
        local pos = Vector3(target.Transform:GetWorldPosition())

        book:DoTaskInTime(2,function() 
            if target.components.inventoryitem then
                if math.random(1,2)==2 then
                    local pos = Vector3(target.Transform:GetWorldPosition())
                    local offset = FindWalkableOffset(pos,  math.random() * PI2, math.random(1,5), 3, false, true)
                    if offset then
                        local double = SpawnPrefab(target.prefab)
                        double.Transform:SetPosition(pos.x+offset.x,0,pos.z+offset.z)
                        SpawnAt("round_puff_fx_hi",double)
                    end   
                else
                    SpawnAt("round_puff_fx_hi",target)
                    target:Remove()
                end
                toall(book)
            end
        end)
    end,

}

local function anim(inst,target,caster)
    if caster~=nil and caster.sg~=nil then
        caster.sg:GoToState("book")
    else
        local caster = inst.components.inventoryitem.owner
        caster.sg:GoToState("book")
    end
end

local function NoSpellClient(inst)
    inst:RemoveComponent("spellcaster")
end

for book,value in pairs(books) do 
    AddPrefabPostInit(book,function(inst)
        inst:RemoveComponent("book")
        local spellcaster
        if value~="attack" then
            spellcaster = inst:AddComponent("spellcaster")
        end
        if not TheWorld.ismastersim then return end
        inst:AddComponent("equippable")

        local weapon = inst:AddComponent("weapon")
        weapon.damage = 25
        weapon.attackrange = 0.5
        weapon.hitrange = 0.5
        weapon:SetOnAttack(function(inst,attacker,target)
            if target:HasTag("player") and not attacker:HasTag("noknockback") then
                target.sg:GoToState("knockback")
                target.Physics:SetMotorVel(20,0,0)
                target:DoTaskInTime(0.5,function() target.Physics:Stop() end)
                target.Transform:SetRotation(attacker.Transform:GetRotation())
                attacker:AddTag("noknockback")
                attacker:DoTaskInTime(5,function() attacker:RemoveTag("noknockback") end)
            end
        end)


        if value == "target" then
            spellcaster.quickcast = true
            spellcaster:SetOnSpellCastFn(anim)
            if book~="book_research_station" then
                spellcaster.canuseontargets = true
                spellcaster.canuseonlocomotors = true
                spellcaster.canuseondead = false
                spellcaster.canuseonpoint = false

                spellcaster.canonlyuseonlocomotors = true
                spellcaster.canonlyuseonlocomotorspvp = true
            else
                spellcaster.canuseontargets = true
                spellcaster.canuseonlocomotors = false
                spellcaster.canuseondead = false
                spellcaster.canuseonpoint = false
                spellcaster.canonlyuseonrecipes = true
            end
            spellcaster:SetSpellFn(fns[book])
        elseif value == "point" then
            spellcaster.quickcast = true
            spellcaster:SetOnSpellCastFn(anim)
            spellcaster.canuseonpoint = true
            
            spellcaster:SetSpellFn(fns[book])
        elseif value == "attack" then
            weapon:SetOnAttack(fns[book])
        end

        inst.components.finiteuses:SetUses(3)
        inst.components.finiteuses:SetMaxUses(3)



        local e = inst.components.equippable
        local old = e.onequipfn
        local old_un = e.onunequipfn

        local function onequip(inst,owner)
            if old then old(inst,owner) end
            inst:AddTag("canread")
            if owner:HasTag("book_reader") then
                inst:AddTag("canread")
            else
                inst:RemoveTag("canread")
                SendModRPCToClient(GetClientModRPC("CLIENT","NOSPELLBOOKCLIENT"),owner.userid,inst)
            end
        end

        local function onunequip(inst,owner)
            if old_un then old_un(inst,owner) end
            
            inst:RemoveTag("canread")
        end

        e:SetOnEquip(onequip)
        e:SetOnUnequip(onunequip)
        
    end)
end

AddClientModRPCHandler("CLIENT","NOSPELLBOOKCLIENT",NoSpellClient)