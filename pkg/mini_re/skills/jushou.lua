local jushou = fk.CreateSkill({
  name = "mini__jushou",
})

Fk:loadTranslationTable{
  ["mini__jushou"] = "据守",
  [":mini__jushou"] = "结束阶段，若你未于本回合出牌阶段造成过伤害，你可以摸三张牌。",

  ["$mini__jushou1"] = "",
  ["$mini__jushou2"] = "",
}

jushou:addEffect(fk.EventPhaseEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(jushou.name) and player.phase == Player.Finish then
      local phase_events = player.room.logic:getEventsOfScope(GameEvent.Phase, 999, function (e)
        return e.data.phase == Player.Play
      end, Player.HistoryTurn)
      return #player.room.logic:getActualDamageEvents(1, function (e)
        return e.data.from == player and
        table.find(phase_events, function (phase)
          return phase.id < e.id and phase.end_id > e.id
        end) ~= nil
      end, Player.HistoryTurn) == 0
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(3, jushou.name)
  end,
})

return jushou
