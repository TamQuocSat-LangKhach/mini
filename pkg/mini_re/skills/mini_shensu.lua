local miniShensu = fk.CreateSkill {
  name = "mini__shensu"
}

Fk:loadTranslationTable{
  ["mini__shensu"] = "神速",
  [":mini__shensu"] = "①判定阶段开始前，你可跳过此阶段和摸牌阶段来视为使用无视防具的【杀】。②出牌阶段开始前，你可跳过此阶段来视为使用无视防具的【杀】。",

  ["#mini__shensu1-choose"] = "神速：你可以跳过判定阶段和摸牌阶段，视为使用一张无距离限制、无视防具的【杀】",
  ["#mini__shensu2-choose"] = "神速：你可以跳过出牌阶段，视为使用一张无距离限制、无视防具的【杀】",
}

miniShensu:addEffect(fk.EventPhaseChanging, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(miniShensu.name) and
      not player:prohibitUse(Fk:cloneCard("slash")) and
      not data.skipped and
      (
        (data.phase == Player.Judge and player:canSkip(Player.Draw)) or
        data.phase == Player.Play
      )
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local use = room:askToUseVirtualCard(
      player,
      {
        name = "slash",
        prompt = data.phase == Player.Judge and "#mini__shensu1-choose" or "#mini__shensu2-choose",
        skill_name = miniShensu.name,
        extra_data = { bypass_distances = true },
        skip = true,
      }
    )
    if use then
      event:setCostData(self, use)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    data.skipped = true
    if data.phase == Player.Judge then
      player:skip(Player.Draw)
    end
    local slash = Fk:cloneCard("slash")
    slash.skillName = miniShensu.name
    room:useCard(event:getCostData(self))
  end,
})

miniShensu:addEffect(fk.TargetSpecified, {
  can_refresh = function(self, event, target, player, data)
    return table.contains(data.card.skillNames, miniShensu.name) and data.to:isAlive()
  end,
  on_refresh = function(self, event, target, player, data)
    data.to:addQinggangTag(data)
  end,
})

return miniShensu
