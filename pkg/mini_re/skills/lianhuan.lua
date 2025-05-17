local lianhuan = fk.CreateSkill {
  name = "mini__lianhuan",
}

Fk:loadTranslationTable{
  ["mini__lianhuan"] = "连环",
  [":mini__lianhuan"] = "你可以将一张♣手牌当【铁索连环】使用或重铸。摸牌阶段，你额外摸X张牌（X为场上处于连环状态的角色数，至多为3）。",

  ["#mini__lianhuan"] = "连环：你可以将一张♣手牌当【铁索连环】使用或重铸",
}

lianhuan:addEffect("active", {
  mute = true,
  prompt = "#mini__lianhuan",
  card_num = 1,
  min_target_num = 0,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Club and table.contains(player:getHandlyIds(), to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected_cards == 1 then
      local card = Fk:cloneCard("iron_chain")
      card:addSubcard(selected_cards[1])
      card.skillName = lianhuan.name
      return player:canUse(card) and card.skill:targetFilter(player, to_select, selected, selected_cards, card)
    end
  end,
  feasible = function (self, player, selected, selected_cards)
    if #selected_cards == 1 then
      if #selected == 0 then
        return table.contains(player:getCardIds("h"), selected_cards[1])
      else
        local card = Fk:cloneCard("iron_chain")
        card:addSubcard(selected_cards[1])
        card.skillName = lianhuan.name
        return card.skill:feasible(player, selected, {}, card)
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    player:broadcastSkillInvoke(lianhuan.name)
    if #effect.tos == 0 then
      room:notifySkillInvoked(player, lianhuan.name, "drawcard")
      room:recastCard(effect.cards, player, lianhuan.name)
    else
      room:notifySkillInvoked(player, lianhuan.name, "control")
      room:sortByAction(effect.tos)
      room:useVirtualCard("iron_chain", effect.cards, player, effect.tos, lianhuan.name)
    end
  end,
})

lianhuan:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(lianhuan.name) and
      table.find(player.room.alive_players, function (p)
        return p.chained
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local n = #table.filter(player.room.alive_players, function (p)
      return p.chained
    end)
    data.n = data.n + math.max(n, 3)
  end,
})

return lianhuan
