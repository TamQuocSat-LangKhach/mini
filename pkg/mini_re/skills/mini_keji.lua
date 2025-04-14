local miniKeji = fk.CreateSkill {
  name = "mini__keji"
}

Fk:loadTranslationTable{
  ["mini__keji"] = "克己",
  [":mini__keji"] = "当你于出牌阶段内使用一张基本牌时，你摸一张牌，本回合手牌上限+1。",
}

miniKeji:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(miniKeji.name) and data.card.type == Card.TypeBasic and player.phase == Player.Play
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, miniKeji.name)
    player.room:addPlayerMark(player, MarkEnum.AddMaxCardsInTurn, 1)
  end,
})

return miniKeji
