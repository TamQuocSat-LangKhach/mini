local miniFuyin = fk.CreateSkill {
  name = "mini__fuyin"
}

Fk:loadTranslationTable{
  ["mini__fuyin"] = "覆胤",
  [":mini__fuyin"] = "游戏开始时，你可以令一名其他角色获得“覆胤”标记，有“覆胤”标记的角色跳过摸牌阶段。摸牌阶段，你多摸两张牌，然后交给有“覆胤”标记的角色两张牌。",

  ["#mini__fuyin-choose"] = "覆胤：你可以令一名角色获得“覆胤”标记！",
  ["@@mini__fuyin"] = "覆胤",
  ["#mini__fuyin-give"] = "覆胤：请交给“覆胤”角色两张牌",
}

miniFuyin:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(miniFuyin.name)
  end,
  on_cost = function (self, event, target, player)
    local room = player.room
    local to = room:askToChoosePlayers(
      player,
      {
        targets = room:getOtherPlayers(player),
        min_num = 1,
        max_num = 1,
        prompt = "#mini__fuyin-choose",
        skill_name = miniFuyin.name,
      }
    )
    if #to > 0 then
      event:setCostData(self, { tos = to })
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:setPlayerMark(to, "@@mini__fuyin", 1)
  end,
})

miniFuyin:addEffect(fk.EventPhaseChanging, {
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return
      target == player and
      data.phase == Player.Draw and
      not data.skipped and
      player:getMark("@@mini__fuyin") > 0
  end,
  on_use = function (self, event, target, player, data)
    data.skipped = true
  end,
})

miniFuyin:addEffect(fk.DrawNCards, {
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(miniFuyin.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data.n = data.n + 2
  end,
})

miniFuyin:addEffect(fk.AfterDrawNCards, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player)
    return
      target == player and
      player:hasSkill(miniFuyin.name, true) and
      not player:isNude() and
      table.find(player.room:getOtherPlayers(player), function (p)
        return p:getMark("@@mini__fuyin") > 0
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player)
    ---@type string
    local skillName = miniFuyin.name
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function (p)
      return p:getMark("@@mini__fuyin") > 0
    end)
    local tos, cards = room:askToChooseCardsAndPlayers(
      player,
      {
        targets = targets,
        skill_name = miniFuyin.name,
        min_num = 1,
        max_num = 1,
        min_card_num = 2,
        max_card_num = 2,
        prompt = "#mini__fuyin-give",
        cancelable = false,
      }
    )

    room:obtainCard(tos[1], cards, false, fk.ReasonGive, player, skillName)
  end,
})

return miniFuyin
