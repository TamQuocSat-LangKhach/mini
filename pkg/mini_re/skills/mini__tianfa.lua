local mini__tianfa = fk.CreateSkill {
  name = "mini__tianfa"
}

Fk:loadTranslationTable{
  ['mini__tianfa'] = '天罚',
  ['@mini__punish-turn'] = '罚',
  ['#mini__tianfa-choose'] = '天罚：你可以对至多 %arg 名其他角色依次造成1点伤害',
  [':mini__tianfa'] = '你每于出牌阶段使用两张锦囊后，你于本回合内获得1枚“罚”标记。回合结束时，你可以对至多X名其他角色依次造成1点伤害（X为“罚”数）。',
}

mini__tianfa:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player:getMark("@mini__punish-turn") > 0
  end,
  on_cost = function (skill, event, target, player, data)
    local n = player:getMark("@mini__punish-turn")
    local tos = player.room:askToChoosePlayers(player, {
      targets = table.map(player.room:getOtherPlayers(player, false), Util.IdMapper),
      min_num = 1,
      max_num = n,
      prompt = "#mini__tianfa-choose:::"..n,
      skill_name = skill.name,
      cancelable = true
    })
    if #tos > 0 then
      event:setCostData(skill, tos)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = event:getCostData(skill)
    room:sortPlayersByAction(tos)
    for _, pid in ipairs(tos) do
      local p = room:getPlayerById(pid)
      if not p.dead then
        room:damage { from = player, to = p, damage = 1, skillName = skill.name }
      end
    end
  end,
})

mini__tianfa:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Play and data.card.type == Card.TypeTrick and player:getMark("mini__tianfa_count-turn") > 1
  end,
  on_cost = function (skill, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "mini__tianfa_count-turn", 0)
    room:addPlayerMark(player, "@mini__punish-turn", 1)
  end,

  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Play and data.card.type == Card.TypeTrick
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "mini__tianfa_count-turn", 1)
  end,
})

return mini__tianfa
