local miniWuwei = fk.CreateSkill {
  name = "mini_wuwei"
}

Fk:loadTranslationTable{
  ["mini_wuwei"] = "武卫",
  [":mini_wuwei"] = "结束阶段，你可以选择一名角色，直到你的下回合开始，当其不因本技能成为伤害牌的目标后，" ..
  "若其体力值不大于你，你令此牌对其无效，然后此牌结算结束后，使用者视为对你使用一张【决斗】。",

  ["#mini_wuwei-ask"] = "是否发动对一名角色发动 武卫？",
  ["@mini_wuwei"] = "被武卫",

  ["$mini_wuwei1"] = "得丞相恩遇，褚必拼死以护！",
  ["$mini_wuwei2"] = "丞相避箭，吾来断后！"
}

miniWuwei:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player.phase == Player.Finish and player:hasSkill(miniWuwei.name) 
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(
      player,
      {
        targets = room:getAlivePlayers(false),
        min_num = 1,
        max_num = 1,
        prompt = "#mini_wuwei-ask",
        skill_name = miniWuwei.name,
      }
    )
    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self)
    room:setPlayerMark(player, "_mini_wuwei", to.id)
    room:addTableMarkIfNeed(to, "@mini_wuwei", player.general)
  end
})

miniWuwei:addEffect(fk.TargetConfirmed, {
  is_delay_effect = true,
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
      return
        target:getMark("@mini_wuwei") ~= 0 and
        player:getMark("_mini_wuwei") == target.id and
        target.hp <= player.hp and
        data.card.is_damage_card and
        not table.contains(data.card.skillNames, miniWuwei.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:doIndicate(player, { target })
    data.nullified = true
    if not (player:isAlive() and data.from:isAlive()) then
      return false
    end

    data.extra_data = data.extra_data or {}
    data.extra_data.wuweiDelayTable = data.extra_data.wuweiDelayTable or {}
    table.insert(data.extra_data.wuweiDelayTable, player.id)
  end,
})

miniWuwei:addEffect(fk.CardUseFinished, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return
      target == player and
      player:isAlive() and
      type((data.extra_data or {}).wuweiDelayTable) == "table" and
      table.find(
        data.extra_data.wuweiDelayTable,
        function(id) 
          local to = player.room:getPlayerById(id)
          return to:isAlive() and player:canUseTo(Fk:cloneCard("duel"), to, { bypass_distances = true, bypass_times = true })
        end
      )
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    ---@type string
    local skillName = miniWuwei.name
    local room = player.room
    local duelTable = table.map(data.extra_data.wuweiDelayTable, function(id) return room:getPlayerById(id) end)
    room:sortByAction(duelTable)
    for _, p in ipairs(duelTable) do
      if not player:isAlive() then
        return false
      end
      if p:isAlive() and player ~= p then
        local card = Fk:cloneCard("duel")
        card.skillName = skillName
        room:useVirtualCard("duel", nil, player, p, skillName, true)
      end
    end
  end,
})

local miniWuweiClearSpec = {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("_mini_wuwei") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    target = room:getPlayerById(player:getMark("_mini_wuwei"))
    local records = target:getTableMark("@mini_wuwei")
    table.removeOne(records, player.general)
    room:setPlayerMark(target, "@mini_wuwei", #records > 0 and records or 0)
    player.room:setPlayerMark(player, "_mini_wuwei", 0)
  end,
}

miniWuwei:addEffect(fk.TurnStart, miniWuweiClearSpec)

miniWuwei:addEffect(fk.BuryVictim, miniWuweiClearSpec)

return miniWuwei
