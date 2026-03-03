GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

PrefabFiles={"throwable_lucy"}

local available_chars = {
    "wilson",
    "willow",
    "wolfgang",
    "wendy",
    "wx78",
    "wickerbottom",
    "woodie",
    "wathgrithr",
    "webber",
    "winona",
    "warly",
    "wortox",
    "wormwood",
    "wurt",
    "wanda",
}

local reworks = {
    "axes",
    "bosses",
    "books"
}

for _,char in pairs(available_chars) do
    modimport("reworks/characters/"..char)
end

for _,file in pairs(reworks) do
    modimport("reworks/prefabs/"..file)
end

TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WINONA     = {"winona_remote"}
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WURT       = {"trident"}
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WEBBER     = {"spidereggsack","monstermeat","monstermeat"}
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WARLY      = {"glasscutter","portablecookpot_item","portablespicer_item"}
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WILSON     = {"wathgrithrhat"}
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WANDA      = {"pocketwatch_heal","pocketwatch_heal"}
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WX78       = {"wx78_moduleremover","wx78_scanner_item","umbrella"}
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WATHGRITHR = {}
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WOODIE     = {}

TUNING.WILLOW_LUNAR_FIRE_PLANAR_DAMAGE = 0
-- TUNING.FIRE_BURST_RANGE = TUNING.FIRE_BURST_RANGE*4

TUNING.WINONA_CATAPULT_MAX_RANGE = TUNING.WINONA_CATAPULT_MAX_RANGE*4
TUNING.WINONA_CATAPULT_HEALTH = TUNING.WINONA_CATAPULT_HEALTH*10

ACTIONS.TOSS.distance=100 
ACTIONS.CASTAOE.distance=100 
ACTIONS.CASTSPELL.distance=100 

TUNING.YELLOWSTAFF_STAR_DURATION = 5*60
TUNING.OPALSTAFF_STAR_DURATION = 5*60

TUNING.WORMWOOD_ROOT_TIME = 0.5
TUNING.ARMORBRAMBLE_DMG = 0
TUNING.ARMORBRAMBLE_DMG_PLANAR_UPGRADE = 0

TUNING.TENTACLE_HEALTH = TUNING.TENTACLE_HEALTH/5

--====================== PREFABS ================================================================

AddPlayerPostInit(function(inst)
    inst.iframes = false 

    if inst.components.grogginess then
        inst.components.grogginess.resistance = 100
    end
    inst:ListenForEvent("respawnfromghost",function()
        inst:DoTaskInTime(2,function() 
            if inst.components.grogginess then
                inst.components.grogginess.resistance = 100
            end
        end)
    end)
end)

-- AddStategraphPostInit("wilson",function(sg)
-- 	if not TheWorld.ismastersim then return end
--     local old = sg.states.hit.onenter
-- 	sg.states.hit.onenter = function(inst,frozen)
--         if inst.iframes then
--             return
--         else
--             old(inst,frozen)
--             inst.iframes = true
--             sg.states.hit.tags = { "pausepredict", "keepchannelcasting" }
--             inst:DoTaskInTime(0.5,function() 
--                 inst.iframes = false
--                 sg.states.hit.tags = { "busy", "pausepredict", "keepchannelcasting" } 
--             end)
--         end
-- 	end
-- end)

local function onattack_blue(inst,attacker,target)
    if target.components.freezable ~= nil and target:IsValid() then
        target.components.freezable:AddColdness(inst.icestaff_coldness or 1)
        target.components.freezable:SpawnShatterFX()
    end
end

AddPrefabPostInit("icestaff2",function(inst)
    inst.icestaff_coldness = 2
    if inst.components.weapon then
        inst.components.weapon:SetDamage(0)
        inst.components.weapon:SetRange(1, 1)
        inst.components.weapon:SetOnAttack(onattack_blue)
        inst.components.weapon:SetProjectile(nil)
    end
end)

AddPrefabPostInit("icestaff3",function(inst)
    inst.icestaff_coldness = 3
    if inst.components.weapon then
        inst.components.weapon:SetDamage(0)
        inst.components.weapon:SetRange(1, 1)
        inst.components.weapon:SetOnAttack(onattack_blue)
        inst.components.weapon:SetProjectile(nil)
    end
end)

AddComponentPostInit("combat", function(self)
    local _DoAttack = self.DoAttack
    function self:DoAttack(targ, weapon, projectile, stimuli, ...)
        if weapon == nil then
            weapon = self:GetWeapon()
        end

        
        stimuli = "blank"
        

        return _DoAttack(self, targ, weapon, projectile, stimuli, ...)
    end
end)

AddPrefabPostInit("deciduoustree",function(inst)
    inst:DoTaskInTime(1,function() inst:Remove() end)
end)

AddPrefabPostInit("saltlick",function(inst)
    inst:DoTaskInTime(1,function() inst:Remove() end)
end)

AddPrefabPostInit("klaus",function(inst)
    inst:DoPeriodicTask(10,function() if inst.enraged == true then inst:Remove() end end)
end)

jellies = {
    "voltgoatjelly",
    "voltgoatjelly_spice_chili",
    "voltgoatjelly_spice_garlic",
    "voltgoatjelly_spice_salt",
    "voltgoatjelly_spice_sugar",
}

for _,jelly in pairs(jellies) do
    AddPrefabPostInit(jelly,function(inst)
        if not TheWorld.ismastersim then return end
        if inst.components.edible then
            local old = inst.components.edible.oneaten

            local function Electricute(dish,...)
                old(dish,...)
                local eater = dish.components.inventoryitem.owner 
                if eater ~= nil then
                    if eater.electrictask then
                        eater.electrictask:Cancel()
                    end
                    if eater.components.combat then
                        local olddmg = eater.components.combat.damagemultiplier
                        if inst.prefab == "voltgoatjelly_spice_chili" then
                            eater.components.combat.damagemultiplier = 2
                        else
                            eater.components.combat.damagemultiplier = 1.75
                        end
                        eater.electrictask = eater:DoTaskInTime(TUNING.BUFF_ELECTRICATTACK_DURATION,function() eater.components.combat.damagemultiplier = olddmg end)
                    end
                end
            end

            inst.components.edible:SetOnEatenFn(Electricute)
        end       
    end)
end

AddPrefabPostInit("tornado",function(inst)
    if inst.components.locomotor then
        inst.components.locomotor.walkspeed = TUNING.TORNADO_WALK_SPEED * .33
        inst.components.locomotor.runspeed = TUNING.TORNADO_WALK_SPEED * .33
        inst:SetDuration(TUNING.TORNADO_LIFETIME*1.1)
    end
end)


AddPrefabPostInit("gunpowder",function(inst)
    if inst.components.explosive then
        inst.components.explosive.explosivedamage = 0
    end
end)

-- ================================= Statistics

local json = require "json"

local chars_count = {} 

for i, charname in ipairs(available_chars) do
    chars_count[charname] = 0
end

local unsafedata_file = "unsafedata/tumbleweed_data.json"

local file = io.open(unsafedata_file, "r")
if file then
    local loaded_data = file:read("*all")
    file:close() 

    if loaded_data and loaded_data ~= "" then 
        local decoded_data = json.decode(loaded_data)
        if decoded_data then
            if type(decoded_data) == "table" then
                for i, charname in ipairs(available_chars) do
                    if decoded_data[charname] ~= nil then
                        chars_count[charname] = decoded_data[charname]
                    end
                end
            else
                print("tumbleweed_data.json содержит не таблицу!")
            end
        else
            print("Ошибка декодирования JSON из tumbleweed_data.json")
        end
    else
        print("Файл tumbleweed_data.json пуст или не содержит данных.")
    end
else
    print("Файл tumbleweed_data.json не найден, используем значения по умолчанию.")
end




AddPrefabPostInit("world",function(inst)
    if not TheWorld.ismastersim then return end

    inst:ListenForEvent("ms_newplayercharacterspawned",function(world, data)
        inst:DoTaskInTime(0,function()

            local prefab = data.player.prefab

            for i,charname in ipairs(available_chars) do
                if prefab == charname then
                    chars_count[charname] = (chars_count[charname] or 0) + 1 
                    local json_chars = json.encode(chars_count)
                    local file_w = io.open(unsafedata_file, "w")

                    file_w:write(json_chars)
                    file_w:close()
                    break          
                end
            end
        end)
    end)
end)






-- local file = io.open("unsafedata/tumbleweed_data.txt", "w")
-- file:write("kipperkotik")
-- file:close()