local miniYanshi = fk.CreateSkill {
  name = "mini_yanshi"
}

Fk:loadTranslationTable{
  ["mini_yanshi"] = "演势",
  [":mini_yanshi"] = "出牌阶段限一次，你可从牌堆顶或牌堆底（不可与你此阶段上一次选择的相同）摸一张牌。若你于此阶段使用了此牌，你可弃置一张牌再次发动〖演势〗。",

  ["#mini_yanshi_only"] = "演势：从%arg摸一张牌",
  ["#mini_yanshi_choose"] = "演势：选择从牌堆顶或牌堆底摸一张牌",
  ["@@mini_yanshi-inhand-phase"] = "演势",

  ["$mini_yanshi1"] = "进荆州，取巴蜀，以成峙鼎三分之势。",
  ["$mini_yanshi2"] = "天下虽多庸饶，亦在隆中方寸之间。",
}

miniYanshi:addEffect("active", {
  can_use = function(self, player)
    return player:usedSkillTimes(miniYanshi.name, Player.HistoryPhase) == player:getMark("_mini_yanshi-phase")
  end,
  target_num = 0,
  card_num = function(self, player)
    return player:usedSkillTimes(miniYanshi.name, Player.HistoryPhase) > 0 and 1 or 0
  end,
  card_filter = function(self, player, to_select, selected_cards)
    return
      #selected_cards < (player:usedSkillTimes(miniYanshi.name, Player.HistoryPhase) > 0 and 1 or 0) and
      not player:prohibitDiscard(Fk:getCardById(to_select))
  end,
  interaction = function(self, player)
    local all_choices = { "Top", "Bottom" }
    local choices = table.simpleClone(all_choices)
    table.removeOne(choices, player:getMark("_mini_yanshi_record-phase"))
    return UI.ComboBox { choices = choices, all_choices = all_choices }
  end,
  prompt = function(self, player, selected_cards, selected_targets)
    local choices = { "Top", "Bottom" }
    table.removeOne(choices, player:getMark("_mini_yanshi_record-phase"))
    if #choices == 1 then
      return "#mini_yanshi_only:::" .. choices[1]
    else
      return "#mini_yanshi_choose"
    end
  end,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = miniYanshi.name
    local player = effect.from
    local choice = self.interaction.data
    if not choice then return false end
    room:setPlayerMark(player, "_mini_yanshi_record-phase", choice)
    if #effect.cards > 0 then
      room:throwCard(effect.cards, skillName, player, player)
      if not player:isAlive() then return end
    end
    player:drawCards(1, skillName, choice == "Bottom" and "bottom" or "top", "@@mini_yanshi-inhand-phase")
  end,
})

miniYanshi:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return
      target == player and
      table.find(Card:getIdList(data.card), function(id)
        return Fk:getCardById(id):getMark("@@mini_yanshi-inhand-phase") > 0
      end)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, "mini_yanshi", "special")
    room:addPlayerMark(player, "_mini_yanshi-phase")
  end,
})

return miniYanshi
