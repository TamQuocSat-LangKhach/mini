local miniHengyi = fk.CreateSkill {
  name = "mini__hengyi"
}

Fk:loadTranslationTable{
  ["mini__hengyi"] = "恒毅",
  [":mini__hengyi"] = "每回合限一次，当你失去手牌中点数最大的牌后，你可以选择一项：1.令一名其他角色获得此牌；2.摸两张牌。",

  ["#mini__hengyi-invoke"] = "恒毅：你可以选择一项",
}

miniHengyi:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(miniHengyi.name) and player:usedSkillTimes(miniHengyi.name, Player.HistoryTurn) == 0 then
      local ids = {}
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              table.insertIfNeed(ids, info.cardId)
            end
          end
        end
      end
      if #ids == 0 then return end
      if player:isKongcheng() then
        return true
      else
        return table.find(ids, function (id)
          return table.every(player:getCardIds("h"), function (id2)
            return Fk:getCardById(id).number >= Fk:getCardById(id2).number
          end)
        end)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local ids = {}
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
    end
    if #ids == 0 then return end
    ids = table.filter(ids, function (id)
      return table.every(player:getCardIds("h"), function (id2)
        return Fk:getCardById(id).number >= Fk:getCardById(id2).number
      end) and
        table.every(ids, function (id2)
          return Fk:getCardById(id).number >= Fk:getCardById(id2).number
        end)
    end)
    local room = player.room
    room:setPlayerMark(player, "mini__hengyi-tmp", ids)
    local success, dat = room:askToUseActiveSkill(
      player,
      {
        skill_name = "mini__hengyi_active",
        prompt = "#mini__hengyi-invoke",
        no_indicate = false,
      }
    )
    room:setPlayerMark(player, "mini__hengyi-tmp", 0)
    if success and dat then
      event:setCostData(self, { tos = dat.targets, cards = dat.cards, choice = dat.interaction })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = miniHengyi.name
    local room = player.room
    local cost_data = event:getCostData(self)
    if cost_data.choice == "draw2" then
      player:drawCards(2, skillName)
    else
      room:moveCardTo(cost_data.cards, Card.PlayerHand, cost_data.tos[1], fk.ReasonJustMove, skillName, nil, true, player)
    end
  end,
})

return miniHengyi
