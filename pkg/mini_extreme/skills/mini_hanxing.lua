local miniHanxing = fk.CreateSkill {
  name = "mini__hanxing",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["mini__hanxing"] = "酣兴",
  [":mini__hanxing"] = "锁定技，每回合你首次对自己使用牌后，你下一次造成的伤害+1。",

  ["@mini__hanxing"] = "酣兴+",
}

miniHanxing:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if
      target == player and
      player:hasSkill(miniHanxing.name) and
      table.contains(data.tos, player)
    then
      local events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data
        return use.from == player and table.contains(use.tos, player)
      end, Player.HistoryTurn)
      return #events > 0 and player.room.logic:getCurrentEvent().id == events[1].id
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@mini__hanxing", 1)
  end,
})

miniHanxing:addEffect(fk.DamageCaused, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@mini__hanxing") > 0
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(player:getMark("@mini__hanxing"))
    player.room:setPlayerMark(player, "@mini__hanxing", 0)
  end,
})

return miniHanxing
