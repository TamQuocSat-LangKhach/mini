local miniHupo = fk.CreateSkill {
  name = "mini__hupo",
}

Fk:loadTranslationTable{
  ["mini__hupo"] = "虎魄",
  [":mini__hupo"] = "出牌阶段各限一次，你可以展示你与一名其他角色的手牌，然后你选择一项：1.弃置你与其一个牌名的所有牌；"..
  "2.弃置其一张你没有的牌名的牌。",

  ["#mini__hupo"] = "虎魄：展示你与一名角色所有手牌，然后弃置其中一种牌或获得其一张牌",
  ["mini__hupo1"] = "弃置双方一个牌名的所有牌",
  ["mini__hupo2"] = "获得其一张你没有的牌名的牌",
  ["#mini__hupo1-discard"] = "虎魄：选择要弃置的牌名",
  ["#mini__hupo2-discard"] = "虎魄：弃置 %dest 的一张牌",
}

miniHupo:addEffect("active", {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#mini__hupo",
  can_use = function(self, player)
    return #player:getTableMark("mini__hupo-phase") < 2
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return
      #selected == 0 and
      to_select ~= player and
      not (player:isKongcheng() and to_select:isKongcheng())
  end,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = miniHupo.name
    local player = effect.from
    local target = effect.tos[1]
    if not player:isKongcheng() then
      player:showCards(player:getCardIds("h"))
    end
    if not target:isKongcheng() and target:isAlive() then
      target:showCards(target:getCardIds("h"))
    end
    if not (player:isAlive() and target:isAlive()) then return end
    local choices = {}
    if not (player:isNude() and target:isNude()) and
      not table.contains(player:getTableMark("mini__hupo-phase"), "mini__hupo1") then
      table.insert(choices, "mini__hupo1")
    end
    local cards = table.filter(target:getCardIds("he"), function(id)
      return not table.find(player:getCardIds("he"), function(id2)
        return Fk:getCardById(id).trueName == Fk:getCardById(id2).trueName
      end)
    end)
    if #cards > 0 and
      not table.contains(player:getTableMark("mini__hupo-phase"), "mini__hupo2") then
      table.insert(choices, "mini__hupo2")
    end
    if #choices == 0 then return end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = skillName,
    })
    room:addTableMark(player, "mini__hupo-phase", choice)
    if choice == "mini__hupo1" then
      choices = {}
      for _, id in ipairs(player:getCardIds("he")) do
        if not player:prohibitDiscard(id) then
          table.insertIfNeed(choices, Fk:getCardById(id).trueName)
        end
      end
      for _, id in ipairs(target:getCardIds("he")) do
        table.insertIfNeed(choices, Fk:getCardById(id).trueName)
      end
      choice = room:askToChoice(player, {
        choices = choices,
        skill_name = skillName,
        prompt = "#mini__hupo1-discard",
      })
      local moves = {}
      local ids = table.filter(player:getCardIds("he"), function(id)
        return Fk:getCardById(id).trueName == choice and not player:prohibitDiscard(id)
      end)
      if #ids > 0 then
        table.insert(moves, {
          ids = ids,
          from = player,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonDiscard,
          skillName = skillName,
          proposer = player,
          moveVisible = true,
        })
      end
      ids = table.filter(target:getCardIds("he"), function(id)
        return Fk:getCardById(id).trueName == choice
      end)
      if #ids > 0 then
        table.insert(moves, {
          ids = ids,
          from = target,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonDiscard,
          skillName = skillName,
          proposer = player,
          moveVisible = true,
        })
      end
      room:moveCards(table.unpack(moves))
    else
      local card = room:askToChooseCard(player, {
        target = target,
        flag = { card_data = {{ target.general, cards }} },
        skill_name = miniHupo.name,
        prompt = "#mini__hupo2-discard::" .. target.id,
      })
      room:throwCard(card, miniHupo.name, target, player)
    end
  end,
})

miniHupo:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "mini__hupo-phase", 0)
end)

return miniHupo
