local yajiao = fk.CreateSkill {
  name = "mini_ex__yajiao"
}

Fk:loadTranslationTable{
  ['mini_ex__yajiao'] = '涯角',
  [':mini_ex__yajiao'] = '当你于回合外使用或打出手牌时，你可摸一张牌。',
}

yajiao:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yajiao.name) and player.phase == Player.NotActive and U.IsUsingHandcard(player, data)
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("yajiao")
    player:drawCards(1, yajiao.name)
  end
})

yajiao:addEffect(fk.CardResponding, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yajiao.name) and player.phase == Player.NotActive and U.IsUsingHandcard(player, data)
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("yajiao")
    player:drawCards(1, yajiao.name)
  end
})

return yajiao
