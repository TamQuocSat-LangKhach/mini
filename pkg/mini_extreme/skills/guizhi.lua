local guizhi = fk.CreateSkill {
  name = "mini__guizhi"
}

Fk:loadTranslationTable{
  ['mini__guizhi'] = '圭志',
  ['#mini__guizhi-choose'] = '圭志：与至多四名角色拼点，赢者使用牌无次数限制，若你没赢则摸牌',
  ['@mini__guizhi'] = '圭志',
  ['@mini__guizhi-phase'] = '圭志',
  [':mini__guizhi'] = '准备阶段，你可以与至多四名其他角色进行<a href=>逐鹿</a>，胜者下个出牌阶段使用的前X张牌无次数限制（X为本次逐鹿没赢的角色数）。若你没赢，则你从牌堆中随机获得点数大于你逐鹿牌的张数的牌。',
}

guizhi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(guizhi.name) and player.phase == Player.Start and
      table.find(player.room:getOtherPlayers(player), function (p)
        return player:canPindian(p)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function (p)
      return player:canPindian(p)
    end)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 4,
      prompt = "#mini__guizhi-choose",
      skill_name = guizhi.name
    })
    if #tos > 0 then
      room:sortPlayersByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pindian = U.jointPindian(player, table.map(event:getCostData(self).tos, Util.Id2PlayerMapper), guizhi.name)
    if pindian.winner and not pindian.winner.dead then
      local n = 0
      if pindian.fromCard then
        n = 1
      end
      for _, _ in pairs(pindian.results) do
        n = n + 1
      end
      n = n - 1
      if n > 0 then
        room:setPlayerMark(pindian.winner, "@mini__guizhi", math.max(n, pindian.winner:getMark("@mini__guizhi")))
      end
    end
    if not player.dead and not (pindian.winner and pindian.winner == player) and pindian.fromCard then
      local n, num = pindian.fromCard.number, 0
      for _, result in pairs(pindian.results) do
        if result.toCard and result.toCard.number > n then
          num = num + 1
        end
      end
      local cards = table.random(room.draw_pile, num)
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, guizhi.name, nil, false, player.id)
      end
    end
  end,
  can_refresh = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and player:getMark("@mini__guizhi") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@mini__guizhi-phase", player:getMark("@mini__guizhi"))
    room:setPlayerMark(player, "@mini__guizhi", 0)
  end,
})

guizhi:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@mini__guizhi-phase") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:removePlayerMark(player, "@mini__guizhi-phase", 1)
    data.extraUse = true
  end,
})

guizhi:addEffect('targetmod', {
  bypass_times = function (self, player, skill, scope, card, to)
    return card and player:getMark("@mini__guizhi-phase") > 0
  end,
})

return guizhi
