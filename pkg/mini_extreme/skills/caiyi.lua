local caiyi = fk.CreateSkill {
  name = "mini__caiyi"
}

Fk:loadTranslationTable{
  ['mini__caiyi'] = '才溢',
  ['#mini__caiyi-choice'] = '才溢：获得其中一种颜色的牌',
  [':mini__caiyi'] = '每回合限一次，当你因使用而失去一种类别的所有手牌后，你可以展示牌堆顶X张牌（X为你手牌的类别数），然后获得其中一种颜色的所有牌。本局游戏你每发动一次此技能，以此法展示牌的数量额外+1（至多+3）。',
}

caiyi:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(caiyi) or player:usedSkillTimes(caiyi.name, Player.HistoryTurn) > 0 or
      (player:isKongcheng() and player:usedSkillTimes(caiyi.name, Player.HistoryGame) == 0) then return end
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonUse then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand and
            not table.find(player:getCardIds("h"), function (id)
              return Fk:getCardById(id).type == Fk:getCardById(info.cardId).type
            end) then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = math.min(3, player:usedSkillTimes(caiyi.name, Player.HistoryGame) - 1)
    local types = {}
    for _, id in ipairs(player:getCardIds("h")) do
      table.insertIfNeed(types, Fk:getCardById(id).type)
    end
    n = n + #types
    local cards = room:getNCards(n)
    room:moveCardTo(cards, Card.Processing, nil, fk.ReasonJustMove, caiyi.name, nil, true, player.id)
    local red, black = {}, {}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id).color == Card.Red then
        table.insert(red, id)
      elseif Fk:getCardById(id).color == Card.Black then
        table.insert(black, id)
      end
    end
    local choices = {}
    if #red > 0 then
      table.insert(choices, "red")
    end
    if #black > 0 then
      table.insert(choices, "black")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = caiyi.name,
      prompt = "#mini__caiyi-choice"
    })
    if choice == "red" then
      room:moveCardTo(red, Card.PlayerHand, player, fk.ReasonJustMove, caiyi.name, nil, true, player.id)
    else
      room:moveCardTo(black, Card.PlayerHand, player, fk.ReasonJustMove, caiyi.name, nil, true, player.id)
    end
    room:cleanProcessingArea(cards)
  end,
})

return caiyi
