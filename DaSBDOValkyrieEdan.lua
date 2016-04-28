DaSBDOValkyrie = { }
DaSBDOValkyrie.__index = DaSBDOValkyrie
DaSBDOValkyrie.Version = "1.2"
--Vitalic did majority of the leg work on this script. TY
DaSBDOValkyrie.Credits = "Vitalic"
DaSBDOValkyrie.CreditsLibs = "Edan"
DaSBDOValkyrie.Author = "DaS"


function DaSBDOValkyrie:Attack(monster, isPull)
    local player = GetSelfPlayer()
    if not monster or not player then
        self.combos = nil
        return
    end

    if isPull and player.IsActionPending then
        return
    end

    local distance = monster.Position.Distance2DFromMe - monster.BodySize - player.BodySize

    if distance > 1200 or not monster.IsLineOfSight then
        --self:CheckFireballStuck("Movement")
        Navigator.MoveTo(monster.Position)
        self.combos = nil
        return
    end

    if player.CurrentActionName == "BT_WAIT_HOLD_ON" then
        print("Stunned")
        self.combos = nil
        return
    end
end

    EdanScout.Update()
    player:FacePosition(monster.Position)

	--print(string.format("debug: pending %s action %s", player.IsActionPending, player.CurrentActionName))
    --print(string.format("ydiff: %s bodyheight %s", tostring(math.abs(player.Position.Y - monster.Position.Y)), tostring(monster.BodyHeight)))

    -- copy any variables you want to use in your combo routine here
    self.distance = distance
    self.player = player
    self.monster = monster
    self.ispull = isPull

	-- execute combos
    if self.combos == nil or coroutine.status(self.combos) == 'dead' then
        self.combos = coroutine.create(DaSBDOValkyrie.Combos)
    end

    local result,err = coroutine.resume(self.combos, self)
    if err then
        print("Combo error: "..err)
    end
end

function DaSBDOValkyrie:Combos()
    if self.player.IsActionPending then
        return
    end

    Navigator.Stop()
	--Farming Combo Celestial Spear (s+e) > Shield Throw (s+q and hold) > Breath of Elion (Shift + e) > forward slash (if boe is on cd)
    if ((EdanScout.MonstersInMeleeRange ~= 0 or EdanScout.MonstersInMeleeRange == 0 and self.player.ManaPercent > 20) or self.player.ManaPercent > 14) and EdanSkills.SkillUsableCooldown(VALKYRIE_CELESTIAL_SPEAR) then
        print("celestrial spear")
        EdanCombo.PressAndWait(ACTION_FLAG_MOVE_BACKWARD|ACTION_FLAG_SPECIAL_ACTION_2, self.monster.Position)
        --EdanCombo.Wait(1000) -- hidden aftercast
        return
    end


    if (EdanScout.MonstersInMeleeRange ~= 0 and self.player.Stamina > 500) and EdanSkills.SkillUsable(VALKYRIE_RIGHTEOUS_CHARGE) then
        if EdanSkills.SkillUsable(VALKYRIE_ULTIMATE_RIGHTEOUS_CHARGE) then
            print('righteous charge ult')
            EdanCombo.PressAndWait(ACTION_FLAG_MOVE_FORWARD|ACTION_FLAG_SPECIAL_ACTION_3, self.monster.Position)
        else
            print('righteous charge')
            EdanCombo.PressAndWait(ACTION_FLAG_MOVE_FORWARD|ACTION_FLAG_SPECIAL_ACTION_3, self.monster.Position)
        end
        return
    end

--~     if ((EdanScout.MonstersInMeleeRange ~= 0 and self.player.Stamina < 350) or self.player.Stamina < 400 or self.player.Stamina < 450 or self.player.Stamina < 500) and EdanSkills.SkillUsableCooldown(VALKYRIE_RIGHTEOUS_CHARGE) then
--~         print("righteous charge")
--~         EdanCombo.PressAndWait(ACTION_FLAG_MOVE_FORWARD|ACTION_FLAG_SPECIAL_ACTION_3, self.monster.Position)
--~         --EdanCombo.Wait(1000) -- hidden aftercast
--~         return
--~     end

--~     if ((EdanScout.MonstersInMeleeRange ~= 0 and self.player.Stamina < 350) or self.player.Stamina < 400 or self.player.Stamina < 450 or self.player.Stamina < 500) and EdanSkills.SkillUsableCooldown(VALKYRIE_ULTIMATE_RIGHTEOUS_CHARGE) then
--~         print("righteous charge ult")
--~         EdanCombo.PressAndWait(ACTION_FLAG_MOVE_FORWARD|ACTION_FLAG_SPECIAL_ACTION_3, self.monster.Position)
--~         --EdanCombo.Wait(1000) -- hidden aftercast
--~         return
--~     end

    if (EdanScout.MonstersInMeleeRange == 0) and EdanSkills.SkillUsable(VALKYRIE_PUNISHMENT) then
        if EdanSkills.SkillUsable(VALKYRIE_ULTIMATE_PUNISHMENT) then
            print('punishment ult')
            EdanCombo.PressAndWait(ACTION_FLAG_SPECIAL_ACTION_2, self.monster.Position)
        else
            print('punishment')
            EdanCombo.PressAndWait(ACTION_FLAG_SPECIAL_ACTION_2, self.monster.Position)
        end
        return
    end

    if (EdanScout.MonstersInMeleeRange == 0 and self.player.ManaPercent > 23) and EdanSkills.SkillUsableCooldown(VALKYRIE_SWORD_OF_JUDGMENT) then
        print("sword of judgment")
        EdanCombo.PressAndWait(ACTION_FLAG_MOVE_BACKWARD|ACTION_FLAG_SECONDARY_ATTACK, self.monster.Position)
        --EdanCombo.Wait(1000) -- hidden aftercast
        return
    end

	if (EdanScout.MonstersInMeleeRange == 0 and self.player.Stamina > 200) and EdanSkills.SkillUsableCooldown(VALKYRIE_SHARP_LIGHT) then
        print("sharp light")
        EdanCombo.PressAndWait(ACTION_FLAG_EVASION|ACTION_FLAG_MAIN_ATTACK, self.monster.Position)
        --EdanCombo.Wait(1000) -- hidden aftercast
        return
    end

    if (EdanScout.MonstersInMeleeRange == 0 and self.player.ManaPercent > 23) and EdanSkills.SkillUsable(VALKYRIE_SWORD_OF_JUDGMENT) then
        if EdanSkills.SkillUsable(VALKYRIE_ULTIMATE_SWORD_OF_JUDGMENT) then
            print('sword of judgment ult')
            EdanCombo.PressAndWait(ACTION_FLAG_MOVE_BACKWARD|ACTION_FLAG_SECONDARY_ATTACK, self.monster.Position)
        else
            print('sword of judgment')
            EdanCombo.PressAndWait(ACTION_FLAG_MOVE_BACKWARD|ACTION_FLAG_SECONDARY_ATTACK, self.monster.Position)
        end
        return
    end

    if EdanScout.MonstersInMeleeRange == 0 or EdanScout.MonstersInMeleeRange ~= 0 and (monster.HealthPercent < 20 or self.player.HealthPercent > 50 or self.player.ManaPercent > 30 or self.player.ManaPercent > 25) and EdanSkills.SkillUsableCooldown(VALKYRIE_SHIELD_THROW) then
        print("shield throw")
        EdanCombo.PressAndWait(ACTION_FLAG_SPECIAL_ACTION_2, self.player.CrosshairPosition)
        return
    end

    if self.player.HealthPercent < 40 and EdanSkills.SkillUsableCooldown(VALKYRIE_BREATH_OF_ELION) then
        print("breath of elion")
        EdanCombo.PressAndWait(ACTION_FLAG_EVASION|ACTION_FLAG_SPECIAL_ACTION_2)
        return
    end

	-- back up and get in guard and wait to heal
    if self.player.HealthPercent < 25 and (EdanScout.MonstersInMeleeRange > 0 or EdanScout.MonstersAggroed > 1) and EdanSkills.SkillUsableCooldown(VALKYRIE_GUARD) then
        print("guard")
        EdanCombo.PressAndWait(ACTION_FLAG_SPECIAL_ACTION_1, self.player.CrosshairPosition)
        return
    end

    -- meteor shower with sage's memory
--~     if #EdanScout.Monsters >= 3 and EdanSkills.SkillUsableCooldown(VALKYRIE_JUDGMENT_OF_LIGHT) then
--~         print("judgment of light")
--~         EdanCombo.UseSkill(VALKYRIE_JUDGMENT_OF_LIGHT)
--~         EdanCombo.WaitUntilDone()
--~         EdanCombo.Wait(200) -- hidden aftercast
--~         return
--~     end


    if EdanSkills.SkillUsableCooldown(VALKYRIE_JUDGMENT_OF_LIGHT) and (self.player.BlackRage < 100 and #EdanScout.Monsters >= 3) then
        if EdanSkills.SkillUsableCooldown(VALKYRIE_JUDGMENT_OF_LIGHT) then
			print("judgment of light")
			EdanCombo.UseSkill(VALKYRIE_JUDGMENT_OF_LIGHT)
			EdanCombo.WaitUntilDone()
			EdanCombo.Wait(200) -- hidden aftercast
			end
        return
    end

--~     if EdanSkills.SkillUsableCooldown(WITCH_FIREBALL) then
--~         print("Fireball")
--~         EdanCombo.SetActionState(ACTION_FLAG_MOVE_BACKWARD|ACTION_FLAG_MAIN_ATTACK, 300)

--~         if EdanScout.MonstersInMeleeRange == 0 then
--~             EdanCombo.WaitUntilNotDoing("^BT_Skill_Fireball_Cast_") -- full cast
--~         end

--~         EdanCombo.PressAndWait(ACTION_FLAG_SECONDARY_ATTACK, self.monster.Position)

--~         if self.player:HasBuffById(1001) and EdanSkills.SkillUsableCooldown(WITCH_FIREBALL_EXPLOSION) then
--~             print("Fireball Explosion")
--~             -- long skippable aftercast
--~             EdanCombo.SetActionStateAtPosition(ACTION_FLAG_SECONDARY_ATTACK, self.monster.Position, 700)
--~         end
--~         return
--~     end

--~     if self.player.ManaPercent > 30 and EdanSkills.SkillUsable(WITCH_LIGHTNING_CHAIN) then
--~         if EdanSkills.SkillUsable(WITCH_LIGHTNING_STORM) then
--~             print('Fast Lightning Chain for Storm')
--~             EdanCombo.SetActionStateAtPosition(ACTION_FLAG_EVASION|ACTION_FLAG_SECONDARY_ATTACK, self.monster.Position, 1500)
--~         else
--~             print('Lightning Chain')
--~             EdanCombo.HoldUntilDone(ACTION_FLAG_EVASION|ACTION_FLAG_SECONDARY_ATTACK, self.monster.Position)
--~         end

--~         if EdanSkills.SkillUsable(WITCH_LIGHTNING_STORM) then
--~             EdanCombo.PressAndWait(ACTION_FLAG_MAIN_ATTACK|ACTION_FLAG_SECONDARY_ATTACK, self.monster.Position)
--~         end
--~         return
--~     end

	-- use heavens echo buff
    if EdanSkills.SkillUsable(VALKYRIE_HEAVENS_ECHO) then
        print("heavens echo")
        EdanCombo.SetActionStateAtPosition(ACTION_FLAG_EVASION|ACTION_FLAG_SPECIAL_ACTION_1, self.monster.Position)
        return
    end

    -- autoattack with forward slash
    EdanCombo.SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD|ACTION_FLAG_MAIN_ATTACK, self.monster.Position, 500)

    return

end

function DaSBDOValkyrie:Roaming()
    local player = GetSelfPlayer()
    if not player then
        return
    end

    self.combos = nil

    if player.IsActionPending then
        return
    end

    if player.ManaPercent < 40 and EdanSkills.SkillUsableCooldown(VALKYRIE_VOW_OF_TRUST) then
        print("roaming vow of trust regen mana")
		Navigator.Stop()
        EdanCombo.UseSkill(VALKYRIE_VOW_OF_TRUST)
        EdanCombo.WaitUntilDone()
        return
    end

    if player.HealthPercent < 60 and EdanSkills.SkillUsableCooldown(VALKYRIE_BREATH_OF_ELION) then
        print("roaming healing breath of elion")
        Navigator.Stop()
        EdanCombo.UseSkill(VALKYRIE_BREATH_OF_ELION)
        EdanCombo.WaitUntilDone()
        return
    end

end
