DaSBDOValkyrie = { }
DaSBDOValkyrie.__index = DaSBDOValkyrie
DaSBDOValkyrie.Version = "2.0.1 Shield Maiden"
DaSBDOValkyrie.Author = "DaS"

------------------- Spell ID's --------------------------

DaSBDOValkyrie.BREATH_OF_ELION = { 764, 763, 762 }
DaSBDOValkyrie.CELESTIAL_SPEAR = { 768, 767, 766, 765 }
DaSBDOValkyrie.CHARGING_SLASH = { 749, 748, 747 }
DaSBDOValkyrie.DIVINE_POWER = { 742, 741, 740, 739 }
DaSBDOValkyrie.FLURRY_OF_KICKS = { 725, 724, 723 }
DaSBDOValkyrie.FLYING_KICK = { 728, 727 }
DaSBDOValkyrie.FORWARD_SLASH = { 1478, 1477, 1476 }
DaSBDOValkyrie.GLARING_SLASH = { 761, 760, 759, 758, 757 }
DaSBDOValkyrie.HEAVENS_ECHO = { 746, 745, 744 }
DaSBDOValkyrie.JUDGEMENT_OF_LIGHT = { 774, 773, 772 }
DaSBDOValkyrie.JUST_COUNTER = { 722, 721, 720 }
DaSBDOValkyrie.PUNISHMENT = { 779, 778, 777, 776 }
DaSBDOValkyrie.RIGHTEOUS_CHARGE = { 752, 751, 750 }
DaSBDOValkyrie.SEVERING_LIGHT = { 1482, 1481, 1480, 1479 }
DaSBDOValkyrie.SHARP_LIGHT = { 1493, 1492, 1491, 1490 }
DaSBDOValkyrie.SHIELD_CHASE = { 738, 737, 736 }
DaSBDOValkyrie.SHIELD_STRIKE = { 1499, 1498, 1497 }
DaSBDOValkyrie.SHIELD_THROW = { 1486, 1485 }
DaSBDOValkyrie.SHINING_DASH = { 731 }
DaSBDOValkyrie.SIDEWAYS_CUT = { 1489, 1488, 1487 }
DaSBDOValkyrie.SKYWARD_STRIKE = { 756, 755, 754 }
DaSBDOValkyrie.SWORD_OF_JUDGEMENT = { 735, 734, 733, 732 }
DaSBDOValkyrie.FLOW_SHIELD_THROW = { 784 }
DaSBDOValkyrie.ULTIMATE_DIVINE_POWER = { 743 }
DaSBDOValkyrie.ULTIMATE_FLURRY_OF_KICKS = { 726 }
DaSBDOValkyrie.ULTIMATE_PUNISHMENT = { 780 }
DaSBDOValkyrie.ULTIMATE_RIGHTEOUS_CHARGE = { 753 }
DaSBDOValkyrie.ULTIMATE_SEVERING_LIGHT = { 1483 }
DaSBDOValkyrie.ULTIMATE_SHARP_LIGHT = { 771 }
DaSBDOValkyrie.ULTIMATE_SWORD_OF_JUDGEMENT = { 770 }
DaSBDOValkyrie.VOW_OF_TRUST = {783,782,781}
DaSBDOValkyrie.GUARD = { 718 }

---------------------------------------------------------------

setmetatable(DaSBDOValkyrie, {
    __call = function (cls, ...)
	return cls.new(...)
    end,
})


----------------------------------------------------------------
--Guard Actions
DaSBDOValkyrie.GuardActions = {
    BT_SKILL_DEFENSE_START = true,
    BT_SKILL_DEFENSE_ING = true,
    BT_SKILL_DEFENSE_ING_RE = true,
	BT_SKILL_DEFENSE_MOVE_F = true,
	BT_Skill_Defense_Start = true,
    BT_Skill_Defense_Ing = true,
    BT_Skill_Defense_Ing_RE = true,
	BT_Skill_Defense_Move_F = true,
	Defense_Start = true,
    Defense_Ing = true,
    Defense_Ing_RE = true,
	Defense_Move_F = true,
}
----------------------------------------------------------------

------------------ Setup New Valk and Constants ---------------------

function DaSBDOValkyrie.new()
    local instance = {}
    local self = setmetatable(instance, DaSBDOValkyrie)
    return self
end

----------------------------------------------------------------------


--------------------Stop the damn bot from KSing----------------------

function DaSBDOValkyrie:CombatPull()
	CombatPullState = { }
	CombatPullState.__index = CombatPullState
	CombatPullState.Name = "Combat - Pull"

	setmetatable(CombatPullState, {
		__call = function(cls, ...)
			return cls.new(...)
		end,
	} )

	function CombatPullState.new()
		local self = setmetatable( { }, CombatPullState)
		self.CurrentCombatActor = { Key = 0 }
		self._pullStarted = nil
		self._newTarget = false
		self.MobIgnoreList = PyxTimedList:New()
		self.Enabled = true
		self.Settings = {DontPull = {}}
		return self
	end

	function CombatPullState:Exit()
		local selfPlayer = GetSelfPlayer()
		if selfPlayer then
			selfPlayer:ClearActionState()
		end
	end

	function CombatPullState:NeedToRun()
		local selfPlayer = GetSelfPlayer()

		if not selfPlayer or self.Enabled == false then
			return false
		end

		if not selfPlayer.IsAlive or selfPlayer.IsSwimming then
			return false
		end

		local selfPlayerPosition = selfPlayer.Position
		local monsters = GetMonsters()
		table.sort(monsters, function(a, b) return a.Position:GetDistance3D(selfPlayerPosition) < b.Position:GetDistance3D(selfPlayerPosition) end)
		for k, v in pairs(monsters) do
			if v.IsVisible and
				v.IsAlive and
				math.abs(selfPlayer.Position.Y - v.Position.Y) < 250 and
				--v.CharacterStaticStatus.TribeType ~= TRIBE_TYPE_UNTRIBE and
				v.CanAttack and
				not self.MobIgnoreList:Contains(v.Key) and
				not table.find(Bot.Settings.PullSettings.DontPull, v.Name) and
				v.Position.Distance3DFromMe <= Bot.Settings.Advanced.PullDistance and
				(Bot.MeshDisabled == true or Bot.Settings.Advanced.IgnorePullBetweenHotSpots == false or
				Bot.Settings.Advanced.IgnorePullBetweenHotSpots == true and ProfileEditor.CurrentProfile:IsPositionNearHotspots(v.Position, Bot.Settings.Advanced.HotSpotRadius)) and
				ProfileEditor.CurrentProfile:CanAttackMonster(v) and
				((self.CurrentCombatActor ~= nil and self.CurrentCombatActor.Key == v.Key) or v.IsLineOfSight) and
				Navigator.CanMoveTo(v.Position) and
				( v.HealthPercent > 95)
				then
				if v.Key ~= self.CurrentCombatActor.Key then
					self._newTarget = true
				else
					self._newTarget = false
				end
				self.CurrentCombatActor = v
				return true
			end
		end

		return false
	end

	function CombatPullState:Run()
		if self._pullStarted == nil or self._newTarget == true then
			self._pullStarted = PyxTimer:New(Bot.Settings.Advanced.PullSecondsUntillIgnore)
			self._pullStarted:Start()
		end

		local selfPlayer = GetSelfPlayer()
		if selfPlayer and not selfPlayer.IsActionPending and not selfPlayer.IsBattleMode then
			print("Switch to battle mode !")
			selfPlayer:SwitchBattleMode()
		end

		if self._pullStarted:Expired() == true then
			self.MobIgnoreList:Add(self.CurrentCombatActor.Key, 600)
			print("Pull Added :" .. self.CurrentCombatActor.Key .. " to Ignore list")
			return
		end

		Bot.CallCombatAttack(self.CurrentCombatActor, true)
	end
end

----------------------------------------------------------------------

--------------------- Get Monster Count -------------------------------

function DaSBDOValkyrie:GetMonsterCount()
    local monsters = GetMonsters()
    local monsterCount = 0
    for k, v in pairs(monsters) do
        if v.IsAggro then
            monsterCount = monsterCount + 1
        end
    end
    return monsterCount
end

----------------------------------------------------------------------

----------------------------------------------------------------------

function DaSBDOValkyrie:StopGuard()
	local selfPlayer = GetSelfPlayer()

	if selfPlayer == nil then
        return
    end

	--Check for Guard if in guard sprint out of that shit
	if DaSBDOValkyrie.GuardActions[selfPlayer.CurrentActionName] ~= nil then
		selfPlayer:DoAction("RUN_SPRINT_FAST_ST", 1000)
		return
	end
end

--------------------- Main Combat Logic ------------------------------

function DaSBDOValkyrie:Attack(monsterActor)

    ------------------------- Create Local Skills for Combat ------------------------------------------

    local BREATH_OF_ELION = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.BREATH_OF_ELION)
    local CELESTIAL_SPEAR = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.CELESTIAL_SPEAR)
    local CHARGING_SLASH = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.CHARGING_SLASH)
    local DIVINE_POWER = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.DIVINE_POWER)
    local FLURRY_OF_KICKS = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.FLURRY_OF_KICKS)
    local FLYING_KICK = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.FLYING_KICK)
    local FORWARD_SLASH = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.FORWARD_SLASH)
    local GLARING_SLASH = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.GLARING_SLASH)
    local HEAVENS_ECHO = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.HEAVENS_ECHO)
    local JUDGEMENT_OF_LIGHT = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.JUDGEMENT_OF_LIGHT)
    local JUST_COUNTER = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.JUST_COUNTER)
    local PUNISHMENT = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.PUNISHMENT)
    local RIGHTEOUS_CHARGE = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.RIGHTEOUS_CHARGE)
    local SEVERING_LIGHT = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.SEVERING_LIGHT)
    local SHARP_LIGHT = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.SHARP_LIGHT)
    local SHIELD_CHASE = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.SHIELD_CHASE)
    local SHIELD_STRIKE = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.SHIELD_STRIKE)
    local SHIELD_THROW = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.SHIELD_THROW)
    local SHINING_DASH = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.SHINING_DASH)
    local SIDEWAYS_CUT = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.SIDEWAYS_CUT)
    local SKYWARD_STRIKE = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.SKYWARD_STRIKE)
    local SWORD_OF_JUDGEMENT = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.SWORD_OF_JUDGEMENT)
    local FLOW_SHIELD_THROW = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.FLOW_SHIELD_THROW)
    local ULTIMATE_DIVINE_POWER = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.ULTIMATE_DIVINE_POWER)
    local ULTIMATE_FLURRY_OF_KICKS = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.ULTIMATE_FLURRY_OF_KICKS)
    local ULTIMATE_PUNISHMENT = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.ULTIMATE_PUNISHMENT)
    local ULTIMATE_RIGHTEOUS_CHARGE = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.ULTIMATE_RIGHTEOUS_CHARGE)
    local ULTIMATE_SEVERING_LIGHT = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.ULTIMATE_SEVERING_LIGHT)
    local ULTIMATE_SHARP_LIGHT = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.ULTIMATE_SHARP_LIGHT)
    local ULTIMATE_SWORD_OF_JUDGEMENT = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.ULTIMATE_SWORD_OF_JUDGEMENT)
	local VOW_OF_TRUST = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.VOW_OF_TRUST)
    local GUARD = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.GUARD)

    -------------------------------------------------------------------------------------------------------------------

    local monsters = GetMonsters()
    local monsterCount = 0

    for k, v in pairs(monsters) do
        if v.IsAggro then
            monsterCount = monsterCount + 1
        end
    end

    if monsterActor then

        local selfPlayer = GetSelfPlayer()
        local actorPosition = monsterActor.Position

        if not selfPlayer.IsActionPending then

            --------------------------------------------------------------------------
            --                                                                      --
            -- BELOW 40% CAST EVASIVE MANEUVERS UNTILL CONSUMABLES HAVE HEALED YOU --
            --                                                                      --
            --------------------------------------------------------------------------

            if selfPlayer.HealthPercent <= 40  then
                -- Low on Health? Heal up!
                if BREATH_OF_ELION ~= 0 and selfPlayer.HealthPercent < 40 and not selfPlayer:IsSkillOnCooldown(BREATH_OF_ELION) and selfPlayer.ManaPercent >= 10 then
                   print("PANIC BELOW 40%! Casting Breath of Elion!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_EVASION + ACTION_FLAG_SPECIAL_ACTION_2, actorPosition, 1000)
                    return
                end
					if selfPlayer.Stamina > 200 then
						local rnd = math.random(1, 3)
						if rnd == 1 then
							if GetSelfPlayer():CheckCurrentAction("BT_Def_Dash_L_Ing_2") == false
							then GetSelfPlayer():DoActionAtPosition("BT_Def_Dash_L_Ing_2",GetSelfPlayer().CrosshairPosition, 1000)
							end
							print("Animation cancel time! To the left!")
							selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_LEFT + ACTION_FLAG_MAIN_ATTACK + ACTION_FLAG_SECONDARY_ATTACK , actorPosition, 1750)
							return
						end
						if rnd == 2 then
							print("Animation cancel time! To the right!")
							if GetSelfPlayer():CheckCurrentAction("BT_Def_Dash_R_Ing_2") == false
							then GetSelfPlayer():DoActionAtPosition("BT_Def_Dash_R_Ing_2",GetSelfPlayer().CrosshairPosition, 1000)
							end
							selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_RIGHT + ACTION_FLAG_MAIN_ATTACK + ACTION_FLAG_SECONDARY_ATTACK, actorPosition, 1750)
							return
						end
						if rnd == 3 then
							print("To the rear!")
							if GetSelfPlayer():CheckCurrentAction("BT_Def_Dash_B_Ing_2") == false
							then GetSelfPlayer():DoActionAtPosition("BT_Def_Dash_B_Ing_2",GetSelfPlayer().CrosshairPosition, 1000)
							end
							selfPlayer:SetActionStateAtPosition(ACTION_FLAG_EVASION + ACTION_FLAG_MOVE_BACKWARD, actorPosition, 1750)
							return
						end
					else
						print("Walk back!")
						selfPlayer:SetActionStateAtPosition(ACTION_FLAG_SPECIAL_ACTION_1  + ACTION_FLAG_MOVE_BACKWARD, actorPosition, 500)
						return
					end
            end

			if selfPlayer.HealthPercent <= 70 then
                -- Low on Health? Heal up!
                if BREATH_OF_ELION ~= 0 and selfPlayer.HealthPercent < 70 and not selfPlayer:IsSkillOnCooldown(BREATH_OF_ELION) and selfPlayer.ManaPercent >= 10 then
                   print("Casting Breath of Elion!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_EVASION + ACTION_FLAG_SPECIAL_ACTION_2, actorPosition, 1000)
                    return
                end
			end

            --RIGHTEOUS_CHARGE combo
            if actorPosition.Distance3DFromMe > monsterActor.BodySize + 150 then
                -- Charge the mob!
                -- Combo: Righteous Charge > Charging Slash > Celestial Spear > Shield Throw > Sword of Judgement >  Shield Throw > Shield Chase > Forward Slash
                if RIGHTEOUS_CHARGE ~= 0 and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 700 and actorPosition.Distance3DFromMe >= monsterActor.BodySize + 300
                    and not selfPlayer:IsSkillOnCooldown(RIGHTEOUS_CHARGE) and selfPlayer.ManaPercent >= 15 then
                    print("Charge Pulling! Righteous Charge Combo!")
                    print("Righteous Charge")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD + ACTION_FLAG_SPECIAL_ACTION_3, actorPosition)

                    -- CHARGING SLASH
                    if CHARGING_SLASH ~= 0 and (not selfPlayer:IsSkillOnCooldown(CHARGING_SLASH) or string.match(selfPlayer.CurrentActionName, "ChargingSlash"))
                        and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 and selfPlayer.ManaPercent > 20 then
                        print("Charging Slash")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_EVASION + ACTION_FLAG_MAIN_ATTACK, actorPosition, 1000)
                        return
                    end

					-- Celestial Spear Check
                    if CELESTIAL_SPEAR ~= 0 and not selfPlayer:IsSkillOnCooldown(CELESTIAL_SPEAR) and selfPlayer.ManaPercent > 20 then
                        print("Casting Celestial Spear!")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_2, actorPosition, 1000)
						--selfPlayer:UseSkillAtPosition(CELESTIAL_SPEAR, actorPosition)
                        return
                    end

                    -- SHIELD THROW
                    if SHIELD_THROW ~= 0 and not selfPlayer:IsSkillOnCooldown(SHIELD_THROW) and selfPlayer.ManaPercent >= 15 then
                        print("Throwing Shield!")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, actorPosition, 1000)
                        return
                    end

					-- Shield Chase
                    if SHIELD_CHASE ~= 0 and (not selfPlayer:IsSkillOnCooldown(SHIELD_CHASE) or string.match(selfPlayer.CurrentActionName, "ShieldChase")
                        or string.match(selfPlayer.CurrentActionName, "FrontSlice") or string.match(selfPlayer.CurrentActionName, "HeavenSpear")) and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 600
                        and selfPlayer.ManaPercent >= 15 then
                        print("Chasing Shield!")
						if GetSelfPlayer():CheckCurrentAction("BT_Def_Dash_F_Ing_2") == false
						then GetSelfPlayer():DoActionAtPosition("BT_Def_Dash_F_Ing_2",GetSelfPlayer().CrosshairPosition, 1)
						GetSelfPlayer():DoActionAtPosition("BT_Def_Dash_F_End_2",GetSelfPlayer().CrosshairPosition, 1)
						end
                        --selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD +  ACTION_FLAG_EVASION , actorPosition)
                        return
                    end

					-- SWORD OF JUDGEMENT
					if SWORD_OF_JUDGEMENT ~= 0 and (not selfPlayer:IsSkillOnCooldown(SWORD_OF_JUDGEMENT) or string.match(selfPlayer.CurrentActionName, "FrontSlice"))
						and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 and selfPlayer.ManaPercent > 20 then
						print("Sword of Judgment Spam!")
						selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SECONDARY_ATTACK, actorPosition, 1000)
						return
					end

					-- SHIELD THROW
                    if SHIELD_THROW ~= 0 and not selfPlayer:IsSkillOnCooldown(SHIELD_THROW) and selfPlayer.ManaPercent >= 15 then
                        print("Throwing Shield!")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, actorPosition, 1000)
                        return
                    end

					-- Flow: Shield Throw
					if FLOW_SHIELD_THROW ~= 0 and not selfPlayer:IsSkillOnCooldown(FLOW_SHIELD_THROW) then
						if string.match(selfPlayer.CurrentActionName, "ShieldThrow") then
							print("Flow: Shield throw!")
							selfPlayer:SetActionStateAtPosition(ACTION_FLAG_SECONDARY_ATTACK, actorPosition, 1750)
							return
						end
					end

                    -- Shield Chase
                    if SHIELD_CHASE ~= 0 and (not selfPlayer:IsSkillOnCooldown(SHIELD_CHASE) or string.match(selfPlayer.CurrentActionName, "ShieldChase")
                        or string.match(selfPlayer.CurrentActionName, "FrontSlice") or string.match(selfPlayer.CurrentActionName, "HeavenSpear")) and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 600
                        and selfPlayer.ManaPercent >= 15 then
                        print("Chasing Shield!")
						if GetSelfPlayer():CheckCurrentAction("BT_Def_Dash_F_Ing_2") == false
						then GetSelfPlayer():DoActionAtPosition("BT_Def_Dash_F_Ing_2",GetSelfPlayer().CrosshairPosition, 1)
						GetSelfPlayer():DoActionAtPosition("BT_Def_Dash_F_End_2",GetSelfPlayer().CrosshairPosition, 1)
                        --selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD +  ACTION_FLAG_EVASION , actorPosition)
						end
                        return
                    end

                    -- Forward Slash
                    if FORWARD_SLASH ~= 0 and (not selfPlayer:IsSkillOnCooldown(FORWARD_SLASH) or string.match(selfPlayer.CurrentActionName, "FrontSlice"))
                        and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 and selfPlayer.ManaPercent > 20 then
                        print("Forward Slash!")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD + ACTION_FLAG_MAIN_ATTACK , actorPosition, 1000)
                        return
                    end

				--Combo EX: Celestial Spear > Shield Throw > Sword of Judgement > Shield Throw > Shield Chase > Righteous Charge > Forward Slash > etc.
                elseif CELESTIAL_SPEAR ~= 0 and selfPlayer:IsSkillOnCooldown(RIGHTEOUS_CHARGE) and not selfPlayer:IsSkillOnCooldown(CELESTIAL_SPEAR)
                    and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 700 and actorPosition.Distance3DFromMe >= monsterActor.BodySize + 300
                    and selfPlayer.ManaPercent >= 15 then
                    print("Charge on CD! Using Celestial Spear Pull instead!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_2, actorPosition, 1000)
					--return
                --end

				-- SHIELD THROW
                if SHIELD_THROW ~= 0 and not selfPlayer:IsSkillOnCooldown(SHIELD_THROW) and selfPlayer.ManaPercent >= 15 then
                    print("Throwing Shield!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, actorPosition, 1000)
                    return
				end

				-- Shield Chase
                if SHIELD_CHASE ~= 0 and (not selfPlayer:IsSkillOnCooldown(SHIELD_CHASE) or string.match(selfPlayer.CurrentActionName, "ShieldChase")
                    or string.match(selfPlayer.CurrentActionName, "FrontSlice") or string.match(selfPlayer.CurrentActionName, "HeavenSpear")) and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 600
                    and selfPlayer.ManaPercent >= 15 then
					if GetSelfPlayer():CheckCurrentAction("BT_Def_Dash_F_Ing_2") == false
					then GetSelfPlayer():DoActionAtPosition("BT_Def_Dash_F_Ing_2",GetSelfPlayer().CrosshairPosition, 1)
					end
                    print("Chasing Shield!")
                    --selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD +  ACTION_FLAG_EVASION , actorPosition)
                    return
                end

                -- SWORD OF JUDGEMENT
                if SWORD_OF_JUDGEMENT ~= 0 and (not selfPlayer:IsSkillOnCooldown(SWORD_OF_JUDGEMENT) or string.match(selfPlayer.CurrentActionName, "FrontSlice"))
                    and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 and selfPlayer.ManaPercent > 20 then
                    print("Sword of Judgment Spam!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SECONDARY_ATTACK, actorPosition, 1000)
                    return
                end

				-- SHIELD THROW
                if SHIELD_THROW ~= 0 and not selfPlayer:IsSkillOnCooldown(SHIELD_THROW) and selfPlayer.ManaPercent >= 15 then
                    print("Throwing Shield!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, actorPosition, 1000)
                    return
                end

				-- Flow: Shield Throw
                if FLOW_SHIELD_THROW ~= 0 and not selfPlayer:IsSkillOnCooldown(FLOW_SHIELD_THROW) then
                    if string.match(selfPlayer.CurrentActionName, "ShieldThrow") then
                        print("Flow: Shield throw!")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_SECONDARY_ATTACK, actorPosition, 1750)
                        return
                    end
                end

                -- Forward Slash
                if FORWARD_SLASH ~= 0 and (not selfPlayer:IsSkillOnCooldown(FORWARD_SLASH) or string.match(selfPlayer.CurrentActionName, "FrontSlice"))
                    and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 and selfPlayer.ManaPercent > 20 then
                    print("Forward Slash!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD + ACTION_FLAG_MAIN_ATTACK , actorPosition, 1000)
                    return
                end
			end

                Navigator.MoveTo(actorPosition)
            else
                Navigator.Stop()

				-- Judge the these mother fuckers with Judgement of Light with monsters >=3 and black spirit 100%
				if JUDGEMENT_OF_LIGHT ~= 0 and not selfPlayer:IsSkillOnCooldown(JUDGEMENT_OF_LIGHT) and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 500
					and monsterCount >= 3 and selfPlayer.BlackRage == 100 and selfPlayer.ManaPercent > 40 then
					print("Maximum Black Rage and too many adds! Judge them!!!")
					selfPlayer:UseSkillAtPosition(JUDGEMENT_OF_LIGHT, actorPosition, 8000)
                    return
                end

				-- SEVERING_LIGHT on several adds
				if SEVERING_LIGHT ~= 0 and (not selfPlayer:IsSkillOnCooldown(SEVERING_LIGHT) or string.match(selfPlayer.CurrentActionName, "LightCut4"))
					and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 and selfPlayer.HealthPercent <= 75 and selfPlayer.ManaPercent > 20 and monsterCount >= 1 then
					print("Low Health gaining health back with severing light")
					selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MAIN_ATTACK + ACTION_FLAG_SECONDARY_ATTACK, actorPosition, 3000)
						if GetSelfPlayer():CheckCurrentAction("BT_skill_Lightcut_S") == false
						then
						print("sev light ult")
						GetSelfPlayer():DoActionAtPosition("BT_skill_Lightcut_S",GetSelfPlayer().CrosshairPosition, 100)
						end
					return
				end

                -- Sword of Judgement
                if SWORD_OF_JUDGEMENT ~= 0 and (not selfPlayer:IsSkillOnCooldown(SWORD_OF_JUDGEMENT) or string.match(selfPlayer.CurrentActionName, "FrontSlice"))
                    and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 and selfPlayer.ManaPercent > 20 then
                    print("Sword of Judgment Spam!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SECONDARY_ATTACK, actorPosition, 1000)
                    return
                end

                -- Low on Health? Heal up!
                if BREATH_OF_ELION ~= 0 and selfPlayer.HealthPercent < 70 and not selfPlayer:IsSkillOnCooldown(BREATH_OF_ELION) and selfPlayer.ManaPercent >= 10 then
                    print("Nothing going on and we are low on health! Casting Breath of Elion!")
                    selfPlayer:SetActionState(ACTION_FLAG_EVASION + ACTION_FLAG_SPECIAL_ACTION_2)
                    return
                end

                -- Shield Throw
                if SHIELD_THROW ~= 0 and (not selfPlayer:IsSkillOnCooldown(SHIELD_THROW) or string.match(selfPlayer.CurrentActionName, "RotationBash")
                    or string.match(selfPlayer.CurrentActionName, "FrontSlice") or string.match(selfPlayer.CurrentActionName, "HeavenSpear")) and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 600
                    and selfPlayer.ManaPercent >= 15 then
                    print("Throwing Shield!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, actorPosition)
                    return
                end

                -- Flow: Shield Throw
                if FLOW_SHIELD_THROW ~= 0 and not selfPlayer:IsSkillOnCooldown(FLOW_SHIELD_THROW) and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 600 then
                    if string.match(selfPlayer.CurrentActionName, "ShieldThrow") then
                        print("Flow: Shield throw!")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_SECONDARY_ATTACK, actorPosition, 1750)
                        return
                    end
                end

				--Check for Guard
				if DaSBDOValkyrie.GuardActions[selfPlayer.CurrentActionName] ~= nil then
					selfPlayer:DoAction("RUN_SPRINT_FAST_ST", 100)
					return
				end

                -- Mana low? Lets regain that shit!
                if FORWARD_SLASH ~= 0 and (not selfPlayer:IsSkillOnCooldown(FORWARD_SLASH) or string.match(selfPlayer.CurrentActionName, "RotationBash")
                    or string.match(selfPlayer.CurrentActionName, "HeavenSpear") or string.match(selfPlayer.CurrentActionName, "ShieldThrow"))
                    and selfPlayer.ManaPercent < 50 and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 then
                    print("Mana Low! Using Forward Slash to regain!")
                    --Remove guard selfPlayer:SetActionStateAtPosition(ACTION_FLAG_SPECIAL_ACTION_1, actorPosition)
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD + ACTION_FLAG_MAIN_ATTACK, actorPosition)
                    return
                end
            end
        end
    end
end

function DaSBDOValkyrie:Roaming()
    local selfPlayer = GetSelfPlayer()
    if not selfPlayer then
        return
    end

    --selfPlayer.combos = nil

    if selfPlayer.IsActionPending then
        return
    end

	local HEAVENS_ECHO = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.HEAVENS_ECHO)
	local VOW_OF_TRUST = SkillsHelper.GetKnownSkillId(DaSBDOValkyrie.VOW_OF_TRUST)

	--Check for Guard if in guard sprint out of that shit
	if DaSBDOValkyrie.GuardActions[selfPlayer.CurrentActionName] ~= nil then
		selfPlayer:DoAction("RUN_SPRINT_FAST_ST", 1000)
		return
	end

	-- Low on mana use vow of trust
    if VOW_OF_TRUST ~= 0 and not selfPlayer:IsSkillOnCooldown(VOW_OF_TRUST) and selfPlayer.ManaPercent <= 10 then
		if GetSelfPlayer():CheckCurrentAction("BT_ACTION_CHANGE") == false
		then Navigator.Stop()
		GetSelfPlayer():DoActionAtPosition("BT_ACTION_CHANGE",GetSelfPlayer().CrosshairPosition, 1)
		print("change stance")
		end
        print("Roaming, Low on mana, vow of trust!")
		Navigator.Stop()
		selfPlayer:UseSkill(VOW_OF_TRUST, 5000)
        selfPlayer:SetActionState(ACTION_FLAG_EVASION + ACTION_FLAG_JUMP, 5000)
        return
    end

    -- Heavens Echo Buff
    if HEAVENS_ECHO ~= 0 and not selfPlayer:IsSkillOnCooldown(HEAVENS_ECHO) and not selfPlayer:HasBuffById(27390) and selfPlayer.ManaPercent >= 10 then
        print("Buffing! Heaven's Echo!")
		EdanSkills.UseSkillAtPosition(VALKYRIE_HEAVENS_ECHO, selfPlayer.CrosshairPosition, 1000)
        return
    end
end

return DaSBDOValkyrie()

