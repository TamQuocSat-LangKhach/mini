local wuwei = fk.CreateSkill {
  name = "mini_wuwei"
}

Fk:loadTranslationTable{
  ['mini_wuwei'] = '武卫',
  ['#mini_wuwei-ask'] = '是否发动对一名角色发动 武卫？',
  ['@mini_wuwei'] = '被武卫',
  ['#mini_wuwei_delay'] = '武卫',
  [':mini_wuwei'] = '结束阶段，你可以选择一名角色，直到你的下回合开始，当其不以此法成为伤害牌的目标后，若其体力值不大于你，你令此牌对其无效，然后此牌结算结束后，使用者视为对你使用一张【决斗】。',
  ['$mini_wuwei1'] = '得丞相恩遇，褚必拼死以护！',
  ['$mini_wuwei2'] = '丞相避箭，吾来断后！'
}

wuwei:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(wuwei) and target == player and player.phase == Player.Finish
  end,
  on_cost = function (self, event, target, player, data)
    local to = player.room:askToChoosePlayers(player, {
      targets = table.map(player.room.alive_players, Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#mini_wuwei-ask",
      skill_name = wuwei.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self)
    room:setPlayerMark(player, "_mini_wuwei", to)
    target = room:getPlayerById(to)
    room:addTableMarkIfNeed(target, "@mini_wuwei", player.general)
  end
})

wuwei:addEffect({fk.TargetConfirmed, fk.CardUseFinished}, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    if event == fk.TargetConfirmed then
      return target:getMark("@mini_wuwei") ~= 0 and player:getMark("_mini_wuwei") == target.id and
        target.hp <= player.hp and data.card.is_damage_card and not table.contains(data.card.skillNames, wuwei.name)
    else
      return target == player and (data.extra_data or {}).wuweiDelay
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirmed then
      player.room:notifySkillInvoked(player, wuwei.name, "defensive")
      player:broadcastSkillInvoke(wuwei.name)
      room:doIndicate(player.id, {target.id})
      table.insertIfNeed(data.nullifiedTargets, target.id)
      if player.dead or room:getPlayerById(data.from).dead then return end
      data.extra_data = data.extra_data or {}
      data.extra_data.wuweiDelay = true
      data.extra_data.wuweiDelayTable = data.extra_data.wuweiDelayTable or {}
      table.insert(data.extra_data.wuweiDelayTable, player.id)
    else
      local duelTable = data.extra_data.wuweiDelayTable
      room:sortPlayersByAction(duelTable)
      for _, pid in ipairs(duelTable) do
        if player.dead then return end
        local p = room:getPlayerById(pid)
        if not p.dead then
          local card = Fk:cloneCard("duel")
          card.skillName = wuwei.name
          room:useVirtualCard("duel", nil, player, p, wuwei.name, true)
        end
      end
    end
  end,
})

wuwei:addEffect({fk.TurnStart, fk.BuryVictim}, {
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
  end
})

return wuwei
