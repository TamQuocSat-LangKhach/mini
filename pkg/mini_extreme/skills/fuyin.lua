local fuyin = fk.CreateSkill {
  name = "mini__fuyin"
}

Fk:loadTranslationTable{
  ['mini__fuyin'] = '覆胤',
  ['#mini__fuyin-choose'] = '覆胤：你可以令一名角色获得“覆胤”标记！',
  ['@@mini__fuyin'] = '覆胤',
  ['#mini__fuyin_trigger'] = '覆胤',
  ['#mini__fuyin-give'] = '覆胤：请交给“覆胤”角色两张牌',
  [':mini__fuyin'] = '游戏开始时，你可以令一名其他角色获得“覆胤”标记，有“覆胤”标记的角色跳过摸牌阶段。摸牌阶段，你多摸两张牌，然后交给有“覆胤”标记的角色两张牌。',
}

fuyin:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(fuyin.name)
  end,
  on_cost = function (self, event, target, player)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = table.map(room:getOtherPlayers(player), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#mini__fuyin-choose",
      skill_name = fuyin.name
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(self).tos[1])
    room:setPlayerMark(to, "@@mini__fuyin", 1)
  end,
})

fuyin:addEffect(fk.EventPhaseChanging, {
  can_refresh = function (self, event, target, player, data)
    return target == player and data.to == Player.Draw and player:getMark("@@mini__fuyin") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player:skip(Player.Draw)
  end,
})

fuyin:addEffect(fk.DrawNCards, {
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill("mini__fuyin")
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data.n = data.n + 2
  end,
})

fuyin:addEffect(fk.AfterDrawNCards, {
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill("mini__fuyin", true) and not player:isNude() and
      table.find(player.room:getOtherPlayers(player), function (p)
        return p:getMark("@@mini__fuyin") > 0
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function (p)
      return p:getMark("@@mini__fuyin") > 0
    end)
    room:askToYiji(player, {
      cards = player:getCardIds("he"),
      targets = targets,
      skill_name = "mini__fuyin",
      min_num = 2,
      max_num = 2,
      prompt = "#mini__fuyin-give"
    })
  end,
})

return fuyin
