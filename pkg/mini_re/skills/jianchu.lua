local jianchu = fk.CreateSkill {
  name = "mini__jianchu"
}

Fk:loadTranslationTable{
  ['mini__jianchu'] = '鞬出',
  [':mini__jianchu'] = '当你使用【杀】指定目标后，你可弃置其一张牌，若此牌：为装备牌，其不能使用【闪】抵消此【杀】；不为装备牌，你获得此牌。',
}

jianchu:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(jianchu.name)) then return end
    local to = player.room:getPlayerById(data.to)
    return data.card.trueName == "slash" and not to:isNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    local id = room:askToChooseCard(player, {
      target = to,
      flag = "he",
      skill_name = jianchu.name
    })
    room:throwCard({id}, jianchu.name, to, player)
    local card = Fk:getCardById(id)
    if card.type == Card.TypeEquip then
      data.disresponsive = true
    else
      room:obtainCard(player.id, card, true)
    end
  end,
})

return jianchu
