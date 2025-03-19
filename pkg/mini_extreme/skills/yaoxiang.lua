local yaoxiang = fk.CreateSkill {
  name = "mini__yaoxiang"
}

Fk:loadTranslationTable{
  ['mini__yaoxiang'] = '遨想',
  ['#mini__yaoxiang'] = '遨想：视为使用【酒】并获得一张手牌中缺少的类别的牌',
  ['#mini__yaoxiang_trigger'] = '才溢',
  ['mini__yaoxiang_invalidate'] = '“才溢”本轮失效',
  ['mini__caiyi'] = '才溢',
  [':mini__yaoxiang'] = '每回合限一次，你可以视为使用一张【酒】，并随机获得一张手牌中未拥有的类别的牌。若如此做，当前回合结束时，你选择一项：1.若你未翻面，将武将牌至背面；2.令〖才溢〗本轮失效。',
}

yaoxiang:addEffect('viewas', {
  anim_type = "support",
  pattern = "analeptic",
  prompt = "#mini__yaoxiang",
  card_filter = Util.FalseFunc,
  view_as = function(self, player)
    local c = Fk:cloneCard("analeptic")
    c.skillName = skill.name
    return c
  end,
  before_use = function(self, player)
    local types = {"basic", "trick", "equip"}
    for _, id in ipairs(player:getCardIds("h")) do
      table.removeOne(types, Fk:getCardById(id):getTypeString())
    end
    if #types > 0 then
      local room = player.room
      local pattern = ".|.|.|.|.|"..table.concat(types, ",")
      local ids = room:getCardsFromPileByRule(pattern)
      if #ids > 0 then
        room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonJustMove, skill.name, nil, true, player.id)
      end
    end
  end,
  enabled_at_play = function (skill, player)
    return player:usedSkillTimes(skill.name, Player.HistoryTurn) == 0
  end,
  enabled_at_response = function (skill, player, response)
    return not response and player:usedSkillTimes(skill.name, Player.HistoryTurn) == 0
  end,
})

yaoxiang:addEffect(fk.TurnEnd, {
  anim_type = "special",
  can_trigger = function(self, event, target, player)
    return player:usedSkillTimes(yaoxiang.name, Player.HistoryTurn) > 0 and not player.dead
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    local choices = {"mini__yaoxiang_invalidate"}
    if player.faceup then
      table.insert(choices, 1, "turnOver")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = "mini__yaoxiang"
    })
    if choice == "turnOver" then
      player:turnOver()
    else
      room:invalidateSkill(player, "mini__caiyi", "-round")
    end
  end,
})

return yaoxiang
