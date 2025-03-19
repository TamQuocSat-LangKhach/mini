local mini__shenxian = fk.CreateSkill {
  name = "mini__shenxian"
}

Fk:loadTranslationTable{
  ['mini__shenxian'] = '甚贤',
  [':mini__shenxian'] = '当有角色因弃置而失去基本牌后，你可以摸一张牌。',
}

mini__shenxian:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(mini__shenxian.name) then return false end
    for _, move in ipairs(data) do
      local from = move.from and player.room:getPlayerById(move.from) or nil
      if from and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).type == Card.TypeBasic then
            return true
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local targets = {}
    for _, move in ipairs(data) do
      local from = move.from and player.room:getPlayerById(move.from) or nil
      if from and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).type == Card.TypeBasic then
            table.insertIfNeed(targets, from.id)
          end
        end
      end
    end
    for i = 1, #targets do
      if not player:hasSkill(mini__shenxian.name) then break end
      skill:doCost(event, nil, player, data)
    end
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("shenxian")
    player:drawCards(1, mini__shenxian.name)
  end,
})

return mini__shenxian
