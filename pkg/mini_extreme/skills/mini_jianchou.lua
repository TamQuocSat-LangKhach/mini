local miniJianchou = fk.CreateSkill {
  name = "mini__jianchou"
}

Fk:loadTranslationTable{
  ["mini__jianchou"] = "谏仇",
  [":mini__jianchou"] = "每轮限两次，一名角色受到【杀】或【决斗】造成的伤害后，你可以令其于此牌结算结束后，视为对伤害来源使用一张【决斗】。",

  ["#mini__jianchou-invoke"] = "谏仇：是否令 %src 视为对 %dest 使用【决斗】？",
}

miniJianchou:addEffect(fk.Damaged, {
  anim_type = "masochism",
  times = function(self, player)
    return 2 - player:usedSkillTimes(miniJianchou.name, Player.HistoryRound)
  end,
  can_trigger = function(self, event, target, player, data)
    return
      player:hasSkill(miniJianchou.name) and
      data.card and
      table.contains({ "slash", "duel" }, data.card.trueName) and
      target:isAlive() and
      player:usedSkillTimes(miniJianchou.name, Player.HistoryRound) < 2 and
      data.from and
      data.from ~= target and
      data.from:isAlive()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(
      player,
      {
        skill_name = miniJianchou.name,
        prompt = "#mini__jianchou-invoke:" .. target.id .. ":" .. data.from.id
      }
    )
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if use_event then
      local use = use_event.data
      use.extra_data = use.extra_data or {}
      use.extra_data.mini__jianchou = use.extra_data.mini__jianchou or {}
      table.insert(use.extra_data.mini__jianchou, {
        from = target,
        to = data.from,
      })
    end
  end,
})

miniJianchou:addEffect(fk.CardUseFinished, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if data.extra_data and data.extra_data.mini__jianchou then
      if not player:isAlive() then return end
      for _, info in ipairs(data.extra_data.mini__jianchou) do
        if info.from == player and info.to:isAlive() then
          local card = Fk:cloneCard("duel")
          card.skillName = miniJianchou.name
          return player:canUseTo(card, info.to)
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local new_info = {}
    for i = #data.extra_data.mini__jianchou, 1, -1 do
      local info = data.extra_data.mini__jianchou[i]
      if info.from == player then
        table.insert(new_info, 1, info.to)
        table.remove(data.extra_data.mini__jianchou, i)
      end
    end
    for _, to in ipairs(new_info) do
      if not player:isAlive() then return end
      if to:isAlive() then
        room:useVirtualCard("duel", nil, player, to, miniJianchou.name)
      end
    end
  end,
})

return miniJianchou
