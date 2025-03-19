local shensu = fk.CreateSkill {
  name = "mini__shensu"
}

Fk:loadTranslationTable{
  ['mini__shensu'] = '神速',
  ['#mini__shensu1-choose'] = '神速：你可以跳过判定阶段和摸牌阶段，视为使用一张无距离限制、无视防具的【杀】',
  ['#mini__shensu2-choose'] = '神速：你可以跳过出牌阶段，视为使用一张无距离限制、无视防具的【杀】',
  [':mini__shensu'] = '①判定阶段开始前，你可跳过此阶段和摸牌阶段来视为使用无视防具的【杀】。②出牌阶段开始前，你可跳过此阶段来视为使用无视防具的【杀】。',
}

shensu:addEffect(fk.EventPhaseChanging, {
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(shensu.name) and not player:prohibitUse(Fk:cloneCard("slash")) then
      if (data.to == Player.Judge and not player.skipped_phases[Player.Draw]) or data.to == Player.Play then
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local slash = Fk:cloneCard("slash")
    local max_num = slash.skill:getMaxTargetNum(player, slash)
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      if not player:isProhibited(p, slash) then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 or max_num == 0 then return end
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = max_num,
      prompt = data.to == Player.Judge and "#mini__shensu1-choose" or "#mini__shensu2-choose",
      skill_name = shensu.name,
      cancelable = true
    })
    if #tos > 0 then
      event:setCostData(self, tos)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.to == Player.Judge then
      player:skip(Player.Judge)
      player:skip(Player.Draw)
    else
      player:skip(Player.Play)
    end
    local slash = Fk:cloneCard("slash")
    slash.skillName = shensu.name
    room:useCard({
      from = target.id,
      tos = table.map(event:getCostData(self), function(pid) return { pid } end),
      card = slash,
      extraUse = true,
    })
  end,
})

shensu:addEffect(fk.TargetSpecified, {
  can_refresh = function(self, event, target, player, data)
    local room = player.room
    if table.contains(data.card.skillNames, shensu.name) and room:getPlayerById(data.to):isAlive() then
      return true
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(room:getPlayerById(data.to), fk.MarkArmorNullified)

    data.extra_data = data.extra_data or {}
    data.extra_data.miniShensuNullified = data.extra_data.miniShensuNullified or {}
    data.extra_data.miniShensuNullified[tostring(data.to)] = (data.extra_data.miniShensuNullified[tostring(data.to)] or 0) + 1
  end,
})

shensu:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    local room = player.room
    return (data.extra_data or {}).miniShensuNullified
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for key, num in pairs(data.extra_data.miniShensuNullified) do
      local p = room:getPlayerById(tonumber(key))
      if p:getMark(fk.MarkArmorNullified) > 0 then
        room:removePlayerMark(p, fk.MarkArmorNullified, num)
      end
    end

    data.miniShensuNullified = nil
  end,
})

return shensu
