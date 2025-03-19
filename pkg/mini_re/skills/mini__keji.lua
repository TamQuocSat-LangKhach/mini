local mini__keji = fk.CreateSkill {
  name = "mini__keji"
}

Fk:loadTranslationTable{
  ['mini__keji'] = '克己',
  [':mini__keji'] = '当你使用一张基本牌时，若此时为你的出牌阶段，你摸一张牌，本回合的手牌上限+1。',
}

mini__keji:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mini__keji.name) and data.card.type == Card.TypeBasic and player.phase == Player.Play
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, mini__keji.name)
    player.room:addPlayerMark(player, MarkEnum.AddMaxCardsInTurn, 1)
  end,
})

return mini__keji
