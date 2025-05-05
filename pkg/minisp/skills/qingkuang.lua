local qingkuang = fk.CreateSkill {
  name = "qingkuang",
}

Fk:loadTranslationTable{
  ["qingkuang"] = "清狂",
  [":qingkuang"] = "出牌阶段，你可以弃置一张牌（每阶段每种颜色限一次），然后摸两张牌。结束阶段，你弃置本回合以此法摸到的牌。",

  ["#qingkuang"] = "清狂：弃一张牌，摸两张牌，结束阶段弃置摸到的牌",
  ["@@qingkuang-inhand-turn"] = "清狂",

  ["$qingkuang1"] = "",
  ["$qingkuang2"] = "",
}

qingkuang:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#qingkuang",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return #player:getTableMark("qingkuang-phase") < 2
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and not player:prohibitDiscard(to_select) and Fk:getCardById(to_select).color ~= Card.NoColor and
      not table.contains(player:getTableMark("qingkuang-phase"), Fk:getCardById(to_select).color)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:addTableMark(player, "qingkuang-phase", Fk:getCardById(effect.cards[1]).color)
    room:throwCard(effect.cards, qingkuang.name, player, player)
    if player.dead then return end
    player:drawCards(2, qingkuang.name, nil, "@@qingkuang-inhand-turn")
  end,
})

qingkuang:addEffect(fk.EventPhaseStart, {
  priority = 0.1,
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player.phase == Player.Finish and
      table.find(player:getCardIds("h"), function (id)
        return Fk:getCardById(id):getMark("@@qingkuang-inhand-turn") > 0
      end)
  end,
  on_use = function (self, event, target, player, data)
    local cards = table.filter(player:getCardIds("h"), function (id)
      return Fk:getCardById(id):getMark("@@qingkuang-inhand-turn") > 0 and not player:prohibitDiscard(id)
    end)
    if #cards > 0 then
      player.room:throwCard(cards, qingkuang.name, player, player)
    end
  end,
})

qingkuang:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "qingkuang-phase", 0)
end)

return qingkuang
