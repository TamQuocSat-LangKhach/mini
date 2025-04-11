local miniPingjiang = fk.CreateSkill {
  name = "mini_pingjiang"
}

Fk:loadTranslationTable{
  ["mini_pingjiang"] = "平江",
  [":mini_pingjiang"] = "出牌阶段，你可选择一名有“讨逆”标记的角色，移去其“讨逆”，视为对其使用【决斗】。若其受到了此【决斗】的伤害，" ..
  "你此回合使用的【决斗】目标角色需要打出【杀】的数量+1，对目标角色造成的伤害+1；否则此技能此回合失效。",

  ["#mini_pingjiang-active"] = "你可以发动〖平江〗，选择一名有“讨逆”的角色，视为对其使用【决斗】",
  ["@mini_pingjiang-turn"] = "平江",

  ["$mini_pingjiang1"] = "一山难存二虎，东吴岂容二王？",
  ["$mini_pingjiang2"] = "九州东南，尽是孙家天下。",
}

miniPingjiang:addEffect("active", {
  anim_type = "offensive",
  prompt = "#mini_pingjiang-active",
  can_use = function(self, player)
    return player:canUse(Fk:cloneCard("duel"))
  end,
  target_num = 1,
  target_filter = function (self, player, to_select)
    if to_select:getMark("@@mini_taoni") > 0 then
      local card = Fk:cloneCard("duel")
      card.skillName = miniPingjiang.name
      return player:canUseTo(card, to_select, { bypass_times = true, bypass_distances = true })
    end
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function (self, room, effect)
    ---@type string
    local skillName = miniPingjiang.name
    local player = effect.from
    local target = effect.tos[1]
    room:setPlayerMark(target, "@@mini_taoni", 0)
    local use = room:useVirtualCard("duel", nil, player, target, skillName, true)
    if use and use.damageDealt then
      if use.damageDealt[target] then
        room:addPlayerMark(player, "@mini_pingjiang-turn")
      else
        room:invalidateSkill(player, skillName, "-turn")
        room:setPlayerMark(player, "@mini_pingjiang-turn", 0)
      end
    end
  end,
})

miniPingjiang:addEffect(fk.TargetSpecified, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:getMark("@mini_pingjiang-turn") ~= 0 and
      data.card and
      data.card.trueName == "duel"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local num = player:getMark("@mini_pingjiang-turn")
    data.fixedResponseTimes = (data.fixedResponseTimes or 1) + num
    data.fixedAddTimesResponsors = data.fixedAddTimesResponsors or {}
    table.insert(data.fixedAddTimesResponsors, data.to)
  end,
})

miniPingjiang:addEffect(fk.TargetConfirmed, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return
      data.to == player and
      player:getMark("@mini_pingjiang-turn") ~= 0 and
      data.card and
      data.card.trueName == "duel"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local num = player:getMark("@mini_pingjiang-turn")
    data.fixedResponseTimes = (data.fixedResponseTimes or 0) + num
    data.fixedAddTimesResponsors = data.fixedAddTimesResponsors or {}
    table.insert(data.fixedAddTimesResponsors, data.from)
  end,
})

miniPingjiang:addEffect(fk.DamageCaused, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      data.by_user and
      player:getMark("@mini_pingjiang-turn") ~= 0 and
      data.card and
      data.card.trueName == "duel"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:changeDamage(player:getMark("@mini_pingjiang-turn"))
  end,
})

return miniPingjiang
