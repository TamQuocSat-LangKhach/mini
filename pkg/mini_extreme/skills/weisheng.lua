local weisheng = fk.CreateSkill {
  name = "mini__weisheng"
}

Fk:loadTranslationTable{
  ['mini__weisheng'] = '威乘',
  ['#mini__weisheng'] = '威乘：与至少%arg名角色拼点，胜者可以使用一张指定所有败者为目标的【杀】',
  ['#mini__weisheng-slash'] = '威乘：你可以使用一张指定所有败者为目标的【杀】',
  ['#mini__weisheng_delay'] = '威乘',
  [':mini__weisheng'] = '出牌阶段限一次，你可以与至少全场半数（向上取整）角色进行一次<a href=>逐鹿</a>，胜者可以使用一张指定所有败者为目标的【杀】。若有败者使用【闪】抵消此【杀】，此【杀】结算后，未使用【闪】的败者失去1点体力。',
}

weisheng:addEffect('active', {
  anim_type = "control",
  prompt = function (self, player)
    return "#mini__weisheng:::"..(#Fk:currentRoom().alive_players + 1) // 2
  end,
  card_num = 0,
  min_target_num = function ()
    return (#Fk:currentRoom().alive_players + 1) // 2
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(weisheng.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, _, _, _)
    return to_select ~= player.id and player:canPindian(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect, player)
    local targets = table.map(effect.tos, Util.Id2PlayerMapper)
    local pindian = U.jointPindian(player, targets, weisheng.name)
    local winner = pindian.winner
    if winner and not winner.dead then
      table.insert(targets, player)
      targets = table.filter(targets, function (p)
        return p ~= winner and not p.dead and winner:canUseTo(Fk:cloneCard("slash"), p, {bypass_distances = true, bypass_times = true})
      end)
      if #targets == 0 then return end
      targets = table.map(targets, Util.IdMapper)
      local use = room:askToUseRealCard(winner, {
        pattern = "slash",
        skill_name = weisheng.name,
        prompt = "#mini__weisheng-slash",
        extra_data = { bypass_distances = true, bypass_times = true, exclusive_targets = targets },
        cancelable = true
      })
      if use then
        use.extraUse = true
        use.extra_data = use.extra_data or {}
        use.extra_data.mini__weisheng = targets
        use.tos = table.map(targets, function (id) return {id} end)
        room:useCard(use)
      end
    end
  end,
})

weisheng:addEffect(fk.CardUseFinished, {
  global = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.extra_data and data.extra_data.mini__weisheng_trigger and
      table.find(data.extra_data.mini__weisheng, function (id)
        return not player.room:getPlayerById(id).dead
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(data.extra_data.mini__weisheng, function (id)
      return not room:getPlayerById(id).dead
    end)
    room:sortPlayersByAction(targets)
    for _, id in ipairs(targets) do
      local p = room:getPlayerById(id)
      if not p.dead then
        room:loseHp(p, 1, weisheng.name)
      end
    end
  end,
})

weisheng:addEffect(fk.CardEffectCancelledOut, {
  global = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and data.extra_data and data.extra_data.mini__weisheng and
      table.contains(data.extra_data.mini__weisheng, data.to)
  end,
  on_use = function (self, event, target, player, data)
    data.extra_data.mini__weisheng_trigger = true
    local dat = data.extra_data.mini__weisheng
    for i = #dat, 1, -1 do
      if dat[i] == data.to then
        table.remove(dat, i)
      end
    end
    data.extra_data.mini__weisheng = dat
  end,
})

return weisheng
