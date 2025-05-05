local mozhi = fk.CreateSkill {
  name = "mini__mozhi",
}

Fk:loadTranslationTable {
  ["mini__mozhi"] = "默识",
  [":mini__mozhi"] = "结束阶段，你可以视为使用你本回合出牌阶段使用过的第一张基本牌或普通锦囊牌，然后你可以视为使用你本回合"..
  "出牌阶段使用过的第二张基本牌或普通锦囊牌。",

  ["#mini__mozhi-invoke"] = "默识：你可以视为使用【%arg】",

  ["$mini__mozhi1"] = "琴棋书画，妾身各得其法。",
  ["$mini__mozhi2"] = "书卷识人，才学默心。",
}

mozhi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(mozhi.name) and player.phase == Player.Finish then
      local room = player.room
      local names = {}
      local phase_ids = {}
      room.logic:getEventsOfScope(GameEvent.Phase, 1, function(e)
        if e.data.phase == Player.Play then
          table.insert(phase_ids, { e.id, e.end_id })
        end
      end, Player.HistoryTurn)
      if #phase_ids == 0 then return end
      room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local in_play = false
        for _, ids in ipairs(phase_ids) do
          if #ids == 2 and e.id > ids[1] and e.id < ids[2] then
            in_play = true
            break
          end
        end
        if in_play then
          local use = e.data
          if use.from == player and (use.card.type == Card.TypeBasic or use.card:isCommonTrick()) then
            table.insert(names, use.card.name)
          end
        end
        return #names > 1
      end, Player.HistoryTurn)
      if #names > 0 then
        event:setCostData(self, {extra_data = names})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local names = event:getCostData(self).extra_data
    local use = room:askToUseVirtualCard(player, {
      name = names[1],
      skill_name = mozhi.name,
      prompt = "#mini__mozhi-invoke:::"..names[1],
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
      skip = true,
    })
    if use then
      event:setCostData(self, {extra_data = use, choice = names})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:useCard(event:getCostData(self).extra_data)
    if player.dead then return end
    local names = event:getCostData(self).choice
    if #names == 1 then return end
    room:askToUseVirtualCard(player, {
      name = names[2],
      skill_name = mozhi.name,
      prompt = "#mini__mozhi-invoke:::"..names[2],
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
    })
  end,
})

return mozhi
