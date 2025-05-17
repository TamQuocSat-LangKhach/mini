local beige = fk.CreateSkill {
  name = "mini__beige",
}

Fk:loadTranslationTable{
  ["mini__beige"] = "悲歌",
  [":mini__beige"] = "每回合限一次，当一名角色受到【杀】造成的伤害后，你可以弃置一张手牌，若为：红色，其摸两张牌；黑色，你视为对其使用【杀】。",

  ["#mini__beige-invoke"] = "悲歌：%dest 受到伤害，你可以弃一张红色手牌令其摸两张牌，或弃一张黑色手牌视为对其使用【杀】",

  ["$mini__beige1"] = "",
  ["$mini__beige2"] = "",
}

beige:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(beige.name) and data.card and data.card.trueName == "slash" and
      not target.dead and not player:isKongcheng() and
      player:usedSkillTimes(beige.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = beige.name,
      cancelable = true,
      prompt = "#mini__beige-invoke::"..target.id,
      skip = true,
      pattern = target == player and ".|.|heart,diamond|hand" or ".",
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local color = Fk:getCardById(event:getCostData(self).cards[1]).color
    room:throwCard(event:getCostData(self).cards, beige.name, player, player)
    if target.dead then return false end
    if color == Card.Red then
      target:drawCards(2, beige.name)
    elseif color == Card.Black then
      room:useVirtualCard("slash", nil, player, target, beige.name, true)
    end
  end,
})

return beige
