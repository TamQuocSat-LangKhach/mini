local mengjin = fk.CreateSkill {
  name = "mini_ex__mengjin"
}

Fk:loadTranslationTable{
  ["mini_ex__mengjin"] = "猛进",
  [":mini_ex__mengjin"] = "当你使用【杀】指定目标后，你可弃置其一张牌，若此牌：为装备牌，其不能响应此【杀】；不为装备牌，你获得此牌。",
}

mengjin:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mengjin.name) and
      data.card.trueName == "slash" and not data.to:isNude()
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = mengjin.name
    local room = player.room
    local to = data.to
    local id = room:askToChooseCard(player, {
      target = to,
      flag = "he",
      skill_name = skillName,
    })

    local card = Fk:getCardById(id)
    room:throwCard(id, skillName, to, player)

    if card.type == Card.TypeEquip then
      data.disresponsive = true
    else
      if room:getCardArea(id) == Card.DiscardPile and not player.dead then
        room:obtainCard(player, card, true, fk.ReasonPrey, player, skillName)
      end
    end
  end,
})

return mengjin
