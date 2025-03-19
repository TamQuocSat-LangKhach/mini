local hanxing = fk.CreateSkill {
  name = "mini__hanxing"
}

Fk:loadTranslationTable{
  ['mini__hanxing'] = '酣兴',
  ['@mini__hanxing'] = '酣兴',
  ['#mini__hanxing_trigger'] = '酣兴',
  [':mini__hanxing'] = '锁定技，每回合你首次对自己使用牌后，你下一次造成的伤害+1。',
}

hanxing:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(hanxing.name) and
      table.contains(TargetGroup:getRealTargets(data.tos), player.id) then
      local events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        return use.from == player.id and table.contains(TargetGroup:getRealTargets(use.tos), player.id)
      end, Player.HistoryTurn)
      return events and player.room.logic:getCurrentEvent().id == events[1].id
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@mini__hanxing", 1)
  end,
})

hanxing:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@mini__hanxing") > 0
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + player:getMark("@mini__hanxing")
    player.room:setPlayerMark(player, "@mini__hanxing", 0)
  end,
})

return hanxing
