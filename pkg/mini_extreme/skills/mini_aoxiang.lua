local miniAoxiang = fk.CreateSkill {
  name = "mini__aoxiang"
}

Fk:loadTranslationTable{
  ["mini__aoxiang"] = "遨想",
  [":mini__aoxiang"] = "每回合限一次，你可以视为使用一张【酒】，并随机获得一张手牌中未拥有的类别的牌。" ..
  "若如此做，当前回合结束时，你选择一项：1.若你未翻面，将武将牌至背面；2.令〖才溢〗本轮失效。",

  ["#mini__aoxiang"] = "遨想：视为使用【酒】并获得一张手牌中缺少的类别的牌",
  ["mini__aoxiang_invalidate"] = "“才溢”本轮失效",
}

miniAoxiang:addEffect("viewas", {
  anim_type = "support",
  pattern = "analeptic",
  prompt = "#mini__aoxiang",
  card_filter = Util.FalseFunc,
  view_as = function(self, player)
    local c = Fk:cloneCard("analeptic")
    c.skillName = miniAoxiang.name
    return c
  end,
  before_use = function(self, player)
    local types = { "basic", "trick", "equip" }
    for _, id in ipairs(player:getCardIds("h")) do
      table.removeOne(types, Fk:getCardById(id):getTypeString())
    end
    if #types > 0 then
      local room = player.room
      local pattern = ".|.|.|.|.|" .. table.concat(types, ",")
      local ids = room:getCardsFromPileByRule(pattern)
      if #ids > 0 then
        room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonJustMove, miniAoxiang.name, nil, true, player)
      end
    end
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(miniAoxiang.name, Player.HistoryTurn) == 0
  end,
  enabled_at_response = function (self, player, response)
    return not response and player:usedSkillTimes(miniAoxiang.name, Player.HistoryTurn) == 0
  end,
})

miniAoxiang:addEffect(fk.TurnEnd, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return player:usedSkillTimes(miniAoxiang.name, Player.HistoryTurn) > 0 and player:isAlive()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = { "mini__aoxiang_invalidate" }
    if player.faceup then
      table.insert(choices, 1, "turnOver")
    end
    local choice = room:askToChoice(
      player,
      {
        choices = choices,
        skill_name = "mini__aoxiang",
      }
    )
    if choice == "turnOver" then
      player:turnOver()
    else
      room:invalidateSkill(player, "mini__caiyi", "-round")
    end
  end,
})

return miniAoxiang
