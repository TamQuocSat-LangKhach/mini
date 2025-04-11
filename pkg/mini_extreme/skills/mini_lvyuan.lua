local miniLvyuan = fk.CreateSkill {
  name = "mini_lvyuan"
}

Fk:loadTranslationTable{
  ["mini_lvyuan"] = "虑远",
  [":mini_lvyuan"] = "结束阶段，你可以弃置任意张牌并摸等量的牌，然后若你以此法弃置了至少两张牌且颜色相同，" ..
  "直到你的下回合开始时，当你失去另一种颜色的一张手牌后，你摸一张牌。",

  ["#mini_lvyuan-discard"] = "虑远：弃置任意张牌并摸等量的牌",
  ["@mini_lvyuan"] = "虑远",
  
  ["$mini_lvyuan1"] = "天下风云多变，皆在肃胸腹之中。",
  ["$mini_lvyuan2"] = "卓识远虑，胜乃可图。",
}

miniLvyuan:addEffect(fk.EventPhaseStart, {
  can_trigger = function (self, event, target, player)
    return
      target == player and
      player:hasSkill(miniLvyuan.name) and
      player.phase == Player.Finish and
      not player:isNude()
  end,
  on_use = function (self, event, target, player)
    ---@type string
    local skillName = miniLvyuan.name
    local room = player.room
    local throw = room:askToDiscard(
      player,
      {
        min_num = 1,
        max_num = #player:getCardIds("he"),
        include_equip = true,
        skill_name = skillName,
        cancelable = false,
        prompt = "#mini_lvyuan-discard",
      }
    )
    if not player:isAlive() then return end
    player:drawCards(#throw, skillName)
    if #throw == 1 then return end
    local color = Fk:getCardById(throw[1]).color
    if color == Card.NoColor then return end
    if table.every(throw, function(id) return Fk:getCardById(id).color == color end) then
      room:setPlayerMark(player, "@mini_lvyuan", color == Card.Black and "red" or "black")
    end
  end,
})

miniLvyuan:addEffect(fk.TurnStart, {
  can_refresh = function (self, event, target, player)
    return target == player and player:getMark("@mini_lvyuan") ~= 0
  end,
  on_refresh = function (self, event, target, player)
    player.room:setPlayerMark(player, "@mini_lvyuan", 0)
  end
})

miniLvyuan:addEffect(fk.AfterCardsMove, {
  is_delay_effect = true,
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    if player:getMark("@mini_lvyuan") == 0 or not player:isAlive() then return false end
    local num = 0
    for _, move in ipairs(data) do
      if move.from == player and (move.to ~= move.from or not table.contains({ Card.PlayerEquip, Card.PlayerHand }, move.toArea)) then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId):getColorString() == player:getMark("@mini_lvyuan") and info.fromArea == Card.PlayerHand then
            return true
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local num = 0
    for _, move in ipairs(data) do
      if move.from == player and (move.to ~= move.from or not table.contains({ Card.PlayerEquip, Card.PlayerHand }, move.toArea)) then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId):getColorString() == player:getMark("@mini_lvyuan") and info.fromArea == Card.PlayerHand then
            num = num + 1
          end
        end
      end
    end

    player:drawCards(num, miniLvyuan.name)
  end
})

return miniLvyuan
