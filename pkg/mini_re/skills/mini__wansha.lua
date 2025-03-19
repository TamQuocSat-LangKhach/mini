local mini__wansha = fk.CreateSkill {
  name = "mini__wansha"
}

Fk:loadTranslationTable{
  ['mini__wansha'] = '完杀',
  ['#mini__wansha-ask'] = '完杀：令一名体力值大于1的角色失去1点体力，出牌阶段结束时，其回复1点体力',
  ['@mini__wansha-phase'] = '完杀',
  [':mini__wansha'] = '锁定技，你的回合内，若有角色处于濒死状态，不处于濒死状态的其他角色，不能使用【桃】。出牌阶段开始时，你令一名体力值大于1的角色失去1点体力，出牌阶段结束时，其回复1点体力。',
}

mini__wansha:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(mini__wansha) and player.phase == Player.Play and table.find(player.room.alive_players, function(p) return p.hp > 1 end)
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p) return p.hp > 1 end), Util.IdMapper)
    if #targets == 0 then return false end
    local target = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#mini__wansha-ask",
      skill_name = mini__wansha.name,
      cancelable = false,
    })
    event:setCostData(skill, target[1])
    return true
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    player:broadcastSkillInvoke("wansha")
    local target = room:getPlayerById(event:getCostData(skill))
    room:setPlayerMark(player, "@mini__wansha-phase", target.general)
    room:setPlayerMark(player, "_mini__wansha-phase", target.id)
    room:loseHp(target, 1, mini__wansha.name)
  end,
  can_refresh = function(self, event, target, player)
    return player:hasSkill(mini__wansha) and player.phase ~= Player.NotActive
  end,
  on_refresh = function(self, event, target, player)
    player.room:notifySkillInvoked(player, mini__wansha.name)
    player:broadcastSkillInvoke("wansha")
  end,
})

mini__wansha:addEffect('prohibit', {
  name = "#mini__wansha_prohibit",
  prohibit_use = function(self, player, card)
    if card.name == "peach" and not player.dying then
      local invoke, ret
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p.phase ~= Player.NotActive and p:hasSkill(mini__wansha) then
          invoke = true
        end
        if p.dying then
          ret = true
        end
      end
      return invoke and ret
    end
  end,
})

mini__wansha:addEffect(fk.EventPhaseEnd, {
  name = "#mini__wansha_recover",
  frequency = Skill.Compulsory,
  mute = true,
  can_trigger = function(self, event, target, player)
    return player == target and target:getMark("_mini__wansha-phase") ~= 0 and not player.room:getPlayerById(player:getMark("_mini__wansha-phase")).dead
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local target = room:getPlayerById(player:getMark("_mini__wansha-phase"))
    if not target.dead then
      room:recover({
        who = target,
        num = 1,
        recoverBy = player,
        skillName = mini__wansha.name
      })
    end
  end,
})

return mini__wansha
