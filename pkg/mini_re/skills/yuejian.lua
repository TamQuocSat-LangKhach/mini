local yuejian = fk.CreateSkill {
  name = "mini__yuejian",
}

Fk:loadTranslationTable{
  ["mini__yuejian"] = "约俭",
  [":mini__yuejian"] = "结束阶段，你可以将手牌摸至体力值。",
}

yuejian:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yuejian.name) and player.phase == Player.Finish and
      player:getHandcardNum() < player.hp
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(player.hp - player:getHandcardNum(), yuejian.name)
  end,
})

return yuejian
