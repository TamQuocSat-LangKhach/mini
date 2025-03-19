local pingjiang = fk.CreateSkill {
  name = "mini_pingjiang"
}

Fk:loadTranslationTable{
  ['mini_pingjiang'] = '平江',
  ['#mini_pingjiang-active'] = '你可以发动〖平江〗，选择一名有“讨逆”的角色，视为对其使用【决斗】',
  ['@@mini_taoni'] = '讨逆',
  ['@mini_pingjiang-turn'] = '平江',
  ['#mini_pingjiang_buff'] = '平江',
  [':mini_pingjiang'] = '出牌阶段，你可选择一名有“讨逆”的角色，弃其“讨逆”，视为对其使用【决斗】。若其受到了此【决斗】的伤害，你此回合使用的【决斗】目标角色需要打出【杀】的数量+1，对目标角色造成的伤害+1；否则此技能此回合失效。',
  ['$mini_pingjiang1'] = '一山难存二虎，东吴岂容二王？',
  ['$mini_pingjiang2'] = '九州东南，尽是孙家天下。',
}

pingjiang:addEffect('active', {
  anim_type = "offensive",
  prompt = "#mini_pingjiang-active",
  can_use = function(self, player)
    return U.canUseCard(Fk:currentRoom(), player, Fk:cloneCard("duel"))
  end,
  target_num = 1,
  target_filter = function (skill, player, to_select)
    local target = Fk:currentRoom():getPlayerById(to_select)
    if target:getMark("@@mini_taoni") > 0 then
      local card = Fk:cloneCard("duel")
      card.skillName = pingjiang.name
      return skill:canUseTo(card, target, { bypass_times = true, bypass_distances = true })
    end
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function (skill, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:setPlayerMark(target, "@@mini_taoni", 0)
    local use = room:useVirtualCard("duel", nil, player, target, pingjiang.name, true)
    if use.damageDealt then
      if use.damageDealt[target.id] then
        room:addPlayerMark(player, "@mini_pingjiang-turn")
      else
        room:invalidateSkill(player, pingjiang.name, "-turn")
        room:setPlayerMark(player, "@mini_pingjiang-turn", 0)
      end
    end
  end,
})

pingjiang:addEffect(fk.TargetSpecified | fk.TargetConfirmed | fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:getMark("@mini_pingjiang-turn") == 0 or not data.card or data.card.trueName ~= "duel" then return end
    if event == fk.TargetSpecified then
      return target == player
    elseif event == fk.TargetConfirmed then
      return data.to == player.id
    else
      return target == player and player.room.logic:damageByCardEffect()
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local num = player:getMark("@mini_pingjiang-turn")
    if event ~= fk.DamageCaused then
      data.fixedResponseTimes = data.fixedResponseTimes or {}
      data.fixedResponseTimes["slash"] = (data.fixedResponseTimes["slash"] or 1) + num
      data.fixedAddTimesResponsors = data.fixedAddTimesResponsors or {}
      table.insert(data.fixedAddTimesResponsors, (event == fk.TargetSpecified and data.to or data.from))
    else
      data.damage = data.damage + num
    end
  end,
})

return pingjiang
