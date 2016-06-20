------------------------Updating to PYX 2.0 ---------------------------

if Pyx.System == nil then
    local callbackTranslations = {
        OnScriptStart = "Pyx.OnScriptStart",
        OnScriptStop = "Pyx.OnScriptStop",
        OnDrawGui = "ImGui.OnRender",
        OnPulse = "PyxBDO.OnPulse",
        OnRender3D = "PyxBDO.OnRender3D",
        OnSendPacket = "PyxBDO.OnSendPacket",
        OnReceivePacket = "PyxBDO.OnReceivePacket",
    }
    Pyx.System = {
        StopCurrentScript = function() Pyx.Scripting.CurrentScript:Stop() end,
        RegisterCallback = function(a,b) Pyx.Scripting.CurrentScript:RegisterCallback(callbackTranslations[a],b) end,
    }
    local mt = {}
    mt.__index = function(self, k)
        if k == "TickCount" then
            return Pyx.Win32.GetTickCount()
        end
        return rawget(self, k)
    end
    setmetatable(Pyx.System, mt)
end
----------------------------------------------------------------------

DaSBDOValkyrie = { }
DaSBDOValkyrie.__index = DaSBDOValkyrie
DaSBDOValkyrie.Author = "DaS"
DaSBDOValkyrie.Version = "3.2.0 Shield Maiden Edition"
DaSBDOValkyrie.BadAssBugTester = "Lucifer^PDX"
DaSBDOValkyrie.CreditsLibs = "Edan"
DaSBDOValkyrie.CreditsTimer = "VisionZ"


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

    --get player level
    local playerLevel = tonumber(BDOLua.Execute("return getSelfPlayer():get():getLevel()"))


    if self.player.BlackRage == 100 and playerLevel >= 35 then
        print("black rage 100% consume it")
        EdanCombo.SetActionState(ACTION_FLAG_PARTNER_COMMAND_1, 100)
        return
    end


    if EdanSkills.SkillUsableCooldown(VALKYRIE_HEAVENS_ECHO) and not self.player:HasBuffById(27390) and self.player.ManaPercent >= 10 then
        print("Buffing! Heaven's Echo!")
        EdanCombo.SetActionState(ACTION_FLAG_EVASION + ACTION_FLAG_SPECIAL_ACTION_1, 100)
        return
    end

    --blessing when low 
    if self.player.HealthPercent < 70 and EdanSkills.SkillUsableCooldown(VALKYRIE_BREATH_OF_ELION)  then
        print("Elions Blessing")
        EdanCombo.PressAndWait(ACTION_FLAG_EVASION + ACTION_FLAG_SPECIAL_ACTION_2)
        return
    end


    if (distance >= 500 and distance < 750) and self.monster.IsLineOfSight and self.player.HealthPercent > 60
    and self.player.ManaPercent > 15 then

                --self.combos = nil
                Navigator.MoveTo(self.monster.Position)

            elseif distance > 750 then
            Navigator.MoveTo(self.monster.Position)
            self.combos = nil
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
  
        if EdanScout.MonstersInMeleeRange > -10 and self.player.ManaPercent > 20 then
            repeat
                if EdanSkills.SkillUsableCooldown(VALKYRIE_CELESTIAL_SPEAR) and EdanScout.MonstersInMeleeRange > 0 and self.player.ManaPercent > 20 then
                print("Celestrial Spear Melee Range")
                EdanCombo.SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD|ACTION_FLAG_SPECIAL_ACTION_2, self.monster.Position)
                    if EdanSkills.SkillUsableCooldown(VALKYRIE_SWORD_OF_JUDGMENT) then
                    print("SOJ 3")
                    EdanCombo.SetActionState(ACTION_FLAG_MOVE_BACKWARD|ACTION_FLAG_SECONDARY_ATTACK, 100)
                    end
                    return 
                end

                -- SEVERING_LIGHT on several adds 
                if EdanSkills.SkillUsableCooldown(VALKYRIE_SEVERING_LIGHT) and self.player.HealthPercent < 70 and EdanScout.MonstersInMeleeRange > 0 and self.player.ManaPercent > 20 then
                print("Low Health gaining health back with severing light")
                EdanCombo.SetActionState(ACTION_FLAG_MAIN_ATTACK + ACTION_FLAG_SECONDARY_ATTACK, 2000)
                    return
                end

                if EdanSkills.SkillUsableCooldown(VALKYRIE_SHARP_LIGHT) and EdanScout.MonstersInMeleeRange > 0 and self.player.ManaPercent > 20 then
                print("Sharp Light")
                EdanCombo.SetActionStateAtPosition(ACTION_FLAG_EVASION | ACTION_FLAG_MAIN_ATTACK, self.monster.Position)
                    if EdanSkills.SkillUsableCooldown(VALKYRIE_SWORD_OF_JUDGMENT) then
                    print("SOJ 3")
                    EdanCombo.SetActionState(ACTION_FLAG_MOVE_BACKWARD|ACTION_FLAG_SECONDARY_ATTACK, 100)
                    end
                    return 
                end

                if EdanSkills.SkillUsableCooldown(VALKYRIE_SWORD_OF_JUDGMENT) and self.player.ManaPercent > 20 then
                    print("Sword of Judgment")
                    EdanCombo.SetActionState(ACTION_FLAG_MOVE_BACKWARD|ACTION_FLAG_SECONDARY_ATTACK, 1000)
                    return
                end

                if EdanSkills.SkillUsableCooldown(VALKYRIE_FORWARD_SLASH) and self.player.ManaPercent < 20 then
                    print("Mana Low! Using Forward Slash to regain!")
                    EdanCombo.SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD + ACTION_FLAG_MAIN_ATTACK, self.monster.Position)
                    return
                end

            print("Throwing Shield Melee Range!")
            EdanCombo.SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, self.monster.Position)
            until monster ~= 1  return
        end 

        if EdanSkills.SkillUsableCooldown(VALKYRIE_FORWARD_SLASH) and self.player.ManaPercent < 20 then
            print("Mana Low! Using Forward Slash to regain!")
            EdanCombo.SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD + ACTION_FLAG_MAIN_ATTACK, self.monster.Position)
            return
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
    
        if distance > 250 and distance < 600 and self.player.ManaPercent > 20 then
            repeat
            if EdanSkills.SkillUsableCooldown(VALKYRIE_CELESTIAL_SPEAR) and EdanScout.MonstersInMidRange > 0 and self.player.ManaPercent > 20 then
            print("Celestrial Spear Mid Range")
            EdanCombo.SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD|ACTION_FLAG_SPECIAL_ACTION_2, self.monster.Position)
            return 
            end
            print("Throwing Shield Mid Range!")
            EdanCombo.SetActionStateAtPosition(ACTION_FLAG_MOVE_BACKWARD + ACTION_FLAG_SPECIAL_ACTION_1, self.monster.Position)
            until monster ~= 1 return
        end
        
        if EdanSkills.SkillUsableCooldown(VALKYRIE_FORWARD_SLASH) and self.player.ManaPercent < 20 then
            print("Righteous Charge")
            if EdanSkills.SkillUsableCooldown(VALKYRIE_FORWARD_SLASH) then 
               EdanCombo.SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD + ACTION_FLAG_SPECIAL_ACTION_3, self.monster.Position)
               return
            end
            print("Mana Low! Using Forward Slash to regain!")
            EdanCombo.SetActionStateAtPosition(ACTION_FLAG_MOVE_FORWARD + ACTION_FLAG_MAIN_ATTACK, self.monster.Position)
            return
        end        
    end
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

end
return setmetatable({}, DaSBDOValkyrie)