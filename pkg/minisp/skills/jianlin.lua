local jianlin = fk.CreateSkill {
  name = "jianlin"
}

Fk:loadTranslationTable{
  ["jianlin"] = "俭吝",
  [":jianlin"] = "一名角色的回合结束时，若你本回合有基本牌因使用、打出或弃置而进入弃牌堆，你可以选择其中一张获得之。",

  ["#jianlin-card"] = "俭吝：选择一张获得",

  ["$jianlin1"] = "吾性至俭，不能自奉，何况遗人？",
  ["$jianlin2"] = "以财自污，则免清高之祸。",
}

local U = require "packages/utility/utility"

jianlin:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(jianlin.name) then return false end
    local room = player.room
    local cards = {}
    local use_cards = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.Processing then
          if move.from == player and (move.moveReason == fk.ReasonUse or move.moveReason == fk.ReasonResponse) then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                table.insertIfNeed(use_cards, info.cardId)
              end
            end
          end
        elseif move.toArea == Card.DiscardPile then
          if move.from == player then
            if move.moveReason == fk.ReasonDiscard then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand then
                  table.insertIfNeed(cards, info.cardId)
                end
              end
            end
          elseif #use_cards > 0 and (move.moveReason == fk.ReasonUse or move.moveReason == fk.ReasonResponse) then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.Processing and table.contains(use_cards, info.cardId) then
                table.insertIfNeed(cards, info.cardId)
              end
            end
          end
        end
      end
      return false
    end, Player.HistoryTurn)
    cards = table.filter(cards, function (id)
      return room:getCardArea(id) == Card.DiscardPile and Fk:getCardById(id).type == Card.TypeBasic
    end)
    if #cards > 0 then
      event:setCostData(self, cards)
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local cards, choice = U.askforChooseCardsAndChoice(
      player,
      event:getCostData(self),
      { "OK" },
      jianlin.name,
      "#jianlin-card",
      { "Cancel" }
    )

    if choice == "OK" then
      event:setCostData(self, cards[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player, event:getCostData(self), true, fk.ReasonJustMove, player, jianlin.name)
  end,
})

return jianlin
