local miniWeicheng = fk.CreateSkill {
  name = "mini__weicheng"
}

Fk:loadTranslationTable{
  ["mini__weicheng"] = "威乘",
  [":mini__weicheng"] = "出牌阶段限一次，你可以与至少全场半数（向上取整）角色进行一次<a href='zhuluPindian'>逐鹿</a>，" ..
  "胜者可以使用一张指定所有败者为目标的【杀】。若有败者使用【闪】抵消此【杀】，此【杀】结算后，未使用【闪】的败者失去1点体力。",

  ["#mini__weicheng"] = "威乘：与至少%arg名角色拼点，胜者可以使用一张指定所有败者为目标的【杀】",
  ["#mini__weicheng-slash"] = "威乘：你可以使用一张指定所有败者为目标的【杀】",
}

local U = require "packages/utility/utility"

miniWeicheng:addEffect("active", {
  anim_type = "control",
  prompt = function (self, player)
    return "#mini__weicheng:::" .. (#Fk:currentRoom().alive_players + 1) // 2
  end,
  card_num = 0,
  min_target_num = function ()
    return (#Fk:currentRoom().alive_players + 1) // 2
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(miniWeicheng.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select)
    return to_select ~= player and player:canPindian(to_select)
  end,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = miniWeicheng.name
    local player = effect.from
    local targets = effect.tos
    local pindian = U.startZhuLu(player, targets, skillName)
    local winner = pindian.winner
    if winner and winner:isAlive() then
      table.insert(targets, player)
      targets = table.filter(targets, function (p)
        return p ~= winner and p:isAlive() and winner:canUseTo(Fk:cloneCard("slash"), p, { bypass_distances = true, bypass_times = true })
      end)
      if #targets == 0 then return end

      local use = room:askToPlayCard(
        winner,
        {
          pattern = "slash",
          skill_name = skillName,
          prompt = "#mini__weicheng-slash",
          extra_data = { bypass_distances = true, extraUse = true, must_targets = table.map(targets, Util.IdMapper) },
          skip = true,
        }
      )
      if use then
        use.tos = targets
        use.extra_data = use.extra_data or {}
        use.extra_data.mini__weicheng = table.map(targets, Util.IdMapper)
        room:useCard(use)
      end
    end
  end,
})

miniWeicheng:addEffect(fk.CardUseFinished, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      data.extra_data and
      data.extra_data.mini__weicheng_trigger and
      table.find(data.extra_data.mini__weicheng, function (id)
        return player.room:getPlayerById(id):isAlive()
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(data.extra_data.mini__weicheng, function (id)
      return room:getPlayerById(id):isAlive()
    end)

    targets = table.map(targets, function(id) return room:getPlayerById(id) end)
    room:sortByAction(targets)
    for _, p in ipairs(targets) do
      if p:isAlive() then
        room:loseHp(p, 1, miniWeicheng.name)
      end
    end
  end,
})

miniWeicheng:addEffect(fk.CardEffectCancelledOut, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return
      target == player and
      data.extra_data and
      data.extra_data.mini__weicheng and
      table.contains(data.extra_data.mini__weicheng, data.to.id)
  end,
  on_use = function (self, event, target, player, data)
    data.extra_data.mini__weicheng_trigger = true
    local dat = data.extra_data.mini__weicheng
    for i = #dat, 1, -1 do
      if dat[i] == data.to.id then
        table.remove(dat, i)
      end
    end
    data.extra_data.mini__weicheng = dat
  end,
})

return miniWeicheng
