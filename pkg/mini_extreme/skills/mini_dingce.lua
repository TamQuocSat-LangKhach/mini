local mini_dingce = fk.CreateSkill {
  name = "mini_dingce"
}

Fk:loadTranslationTable{
  ['mini_dingce'] = '定策',
  ['@mini_moulue'] = '谋略值',
  [':mini_dingce'] = '每回合限一次，你可以消耗1点谋略值，将一张牌当你本回合使用的上一张基本牌或普通锦囊牌使用。',
  ['$mini_dingce1'] = '观天下之势，以措平乱之策。',
  ['$mini_dingce2'] = '主公已有成略，进可依计而行。',
}

mini_dingce:addEffect('viewas', {
  pattern = ".",
  interaction = function(self, player)
    local names = {}
    local card = Fk:cloneCard(player:getMark("mini_dingce-turn"))
    if ((Fk.currentResponsePattern == nil and card.skill:canUse(player, card) and not player:prohibitUse(card)) or
      (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
      names = {player:getMark("mini_dingce-turn")}
    end
    if #names == 0 then return end
    return U.CardNameBox {choices = names}
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = skill.name
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function(self, player, use)
    handleMoulue(player.room, player, -1)
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(skill.name, Player.HistoryTurn) == 0 and player:getMark("mini_dingce-turn") ~= 0 and
      player:getMark("@mini_moulue") > 0 and
      #U.getViewAsCardNames(player, skill.name, {"mini_dingce-turn"}) > 0
  end,
  enabled_at_response = function(self, player, response)
    if response or player:usedSkillTimes(skill.name, Player.HistoryTurn) > 0 or
      player:getMark("mini_dingce-turn") == 0 or (player:isNude() and #player:getHandlyIds() == 0) or
      player:getMark("@mini_moulue") < 1 then return false end
    local card = Fk:cloneCard(player:getMark("mini_dingce-turn"))
    return #U.getViewAsCardNames(player, skill.name, {"mini_dingce-turn"}) > 0
  end,
})

mini_dingce:addEffect(fk.CardUsing, {
  can_refresh = function(self, event, target, player, data)
    return target == player and (data.card.type == Card.TypeBasic or data.card:isCommonTrick())
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "mini_dingce-turn", data.card.name)
  end,
})

return mini_dingce
