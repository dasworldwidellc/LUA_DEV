DaSValkyrie = { }
DaSValkyrie.__index = DaSValkyrie
DaSValkyrie.Version = "1.0"
--Vitalic did majority of the leg work on this script. TY
DaSValkyrie.Credits = "Vitalic"
DaSValkyrie.Author = "DaS"

------------------- Spell ID's --------------------------

DaSValkyrie.BREATH_OF_ELION = { 764, 763, 762 }
DaSValkyrie.CELESTIAL_SPEAR = { 775, 768, 767, 766, 765 }
DaSValkyrie.CHARGING_SLASH = { 749, 748, 747 }
DaSValkyrie.DIVINE_POWER = { 742, 741, 740, 739 }
DaSValkyrie.FLURRY_OF_KICKS = { 725, 724, 723 }
DaSValkyrie.FLYING_KICK = { 728, 727 }
DaSValkyrie.FORWARD_SLASH = { 1478, 1477, 1476 }
DaSValkyrie.GLARING_SLASH = { 761, 760, 759, 758, 757 }
DaSValkyrie.HEAVENS_ECHO = { 746, 745, 744 }
DaSValkyrie.JUDGEMENT_OF_LIGHT = { 774, 773, 772 }
DaSValkyrie.JUST_COUNTER = { 722, 721, 720 }
DaSValkyrie.PUNISHMENT = { 779, 778, 777, 776 }
DaSValkyrie.RIGHTEOUS_CHARGE = { 752, 751, 750 }
DaSValkyrie.SEVERING_LIGHT = { 1482, 1481, 1480, 1479 }
DaSValkyrie.SHARP_LIGHT = { 1493, 1492, 1491, 1490 }
DaSValkyrie.SHIELD_CHASE = { 738, 737, 736 }
DaSValkyrie.SHIELD_STRIKE = { 1499, 1498, 1497 }
DaSValkyrie.SHIELD_THROW = { 1486, 1485 }
DaSValkyrie.SHINING_DASH = { 731 }
DaSValkyrie.SIDEWAYS_CUT = { 1489, 1488, 1487 }
DaSValkyrie.SKYWARD_STRIKE = { 756, 755, 754 }
DaSValkyrie.SWORD_OF_JUDGEMENT = { 735, 734, 733, 732 }
DaSValkyrie.FLOW_SHIELD_THROW = { 784 }
DaSValkyrie.ULTIMATE_DIVINE_POWER = { 743 }
DaSValkyrie.ULTIMATE_FLURRY_OF_KICKS = { 726 }
DaSValkyrie.ULTIMATE_PUNISHMENT = { 780 }
DaSValkyrie.ULTIMATE_RIGHTEOUS_CHARGE = { 753 }
DaSValkyrie.ULTIMATE_SEVERING_LIGHT = { 1483 }
DaSValkyrie.ULTIMATE_SHARP_LIGHT = { 771 }
DaSValkyrie.ULTIMATE_SWORD_OF_JUDGEMENT = { 770 }
DaSValkyrie.GUARD = { 718 }

---------------------------------------------------------------

setmetatable(DaSValkyrie, {
    __call = function (cls, ...)
	return cls.new(...)
    end,
})

----------------------------------------------------------------

------------------ Setup New Valk and Constants ---------------------

function DaSValkyrie.new()
    local instance = {}
    local self = setmetatable(instance, DaSValkyrie)
    return self
end

----------------------------------------------------------------------

--------------------- Get Monster Count -------------------------------

function DaSValkyrie:GetMonsterCount()
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

--------------------- Main Combat Logic ------------------------------

function DaSValkyrie:Attack(monsterActor)

    ------------------------- Create Local Skills for Combat ------------------------------------------

    local BREATH_OF_ELION = SkillsHelper.GetKnownSkillId(DaSValkyrie.BREATH_OF_ELION)
    local CELESTIAL_SPEAR = SkillsHelper.GetKnownSkillId(DaSValkyrie.CELESTIAL_SPEAR)
    local CHARGING_SLASH = SkillsHelper.GetKnownSkillId(DaSValkyrie.CHARGING_SLASH)
    local DIVINE_POWER = SkillsHelper.GetKnownSkillId(DaSValkyrie.DIVINE_POWER)
    local FLURRY_OF_KICKS = SkillsHelper.GetKnownSkillId(DaSValkyrie.FLURRY_OF_KICKS)
    local FLYING_KICK = SkillsHelper.GetKnownSkillId(DaSValkyrie.FLYING_KICK)
    local FORWARD_SLASH = SkillsHelper.GetKnownSkillId(DaSValkyrie.FORWARD_SLASH)
    local GLARING_SLASH = SkillsHelper.GetKnownSkillId(DaSValkyrie.GLARING_SLASH)
    local HEAVENS_ECHO = SkillsHelper.GetKnownSkillId(DaSValkyrie.HEAVENS_ECHO)
    local JUDGEMENT_OF_LIGHT = SkillsHelper.GetKnownSkillId(DaSValkyrie.JUDGEMENT_OF_LIGHT)
    local JUST_COUNTER = SkillsHelper.GetKnownSkillId(DaSValkyrie.JUST_COUNTER)
    local PUNISHMENT = SkillsHelper.GetKnownSkillId(DaSValkyrie.PUNISHMENT)
    local RIGHTEOUS_CHARGE = SkillsHelper.GetKnownSkillId(DaSValkyrie.RIGHTEOUS_CHARGE)
    local SEVERING_LIGHT = SkillsHelper.GetKnownSkillId(DaSValkyrie.SEVERING_LIGHT)
    local SHARP_LIGHT = SkillsHelper.GetKnownSkillId(DaSValkyrie.SHARP_LIGHT)
    local SHIELD_CHASE = SkillsHelper.GetKnownSkillId(DaSValkyrie.SHIELD_CHASE)
    local SHIELD_STRIKE = SkillsHelper.GetKnownSkillId(DaSValkyrie.SHIELD_STRIKE)
    local SHIELD_THROW = SkillsHelper.GetKnownSkillId(DaSValkyrie.SHIELD_THROW)
    local SHINING_DASH = SkillsHelper.GetKnownSkillId(DaSValkyrie.SHINING_DASH)
    local SIDEWAYS_CUT = SkillsHelper.GetKnownSkillId(DaSValkyrie.SIDEWAYS_CUT)
    local SKYWARD_STRIKE = SkillsHelper.GetKnownSkillId(DaSValkyrie.SKYWARD_STRIKE)
    local SWORD_OF_JUDGEMENT = SkillsHelper.GetKnownSkillId(DaSValkyrie.SWORD_OF_JUDGEMENT)
    local FLOW_SHIELD_THROW = SkillsHelper.GetKnownSkillId(DaSValkyrie.FLOW_SHIELD_THROW)
    local ULTIMATE_DIVINE_POWER = SkillsHelper.GetKnownSkillId(DaSValkyrie.ULTIMATE_DIVINE_POWER)
    local ULTIMATE_FLURRY_OF_KICKS = SkillsHelper.GetKnownSkillId(DaSValkyrie.ULTIMATE_FLURRY_OF_KICKS)
    local ULTIMATE_PUNISHMENT = SkillsHelper.GetKnownSkillId(DaSValkyrie.ULTIMATE_PUNISHMENT)
    local ULTIMATE_RIGHTEOUS_CHARGE = SkillsHelper.GetKnownSkillId(DaSValkyrie.ULTIMATE_RIGHTEOUS_CHARGE)
    local ULTIMATE_SEVERING_LIGHT = SkillsHelper.GetKnownSkillId(DaSValkyrie.ULTIMATE_SEVERING_LIGHT)
    local ULTIMATE_SHARP_LIGHT = SkillsHelper.GetKnownSkillId(DaSValkyrie.ULTIMATE_SHARP_LIGHT)
    local ULTIMATE_SWORD_OF_JUDGEMENT = SkillsHelper.GetKnownSkillId(DaSValkyrie.ULTIMATE_SWORD_OF_JUDGEMENT)
    local GUARD = SkillsHelper.GetKnownSkillId(DaSValkyrie.GUARD)


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
            -- BELOW 50% CAST EVASIVE MANOUEVERS UNTILL CONSUMABLES HAVE HEALED YOU --
            --                                                                      --
            --------------------------------------------------------------------------

            if selfPlayer.HealthPercent <= 40 then
                -- Low on Health? Heal up!
                if BREATH_OF_ELION ~= 0 and selfPlayer.HealthPercent < 40 and not selfPlayer:IsSkillOnCooldown(BREATH_OF_ELION) and selfPlayer.ManaPercent >= 10 then
                   print("Nothing going on and we are low on health! Casting Breath of Elion!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_EVASION | ACTION_FLAG_SPECIAL_ACTION_2, actorPosition, 1000)
                    return
                end
                if selfPlayer.Stamina > 200 then
                    local rnd = math.random(1, 3)
                    -- +++++++++++++TEST++++++++++++
                    if rnd == 1 then
                        print("GTFO! Teleporting time! To the left!")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_LEFT | ACTION_FLAG_MAIN_ATTACK | ACTION_FLAG_SECONDARY_ATTACK , actorPosition, 1750)
                        return
                    end
                    -- +++++++++++++TEST++++++++++++
                    if rnd == 2 then
                        print("GTFO! Teleporting time! To the right!")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_RIGHT | ACTION_FLAG_MAIN_ATTACK | ACTION_FLAG_SECONDARY_ATTACK, actorPosition, 1750)
                        return
                    end
                    -- +++++++++++++TEST++++++++++++
                    if rnd == 3 then
                        print("GTFO! Teleporting time! To the rear!")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_EVASION | ACTION_FLAG_MOVE_BACKWARD, actorPosition, 1750)
                        return
                    end
                else
                    -- +++++++++++++TEST++++++++++++
                    print("GTFO! Oh damn no stamina! Walk back, pray and spray!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_SPECIAL_ACTION_1  | ACTION_FLAG_MOVE_BACKWARD, actorPosition, 500)
                    return
                end

            end


            -- Heavens Echo Buff
            if HEAVENS_ECHO ~= 0 and not selfPlayer:IsSkillOnCooldown(HEAVENS_ECHO) and not selfPlayer:HasBuffById(27390) and selfPlayer.ManaPercent >= 10 then
                print("Buffing! Heaven's Echo!")
                selfPlayer:SetActionState(ACTION_FLAG_EVASION | ACTION_FLAG_SPECIAL_ACTION_1)
                return
            end

            -- if actorPosition.Distance3DFromMe > monsterActor.BodySize + 150 then
            -- -- Charge the mob!
            -- if RIGHTEOUS_CHARGE ~= 0 and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 700 and actorPosition.Distance3DFromMe >= monsterActor.BodySize + 300
            -- and not selfPlayer:IsSkillOnCooldown(RIGHTEOUS_CHARGE) and selfPlayer.ManaPercent >= 15 then
            -- print("Charge Pulling! Righteous Charge!")
            -- selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD | ACTION_FLAG_SPECIAL_ACTION_3, actorPosition)

            -- elseif CELESTIAL_SPEAR ~= 0 and selfPlayer:IsSkillOnCooldown(RIGHTEOUS_CHARGE) and not selfPlayer:IsSkillOnCooldown(CELESTIAL_SPEAR)
            -- and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 700 and actorPosition.Distance3DFromMe >= monsterActor.BodySize + 300
            -- and selfPlayer.ManaPercent >= 15 then
            -- print("Charge on CD! Using Celestial Spear Pull instead!")
            -- selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD | ACTION_FLAG_SPECIAL_ACTION_2, actorPosition)
            -- return
            -- end

            -- Navigator.MoveTo(actorPosition)
            -- else
            -- Navigator.Stop()

            --RIGHTEOUS_CHARGE combo
            if actorPosition.Distance3DFromMe > monsterActor.BodySize + 150 then
                -- Charge the mob!
                -- Combo: Righteous Charge > Charging Slash > Just Counter > Sword of Judgement > Shield Throw > Celestrial Spear > Shield Throw > Shield Chase > Just Counter
                if RIGHTEOUS_CHARGE ~= 0 and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 700 and actorPosition.Distance3DFromMe >= monsterActor.BodySize + 300
                    and not selfPlayer:IsSkillOnCooldown(RIGHTEOUS_CHARGE) and selfPlayer.ManaPercent >= 15 then
                    print("Charge Pulling! Righteous Charge Combo!")
                    print("Righteous Charge")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD | ACTION_FLAG_SPECIAL_ACTION_3, actorPosition)

                    -- CHARKING SLASH
                    if CHARGING_SLASH ~= 0 and (not selfPlayer:IsSkillOnCooldown(CHARGING_SLASH) or string.match(selfPlayer.CurrentActionName, "ChargingSlash"))
                        and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 and selfPlayer.ManaPercent > 20 then
                        print("Charging Slash")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_EVASION | ACTION_FLAG_MAIN_ATTACK, actorPosition, 1000)
                        return
                    end
                    -- JUST COUNTER
                    if JUST_COUNTER ~= 0 and (not selfPlayer:IsSkillOnCooldown(JUST_COUNTER) or string.match(selfPlayer.CurrentActionName, "JustCounter"))
                        and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 and selfPlayer.HealthPercent <= 50 and selfPlayer.ManaPercent > 20 and monsterCount >= 3 then
                        print("Just Counter")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD | ACTION_FLAG_MAIN_ATTACK, actorPosition, 1000)
                        return
                    end
                    -- SWORD OF JUDGEMENT
                    if SWORD_OF_JUDGEMENT ~= 0 and (not selfPlayer:IsSkillOnCooldown(SWORD_OF_JUDGEMENT) or string.match(selfPlayer.CurrentActionName, "FrontSlice"))
                        and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 and selfPlayer.ManaPercent > 20 then
                        print("Sword of Judgment Spam!")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD | ACTION_FLAG_SECONDARY_ATTACK, actorPosition, 1000)
                        return
                    end
                    -- SHIELD THROW
                    if SHIELD_THROW ~= 0 and (not selfPlayer:IsSkillOnCooldown(SHIELD_THROW) or string.match(selfPlayer.CurrentActionName, "RotationBash")
                        or string.match(selfPlayer.CurrentActionName, "FrontSlice") or string.match(selfPlayer.CurrentActionName, "HeavenSpear")) and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 600
                        and selfPlayer.ManaPercent >= 15 then
                        print("Throwing Shield!")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD | ACTION_FLAG_SPECIAL_ACTION_1, actorPosition)
                        return
                    end
                    -- Celestial Spear Check
                    if CELESTIAL_SPEAR ~= 0 and not selfPlayer:IsSkillOnCooldown(CELESTIAL_SPEAR) and selfPlayer.ManaPercent > 20 then
                        print("Casting Celestial Spear!")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD | ACTION_FLAG_SPECIAL_ACTION_2, actorPosition)
                        return
                    end
                    -- Shield Throw
                    if SHIELD_THROW ~= 0 and (not selfPlayer:IsSkillOnCooldown(SHIELD_THROW) or string.match(selfPlayer.CurrentActionName, "RotationBash")
                        or string.match(selfPlayer.CurrentActionName, "FrontSlice") or string.match(selfPlayer.CurrentActionName, "HeavenSpear")) and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 600
                        and selfPlayer.ManaPercent >= 15 then
                        print("Throwing Shield!")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD | ACTION_FLAG_SPECIAL_ACTION_1, actorPosition)
                        return
                    end
                    -- Shield Chase
                    if SHIELD_CHASE ~= 0 and (not selfPlayer:IsSkillOnCooldown(SHIELD_CHASE) or string.match(selfPlayer.CurrentActionName, "ShieldChase")
                        or string.match(selfPlayer.CurrentActionName, "FrontSlice") or string.match(selfPlayer.CurrentActionName, "HeavenSpear")) and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 600
                        and selfPlayer.ManaPercent >= 15 then
                        print("Chasing Shield!")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD |  ACTION_FLAG_EVASION , actorPosition)
                        return
                    end
                    -- Just counter
                    if JUST_COUNTER ~= 0 and (not selfPlayer:IsSkillOnCooldown(JUST_COUNTER) or string.match(selfPlayer.CurrentActionName, "JustCounter"))
                        and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 and selfPlayer.ManaPercent > 20 then
                        print("Just Counter!")
                        selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD | ACTION_FLAG_MAIN_ATTACK, actorPosition, 1000)
                        return
                    end


                    --Combo EX: Celestrial Spear > Sword of Judgement > Shield Throw > Shield Chase > Righteous Charge > Just Counter > etc.
                elseif CELESTIAL_SPEAR ~= 0 and selfPlayer:IsSkillOnCooldown(RIGHTEOUS_CHARGE) and not selfPlayer:IsSkillOnCooldown(CELESTIAL_SPEAR)
                    and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 700 and actorPosition.Distance3DFromMe >= monsterActor.BodySize + 300
                    and selfPlayer.ManaPercent >= 15 then
                    print("Charge on CD! Using Celestial Spear Pull instead!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD | ACTION_FLAG_SPECIAL_ACTION_2, actorPosition)
                    return
                end
                -- SWORD OF JUDGEMENT
                if SWORD_OF_JUDGEMENT ~= 0 and (not selfPlayer:IsSkillOnCooldown(SWORD_OF_JUDGEMENT) or string.match(selfPlayer.CurrentActionName, "FrontSlice"))
                    and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 and selfPlayer.ManaPercent > 20 then
                    print("Sword of Judgment Spam!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD | ACTION_FLAG_SECONDARY_ATTACK, actorPosition, 1000)
                    return
                end
                -- Shield Throw
                if SHIELD_THROW ~= 0 and (not selfPlayer:IsSkillOnCooldown(SHIELD_THROW) or string.match(selfPlayer.CurrentActionName, "RotationBash")
                    or string.match(selfPlayer.CurrentActionName, "FrontSlice") or string.match(selfPlayer.CurrentActionName, "HeavenSpear")) and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 600
                    and selfPlayer.ManaPercent >= 15 then
                    print("Throwing Shield!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD | ACTION_FLAG_SPECIAL_ACTION_1, actorPosition)
                    return
                end
                -- Shield Chase
                if SHIELD_CHASE ~= 0 and (not selfPlayer:IsSkillOnCooldown(SHIELD_CHASE) or string.match(selfPlayer.CurrentActionName, "ShieldChase")
                    or string.match(selfPlayer.CurrentActionName, "FrontSlice") or string.match(selfPlayer.CurrentActionName, "HeavenSpear")) and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 600
                    and selfPlayer.ManaPercent >= 15 then
                    print("Chasing Shield!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD |  ACTION_FLAG_EVASION , actorPosition)
                    return
                end
                -- Just counter
                if JUST_COUNTER ~= 0 and (not selfPlayer:IsSkillOnCooldown(JUST_COUNTER) or string.match(selfPlayer.CurrentActionName, "JustCounter"))
                    and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 and selfPlayer.ManaPercent > 20 then
                    print("Just Counter!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD | ACTION_FLAG_MAIN_ATTACK, actorPosition, 1000)
                    return
                end

                Navigator.MoveTo(actorPosition)
            else
                Navigator.Stop()

                -- Judgement of Light on several adds
                -- if JUDGEMENT_OF_LIGHT ~= 0 and not selfPlayer:IsSkillOnCooldown(JUDGEMENT_OF_LIGHT) and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 500
                -- and monsterCount >= 3 and selfPlayer.BlackRage == 100 and selfPlayer.ManaPercent > 40 then
                -- print("Maximum Black Rage and too many adds! Let their be light!")
                -- selfPlayer:DoActionAtPosition(JUDGEMENT_OF_LIGHT, actorPosition, 3000)
                -- return
                -- end


                -- SEVERING_LIGHT on several adds
                if SEVERING_LIGHT ~= 0 and (not selfPlayer:IsSkillOnCooldown(SEVERING_LIGHT) or string.match(selfPlayer.CurrentActionName, "LightCut4"))
                    and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 and selfPlayer.HealthPercent <= 75 and selfPlayer.ManaPercent > 20 and monsterCount >= 1 then
                    print("Low Health gaining health back with severing light")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_SPECIAL_ACTION_1, actorPosition)
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MAIN_ATTACK | ACTION_FLAG_SECONDARY_ATTACK, actorPosition, 1000)
                    return
                end



                -- Celestial Spear Check
                if CELESTIAL_SPEAR ~= 0 and not selfPlayer:IsSkillOnCooldown(CELESTIAL_SPEAR) and selfPlayer.ManaPercent > 20 then
                    print("Casting Celestial Spear!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD | ACTION_FLAG_SPECIAL_ACTION_2, actorPosition)
                    return
                end

                -- Sword of Judgement
                if SWORD_OF_JUDGEMENT ~= 0 and (not selfPlayer:IsSkillOnCooldown(SWORD_OF_JUDGEMENT) or string.match(selfPlayer.CurrentActionName, "FrontSlice"))
                    and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 and selfPlayer.ManaPercent > 20 then
                    print("Sword of Judgment Spam!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD | ACTION_FLAG_SECONDARY_ATTACK, actorPosition, 1000)
                    return
                end

                -- -- Breath of Elion Check
                -- if BREATH_OF_ELION ~= 0 and (not selfPlayer:IsSkillOnCooldown(BREATH_OF_ELION) or string.match(selfPlayer.CurrentActionName, "RotationBash"))
                -- and selfPlayer.HealthPercent <= 70 and selfPlayer.ManaPercent >= 15 then
                -- print("Health is low! Casting Breaht of Elion")
                -- selfPlayer:SetActionStateAtPosition(ACTION_FLAG_EVASION | ACTION_FLAG_SPECIAL_ACTION_2)
                -- return
                -- end

                -- Low on Health? Heal up!
                if BREATH_OF_ELION ~= 0 and selfPlayer.HealthPercent < 70 and not selfPlayer:IsSkillOnCooldown(BREATH_OF_ELION) and selfPlayer.ManaPercent >= 10 then
                    print("Nothing going on and we are low on health! Casting Breath of Elion!")
                    selfPlayer:SetActionState(ACTION_FLAG_EVASION | ACTION_FLAG_SPECIAL_ACTION_2)
                    return
                end

                -- Shield Throw
                if SHIELD_THROW ~= 0 and (not selfPlayer:IsSkillOnCooldown(SHIELD_THROW) or string.match(selfPlayer.CurrentActionName, "RotationBash")
                    or string.match(selfPlayer.CurrentActionName, "FrontSlice") or string.match(selfPlayer.CurrentActionName, "HeavenSpear")) and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 600
                    and selfPlayer.ManaPercent >= 15 then
                    print("Throwing Shield!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD | ACTION_FLAG_SPECIAL_ACTION_1, actorPosition)
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

                -- Mana low? Lets regain that shit!
                if FORWARD_SLASH ~= 0 and (not selfPlayer:IsSkillOnCooldown(FORWARD_SLASH) or string.match(selfPlayer.CurrentActionName, "RotationBash")
                    or string.match(selfPlayer.CurrentActionName, "HeavenSpear") or string.match(selfPlayer.CurrentActionName, "ShieldThrow"))
                    and selfPlayer.ManaPercent < 30 and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 200 then
                    print("Mana Low! Using Forward Slash to regain!")
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_SPECIAL_ACTION_1, actorPosition)
                    selfPlayer:SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD | ACTION_FLAG_MAIN_ATTACK, actorPosition)
                    return
                end
            end
        end
    end
end

return DaSValkyrie()








