local miniShenxian = fk.CreateSkill {
  name = "mini__shenxian"
}

Fk:loadTranslationTable{
  ["mini__shenxian"] = "甚贤",
  [":mini__shenxian"] = "当有角色因弃置而失去基本牌后，你可以摸一张牌。",
}

miniShenxian:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(miniShenxian.name) then
      return false
    end

    for _, move in ipairs(data) do
      if move.from and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).type == Card.TypeBasic then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("shenxian")
    player:drawCards(1, miniShenxian.name)
  end,
})

return miniShenxian
