local miniWansha = fk.CreateSkill {
  name = "mini__wansha",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["mini__wansha"] = "完杀",
  [":mini__wansha"] = "锁定技，你的回合内，若有角色处于濒死状态，不处于濒死状态的其他角色，不能使用【桃】；" ..
  "出牌阶段开始时，你令一名体力值大于1的角色失去1点体力，此阶段结束时，其回复1点体力。",

  ["#mini__wansha-ask"] = "完杀：令一名体力值大于1的角色失去1点体力，出牌阶段结束时，其回复1点体力",
  ["@mini__wansha-phase"] = "完杀",
}

miniWansha:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player)
    return
      target == player and
      player:hasSkill(miniWansha.name) and
      player.phase == Player.Play and
      table.find(player.room.alive_players, function(p) return p.hp > 1 end)
  end,
  on_use = function(self, event, target, player)
    ---@type string
    local skillName = miniWansha.name
    local room = player.room
    local targets = table.filter(room.alive_players, function(p) return p.hp > 1 end)
    if #targets == 0 then
      return false
    end

    local tos = room:askToChoosePlayers(
      player,
      {
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#mini__wansha-ask",
        skill_name = skillName,
        cancelable = false,
      }
    )

    local to = tos[1]
    room:setPlayerMark(player, "@mini__wansha-phase", to.general)
    room:setPlayerMark(player, "_mini__wansha-phase", to.id)
    room:loseHp(to, 1, skillName)
  end,
})

miniWansha:addEffect(fk.EventPhaseEnd, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player)
    if player ~= target or target:getMark("_mini__wansha-phase") == 0 then
      return false
    end

    local victim = player.room:getPlayerById(player:getMark("_mini__wansha-phase"))
    return victim:isAlive() and victim:isWounded()
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local victim = room:getPlayerById(player:getMark("_mini__wansha-phase"))
    if victim:isAlive() then
      room:recover{
        who = victim,
        num = 1,
        recoverBy = player,
        skillName = miniWansha.name,
      }
    end
  end,
})

miniWansha:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    if card.trueName == "peach" and not player.dying then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return Fk:currentRoom().current == p and p:hasSkill(miniWansha.name) and p ~= player
      end)
    end
  end,
})

miniWansha:addEffect(fk.EnterDying, {
  can_refresh = function(self, event, target, player)
    return player:hasSkill(miniWansha.name) and player.phase ~= Player.NotActive
  end,
  on_refresh = function(self, event, target, player)
    player.room:notifySkillInvoked(player, miniWansha.name)
    player:broadcastSkillInvoke("wansha")
  end,
})

return miniWansha
