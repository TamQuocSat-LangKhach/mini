local mini_suanlve = fk.CreateSkill {
  name = "mini_suanlve"
}

Fk:loadTranslationTable{
  ['mini_suanlve'] = '算略',
  ['@mini_moulue'] = '谋略值',
  [':mini_suanlve'] = '游戏开始时，你获得3点<a href=>谋略值</a>。每个回合结束时，你获得X点谋略值（X为你本回合使用牌的类别数）。',
  ['$mini_suanlve1'] = '敌我之人，皆可为我所欲。',
  ['$mini_suanlve2'] = '谋，无主则困；事，无备则废。',
}

mini_suanlve:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player)
    if not player:hasSkill(mini_suanlve.name) then return end
    return player:getMark("@mini_moulue") < 5
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    handleMoulue(room, player, 3)
  end,
})

mini_suanlve:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player)
    if not player:hasSkill(mini_suanlve.name) then return end
    if player:getMark("@mini_moulue") >= 5 then return end
    local card_types = {}
    local room = player.room
    local logic = room.logic
    local e = logic:getCurrentEvent()
    local end_id = e.id
    local events = logic.event_recorder[GameEvent.UseCard] or Util.DummyTable
    for i = #events, 1, -1 do
      e = events[i]
      if e.id <= end_id then break end
      local use = e.data[1]
      if use.from == player.id then
        table.insertIfNeed(card_types, use.card.type)
      end
    end
    if #card_types > 0 then
      event:setCostData(self, #card_types)
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    handleMoulue(room, player, event:getCostData(self))
  end,
})

return mini_suanlve
