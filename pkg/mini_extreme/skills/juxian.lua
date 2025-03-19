local juxian = fk.CreateSkill {
  name = "mini_juxian"
}

Fk:loadTranslationTable{
  ['mini_juxian'] = '举贤',
  [':mini_juxian'] = '你的回合内，当其他角色的牌因使用、打出或弃置而进入弃牌堆后，你获得之（至多为3）。',
  ['$mini_juxian1'] = '遍推贤能，以襄明公大业。',
  ['$mini_juxian2'] = '天下贤才之至，皆系于明公。',
}

juxian:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(juxian) or player:getMark("mini_juxian-turn") > 2 or player.room.current ~= player then return false end
    local room = player.room
    local to_get = {}
    local move_event = room.logic:getCurrentEvent()
    local parent_event = move_event.parent
    if parent_event and (parent_event.event == GameEvent.UseCard or parent_event.event == GameEvent.RespondCard) then
      local parent_data = parent_event.data[1]
      if parent_data.from ~= player.id then
        local card_ids = room:getSubcardsByRule(parent_data.card)
        for _, move in ipairs(data) do
          if move.toArea == Card.DiscardPile then
            for _, info in ipairs(move.moveInfo) do
              local id = info.cardId
              if info.fromArea == Card.Processing and room:getCardArea(id) == Card.DiscardPile and table.contains(card_ids, id) then
                table.insertIfNeed(to_get, id)
              end
            end
          end
        end
      end
    else
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          local from = move.from
          if from and from ~= player.id and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and room:getCardArea(info.cardId) == Card.DiscardPile then
                table.insertIfNeed(to_get, info.cardId)
              end
            end
          end
        end
      end
    end
    if #to_get > 0 then
      event:setCostData(skill, to_get)
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(skill)
    local x = player:getMark("mini_juxian-turn")
    if x >= 3 then return false end
    if #cards + x > 3 then
      cards = table.random(cards, 3-x)
    end
    room:addPlayerMark(player, "mini_juxian-turn", #cards)
    room:obtainCard(player, cards, true, fk.ReasonPrey, player.id, juxian.name)
  end,
})

return juxian
