local mini__jianxiong = fk.CreateSkill {
  name = "mini__jianxiong"
}

Fk:loadTranslationTable{
  ['mini__jianxiong'] = '奸雄',
  ['@$mini__jianxiong-turn'] = '奸雄',
  [':mini__jianxiong'] = '当你于你的回合内使用牌造成伤害后，你可以获得造成伤害的牌（每回合每牌名的牌限一次）。',
}

mini__jianxiong:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(mini__jianxiong.name) and target == player and data.card and player.phase ~= Player.NotActive and 
      not table.contains(player:getTableMark("@$mini__jianxiong-turn"), data.card.trueName) and 
      table.every(data.card:isVirtual() and data.card.subcards or {data.card.id}, function(id) return player.room:getCardArea(id) == Card.Processing end) and not player.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("guixin")
    room:addTableMark(player, "@$mini__jianxiong-turn", data.card.trueName)
    room:obtainCard(player, data.card, true, fk.ReasonJustMove)
  end,
})

return mini__jianxiong
