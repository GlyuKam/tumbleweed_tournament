-- TUNING.ABIGAIL_HEALTH_LEVEL1 = TUNING.ABIGAIL_HEALTH_LEVEL1/3
-- TUNING.ABIGAIL_HEALTH_LEVEL2 = TUNING.ABIGAIL_HEALTH_LEVEL2/3
-- TUNING.ABIGAIL_HEALTH_LEVEL3 = TUNING.ABIGAIL_HEALTH_LEVEL3/3
-- -- TUNING.ABIGAIL_DAMAGE.day    = TUNING.ABIGAIL_DAMAGE.day   *5
-- -- TUNING.ABIGAIL_DAMAGE.dusk   = TUNING.ABIGAIL_DAMAGE.dusk  *5
-- -- TUNING.ABIGAIL_DAMAGE.night  = TUNING.ABIGAIL_DAMAGE.night *5
-- TUNING.WENDY_DAMAGE_MULT = 1

-- local function UpdateDamage(inst)
--     local buff = inst:GetDebuff("elixir_buff")
--     local murderbuff = inst:GetDebuff("abigail_murder_buff")
-- 	local phase = (buff ~= nil and buff.prefab == "ghostlyelixir_attack_buff") and "night" or TheWorld.state.phase
--     local modified_damage = (TUNING.ABIGAIL_DAMAGE[phase] or TUNING.ABIGAIL_DAMAGE.day)*5
-- 	inst.components.combat.defaultdamage = modified_damage --/ (murderbuff and TUNING.ABIGAIL_SHADOW_VEX_DAMAGE_MOD or TUNING.ABIGAIL_VEX_DAMAGE_MOD) -- so abigail does her intended damage defined in tunings.lua --

--     inst.attack_level = (phase == "day" and 1)
-- 						or (phase == "dusk" and 2)
-- 						or 3

   
--     if murderbuff then
--         inst.components.planardamage:AddBonus(inst, TUNING.ABIGAIL_SHADOW_PLANAR_DAMAGE, "shadow_murder_planar")
--     else
--         inst.components.planardamage:AddBonus(inst, 0, "shadow_murder_planar")
--     end

--     -- If the animation fx was already playing we update its animation
--     local level_str = tostring(inst.attack_level)
--     if inst.attack_fx and not inst.attack_fx.AnimState:IsCurrentAnimation("attack" .. level_str .. "_loop") then
--         inst.attack_fx.AnimState:PlayAnimation("attack" .. level_str .. "_loop", true)
--     end
-- end

-- AddPrefabPostInit("abigail",function(inst)
--     if inst.components.health then
--         inst.components.health:StartRegen(10,1)
--     end
--     -- inst.UpdateDamage = UpdateDamage
-- end)

AddStategraphPostInit("wilson",function(sg)
    --Wendy
    sg.states.summon_abigail.tags = {"nodangle","canrotate"}
    sg.states.unsummon_abigail.tags = {"nodangle","canrotate"}
end)