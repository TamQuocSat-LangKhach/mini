local jianchou = fk.CreateSkill {
  name = "mini__jianchou"
}

Fk:loadTranslationTable{
  ['mini__jianchou'] = '谏仇',
  ['#mini__jianchou-invoke'] = '谏仇：是否令 %src 视为对 %dest 使用【决斗】？',
  ['#mini__jianchou_delay'] = '谏仇',
  [':mini__jianchou'] = '每轮限两次，一名角色受到【杀】或【决斗】造成的伤害后，你可以令其于此牌结算结束后，视为对伤害来源使用一张【决斗】。',
}

jianchou:addEffect(fk.Damaged, {
  anim_type = "masochism",
  times = function(self)
    return 2 - Self:usedSkillTimes(jianchou.name, Player.HistoryRound)
  end,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jianchou.name) and data.card and table.contains({"slash", "duel"}, data.card.trueName) and
      not target.dead and player:usedSkillTimes(jianchou.name, Player.HistoryRound) < 2 and
      data.from and data.from ~= target and not data.from.dead
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {skill_name = jianchou.name, prompt = "#mini__jianchou-invoke:" .. target.id .. ":" .. data.from.id}) then
      event:setCostData(self, {tos = {target.id}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if use_event then
      local use = use_event.data[1]
      use.extra_data = use.extra_data or {}
      use.extra_data.mini__jianchou = use.extra_data.mini__jianchou or {}
      table.insert(use.extra_data.mini__jianchou, {
        from = target,
        to = data.from,
      })
    end
  end,
})

jianchou:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if data.extra_data and data.extra_data.mini__jianchou then
      if player.dead then return end
      for _, info in ipairs(data.extra_data.mini__jianchou) do
        if info.from == player and not info.to.dead then
          local card = Fk:cloneCard("duel")
          card.skillName = "mini__jianchou"
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
      if player.dead then return end
      if not to.dead then
        room:useVirtualCard("duel", nil, player, to, "mini__jianchou")
      end
    end
  end,
})

return jianchou
