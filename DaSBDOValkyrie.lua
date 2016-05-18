DaSBDOValkyrie = { }
DaSBDOValkyrie.__index = DaSBDOValkyrie
DaSBDOValkyrie.Version = "3.0.0"
DaSBDOValkyrie.CreditsLibs = "Edan"
DaSBDOValkyrie.CreditsLibs = "VisionZ"
DaSBDOValkyrie.Author = "DaS"

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

heavensTimerInitial = false
heavensTimer = PyxTimer:New(5)  --creates a timer counting to 60 sec

function DaSBDOValkyrie:Attack(monster, isPull)
    local player = GetSelfPlayer()
    if not player or not monster then
        self.combos = nil
        return
    end

    distance = monster.Position.Distance3DFromMe - monster.BodySize

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
        self.combos = coroutine.create(self.Combos)
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

   --Navigator.Stop()

    --skill spam vow of trust to regen mana
    if self.player.ManaPercent <= 30 then
        if EdanSkills.SkillUsableCooldown(VALKYRIE_VOW_OF_TRUST) then
        EdanCombo.DoActionAtPosition("BT_skill_FightingSpirit_Ing2", self.monster.Position, 1)
        print("vow of trust regen mana")
        end
        return
    end

    if heavensTimerInitial == false and not heavensTimer:IsRunning() then
        print("inside timerinitial false")
            heavensTimer:Start()
            heavensTimerInitial = true
    end

    if heavensTimer:Expired() and not heavensTimer:IsRunning() then
            print("inside else if")
            GetSelfPlayer():SetActionState(ACTION_FLAG_EVASION|ACTION_FLAG_SPECIAL_ACTION_1)
            heavensTimer:Reset()
            heavensTimer:Stop()
            heavensTimerInitial = false
    end

    if self.player.BlackRage == 100 then
        EdanCombo.SetActionState(ACTION_FLAG_PARTNER_COMMAND_1, 500)
        return
    end

    --blessing when low 
    if self.player.HealthPercent < 70 and EdanSkills.SkillUsableCooldown(VALKYRIE_BREATH_OF_ELION)  then
        print("Elions Blessing")
        EdanCombo.PressAndWait(ACTION_FLAG_EVASION + ACTION_FLAG_SPECIAL_ACTION_2)
        return
    end


    if (distance >= 500 and distance < 750) and self.monster.IsLineOfSight and self.player.HealthPercent > 60
    and self.player.ManaPercent > 15 and EdanSkills.SkillUsableCooldown(VALKYRIE_RIGHTEOUS_CHARGE) then
                print("Charge")
                EdanCombo.UseSkillAtPosition(VALKYRIE_RIGHTEOUS_CHARGE, self.monster.Position, 1000)
                self.combos = nil

            elseif distance > 800 and self.player.HealthPercent >= 60 then
            Navigator.MoveTo(self.monster.Position)
            self.combos = nil

--[[todo evasion

    elseif distance > 250 and self.player.HealthPercent >= 60 then
            Navigator.MoveTo(self.monster.Position)
            self.combos = nil

    -- elseif  distance > 150 and self.player.HealthPercent >= 60 then
    --         Navigator.MoveTo(self.monster.Position)
    --         self.combos = nil

    -- elseif  EvasionMovment == 1 and self.player.HealthPercent < 60  then

    --         --------------------------------------------------------------------------
    -- --------------------- Evasion move with hp below 60%----------------------
    -- --------------------------------------------------------------------------

    --             if EdanScout.InFrontOfMe(self.monster.Position) ~= true
    --                 and EdanScout.MonstersInMeleeRange > 0
    --                 and EdanScout.AggroBehind > 0
    --                 and EdanSkills.SkillUsableCooldown(VALKYRIE_SHIELD_CHASE)
    --                     then
    --                         print("Back Dash")
    --                         EdanCombo.DoActionAtPosition("BT_Def_Dash_B_Ing_2", self.monster.Position, 2)
    --                         --EdanCombo.SetActionState(ACTION_FLAG_MOVE_BACKWARD | ACTION_FLAG_SECONDARY_ATTACK)
    --                             if distance > 150 then
    --                             if EdanSkills.SkillUsableCooldown(VALKYRIE_SHIELD_THROW) then
    --                                 print("Player Around Throwing Shield!")
    --                                 EdanCombo.Wait(1200)
    --                                 EdanCombo.PressAndWait(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, self.monster.Position, 1000)
    --                             else
    --                                 EdanCombo.PressAndWait(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, self.monster.Position, 1000)
    --                             end

    --                         end
    --                 return
    --             end

    --             if EdanScout.InFront(self.player.Position,self.player.Rotation - math.pi / 2,90, self.monster.Position)
    --                 and EdanScout.MonstersInMeleeRange > 0
    --                 and EdanSkills.SkillUsableCooldown(VALKYRIE_SHIELD_CHASE)
    --                     then
    --                         print("Right Dash")
    --                         EdanCombo.DoActionAtPosition("BT_Def_Dash_R_Ing_2", self.monster.Position, 2)
    --                         --EdanCombo.SetActionState(ACTION_FLAG_MOVE_BACKWARD | ACTION_FLAG_MOVE_RIGHT | ACTION_FLAG_SECONDARY_ATTACK)
    --                             if distance > 150 then
    --                             if EdanSkills.SkillUsableCooldown(VALKYRIE_SHIELD_THROW) then
    --                                 print("Player Around Throwing Shield!")
    --                                 EdanCombo.Wait(1200)
    --                                 EdanCombo.PressAndWait(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, self.monster.Position, 1000)
    --                             else
    --                                 EdanCombo.PressAndWait(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, self.monster.Position, 1000)
    --                             end
    --                         end
    --                 return
    --             end

    --             if EdanScout.InFront(self.player.Position,self.player.Rotation + math.pi / 2,90, self.monster.Position)
    --                 and EdanScout.MonstersInMeleeRange > 0
    --                 and EdanSkills.SkillUsableCooldown(VALKYRIE_SHIELD_CHASE)
    --                     then
    --                         print("Left Dash")
    --                         EdanCombo.DoActionAtPosition("BT_Def_Dash_L_Ing_2", self.monster.Position, 2)
    --                         --EdanCombo.SetActionState(ACTION_FLAG_MOVE_BACKWARD | ACTION_FLAG_MOVE_LEFT | ACTION_FLAG_SECONDARY_ATTACK)
    --                             if distance > 150 then
    --                             if EdanSkills.SkillUsableCooldown(VALKYRIE_SHIELD_THROW) then
    --                                 print("Player Around Throwing Shield!")
    --                                 EdanCombo.Wait(1200)
    --                                 EdanCombo.PressAndWait(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, self.monster.Position, 1000)
    --                             else
    --                                 EdanCombo.PressAndWait(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, self.monster.Position, 1000)
    --                             end
    --                         end
    --                 return
    --             end
    -- else
    --Farming Combo Celestial Spear (s+e) > Shield Throw (s+q and hold) > Breath of Elion (Shift + e) > forward slash (if boe is on cd)
    -- if EdanSkills.SkillUsableCooldown(VALKYRIE_CELESTIAL_SPEAR) and EdanScout.MonstersInMeleeRange > 0 then
    --     print("celestrial spear")
    --     EdanCombo.PressAndWait(ACTION_FLAG_MOVE_BACKWARD|ACTION_FLAG_SPECIAL_ACTION_2, self.monster.Position)
    --     --EdanCombo.Wait(1000) -- hidden aftercast
    --         if EdanSkills.SkillUsableCooldown(VALKYRIE_SHIELD_THROW ) and EdanScout.MonstersInMeleeRange > 0 then
    --             --skill spam shield throw only if no players are around
    --             Playerswitch = true
    --             local characters = GetActors();
    --             table.sort(characters, function(a,b) return a.Position.Distance3DFromMe < b.Position.Distance3DFromMe end)
    --             for k,v in pairs(characters) do
    --                 if v.IsPlayer and math.floor(v.Position.Distance3DFromMe) > 0 then
    --                 Playerswitch = false
    --                 break
    --                 end
    --             end
    --             if EdanSkills.SkillUsableCooldown(VALKYRIE_SHIELD_THROW) and Playerswitch == true then
    --                 print("No Players Around Shield Throw Spam!")
    --                 EdanCombo.DoActionAtPosition("BT_Skill_ShieldThrow_R_Start_UP", self.monster.Position, 2)
    --                 EdanCombo.DoActionAtPosition("BT_Skill_ShieldThrow_R_Cool_Ing", self.monster.Position, 2)
    --                 EdanCombo.DoActionAtPosition("BT_Skill_ShieldThrow_R_Cool_End", self.monster.Position, 2)
    --                 return
    --             end
    --             elseif EdanSkills.SkillUsableCooldown(VALKYRIE_SHIELD_THROW) and EdanScout.MonstersInMeleeRange > 0 then
    --                 print("Player Around Throwing Shield!")
    --                 EdanCombo.SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, self.monster.Position)
    --             else
    --                 if EdanSkills.SkillUsableCooldown(VALKYRIE_SWORD_OF_JUDGMENT) and EdanScout.MonstersInMeleeRange > 0 then
    --                     if EdanSkills.SkillUsableCooldown(VALKYRIE_SWORD_OF_JUDGMENT) and Playerswitch == true then
    --                         print("sword of judgment ult spam")
    --                         EdanCombo.DoActionAtPosition("BT_Skill_RotationBash_C_S", self.monster.Position, 1000)
    --                     else
    --                         if EdanSkills.SkillUsableCooldown(VALKYRIE_SWORD_OF_JUDGMENT) and Playerswitch == false then
    --                         print("sword of judgment")
    --                         EdanCombo.SetActionState(ACTION_FLAG_MOVE_BACKWARD|ACTION_FLAG_SECONDARY_ATTACK, 1000)
    --                         return
    --                     end
    --                 end
    --              --return
    --         end
    --     self.combos = nil
    --     return
    -- end
    -- end
    ]]
    end

--BT_Def_Dash_F_ing_3
--BT_Def_Dash_L_Ing_1
--BT_Def_Dash_R_Ing_2
--self.monster.Key(23007) ogre
if string.match(self.monster.CurrentActionName, "BATTLE_ATTACK") and EdanScout.MonstersInMeleeRange > 0 then

                if EdanScout.InFront(self.player.Position,self.player.Rotation + math.pi / 2,120, self.monster.Position) then
                    --EdanCombo.DoAction("BT_ROLL_L",500)
                    EdanCombo.DoAction("BT_Def_Dash_L_Ing_1",100)
                    print("dash to the left")


                elseif EdanScout.InFront(self.player.Position,self.player.Rotation - math.pi / 2,120, self.monster.Position) then
                    --EdanCombo.DoAction("BT_ROLL_P",500)
                    EdanCombo.DoAction("BT_Def_Dash_R_Ing_2",100)
                    print("dash to the right")

                elseif EdanScout.InFrontOfMe(self.monster.Position) ~= true then
                            if math.random(1, 2) == 1 then
                            EdanCombo.DoAction("BT_ROLL_L",100)
                            print("roll to the left")
                        else
                            EdanCombo.DoAction("BT_ROLL_P",100)
                            print("roll to the right")
                            end
                elseif math.random(1, 2) == 1 then
                    --EdanCombo.DoAction("BT_ROLL_L",500)BT_Skill_Defense_Ing
                    EdanCombo.DoAction("BT_ROLL_L",100)
                    print("roll to the left")
                else
                    --EdanCombo.DoAction("BT_ROLL_P",500)
                    EdanCombo.DoAction("BT_ROLL_P",100)
                    print("roll to the right")
                end
end

    if  EdanScout.MonstersInMeleeRange > 0 then        
        Playerswitch = true
        local characters = GetActors();
        table.sort(characters, function(a,b) return a.Position.Distance3DFromMe < b.Position.Distance3DFromMe end)
        for k,v in pairs(characters) do
            if v.IsPlayer and math.floor(v.Position.Distance3DFromMe) > 0 then
            Playerswitch = false
            break
            end
        end
        -- if Playerswitch == true then
        -- repeat        
        -- print("No Players Around Shield Throw Spam!")
        -- EdanCombo.DoActionAtPosition("BT_Skill_ShieldThrow_R_Start_UP", self.monster.Position, 2)
        -- EdanCombo.DoActionAtPosition("BT_Skill_ShieldThrow_R_Cool_Ing", self.monster.Position, 2)
        -- EdanCombo.DoActionAtPosition("BT_Skill_ShieldThrow_R_Cool_End", self.monster.Position, 2)
        -- until monster ~= 1 return
        --  else     
         if EdanScout.MonstersInMeleeRange > 0 then
            repeat
                if EdanSkills.SkillUsableCooldown(VALKYRIE_CELESTIAL_SPEAR) and EdanScout.MonstersInMeleeRange > 0 then
                print("celestrial spear Melee Range")
                EdanCombo.SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD|ACTION_FLAG_SPECIAL_ACTION_2, self.monster.Position)
                return 
                end

                --todo add righteous charge to the combo
                -- if EdanSkills.SkillUsableCooldown(VALKYRIE_RIGHTEOUS_CHARGE) and EdanScout.MonstersInMeleeRange > 0 then
                -- print("righteous charge")
                -- EdanCombo.SetActionState(ACTION_FLAG_EVASION|ACTION_FLAG_SPECIAL_ACTION_3, 500)
                -- return 
                -- end

                -- SEVERING_LIGHT on several adds VALKYRIE_RIGHTEOUS_CHARGE
                if EdanSkills.SkillUsableCooldown(VALKYRIE_SEVERING_LIGHT) and self.player.HealthPercent < 70 and EdanScout.MonstersInMeleeRange > 0 then
                print("Low Health gaining health back with severing light")
                EdanCombo.SetActionState(ACTION_FLAG_MAIN_ATTACK + ACTION_FLAG_SECONDARY_ATTACK, 2000)
                    if EdanSkills.SkillUsableCooldown(VALKYRIE_SEVERING_LIGHT)
                    then
                    print("sev light ult")
                    EdanCombo.DoActionAtPosition("BT_skill_Lightcut_S",self.monster.Position, 100)
                    end
                    return
                end

                if EdanSkills.SkillUsableCooldown(VALKYRIE_SHARP_LIGHT) and EdanScout.MonstersInMeleeRange > 0 then
                print("sharp light")
                EdanCombo.SetActionStateAtPosition(ACTION_FLAG_EVASION | ACTION_FLAG_MAIN_ATTACK, self.monster.Position)
                return 
                end

                if EdanSkills.SkillUsableCooldown(VALKYRIE_SWORD_OF_JUDGMENT) then
                print("sword of judgment")
                EdanCombo.SetActionState(ACTION_FLAG_MOVE_BACKWARD|ACTION_FLAG_SECONDARY_ATTACK, 1000)
                return
                end

            print("Throwing Shield Melee Range!")
            EdanCombo.SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, self.monster.Position)
            until monster ~= 1  return
        end     
    end

    if  EdanScout.MonstersInMidRange > 0 then        
        Playerswitch = true
        local characters = GetActors();
        table.sort(characters, function(a,b) return a.Position.Distance3DFromMe < b.Position.Distance3DFromMe end)
        for k,v in pairs(characters) do
            if v.IsPlayer and math.floor(v.Position.Distance3DFromMe) > 0 then
            Playerswitch = false
            break
            end
        end
        -- if Playerswitch == true then
        -- repeat        
        -- print("No Players Around Shield Throw Spam!")
        -- EdanCombo.DoActionAtPosition("BT_Skill_ShieldThrow_R_Start_UP", self.monster.Position, 2)
        -- EdanCombo.DoActionAtPosition("BT_Skill_ShieldThrow_R_Cool_Ing", self.monster.Position, 2)
        -- EdanCombo.DoActionAtPosition("BT_Skill_ShieldThrow_R_Cool_End", self.monster.Position, 2)
        -- until monster ~= 1 return
        --  else     
        if EdanScout.MonstersInMidRange > 0 then
            repeat
            if EdanSkills.SkillUsableCooldown(VALKYRIE_CELESTIAL_SPEAR) and EdanScout.MonstersInMidRange > 0 then
            print("celestrial spear mid range")
            EdanCombo.SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD|ACTION_FLAG_SPECIAL_ACTION_2, self.monster.Position)
            return 
            end
            print("Throwing Shield Mid Range!")
            EdanCombo.SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, self.monster.Position)
            until monster ~= 1 return
        end        
    end
end


    -- autoattack with forward slash
    --print("Forward Slash")
    --EdanCombo.DoActionAtPosition("BT_Skill_ShieldThrow_R_Cool_Ing", self.monster.Position, 2)
    --EdanCombo.SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD|ACTION_FLAG_MAIN_ATTACK, self.monster.Position, 500)

function DaSBDOValkyrie:Roaming()
    local player = GetSelfPlayer()
    if not player then
        return
    end

    self.combos = nil

    if player.IsActionPending then
        return
    end

end
return setmetatable({}, DaSBDOValkyrie)