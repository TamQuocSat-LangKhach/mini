local miniSuanlve = fk.CreateSkill {
  name = "mini_suanlve"
}

Fk:loadTranslationTable{
  ["mini_suanlve"] = "算略",
  [":mini_suanlve"] = "游戏开始时，你获得3点<a href='mini_moulue'>谋略值</a>。每个回合结束时，你获得X点谋略值（X为你本回合使用牌的类别数）。",

  ["$mini_suanlve1"] = "敌我之人，皆可为我所欲。",
  ["$mini_suanlve2"] = "谋，无主则困；事，无备则废。",
}

local miniUtil = require "packages/mini/mini_util"

miniSuanlve:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(miniSuanlve.name) and player:getMark("@mini_moulue") < 5
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    miniUtil.handleMoulue(room, player, 3)
  end,
})

miniSuanlve:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player)
    if not player:hasSkill(miniSuanlve.name) or player:getMark("@mini_moulue") >= 5 then
      return false
    end

    return
      #player.room.logic:getEventsOfScope(
        GameEvent.UseCard,
        1,
        function(e)
          return e.data.from == player
        end,
        Player.HistoryTurn
      ) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    local cardTypes = {}
    room.logic:getEventsOfScope(
      GameEvent.UseCard,
      1,
      function(e)
        local data = e.data
        if data.from == player then
          table.insertIfNeed(cardTypes, data.card.type)
        end

        return false
      end,
      Player.HistoryTurn
    )

    miniUtil.handleMoulue(room, player, #cardTypes)
  end,
})

return miniSuanlve
