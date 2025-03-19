local bianguan = fk.CreateSkill {
  name = "mini__bianguan"
}

Fk:loadTranslationTable{
  ['mini__bianguan'] = '变观',
  ['#mini__bianguan_trigger'] = '变观',
  [':mini__bianguan'] = '锁定技，当你每轮首次参与<a href=>逐鹿</a>后，你获得本次逐鹿所有拼点牌。当你死亡时，令场上所有存活角色进行一次逐鹿，所有败者失去1点体力。',
}

-- 第一个效果
bianguan:addEffect(fk.PindianFinished, {
  global = false,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(bianguan.name) and (target == player or data.results[player.id]) and
      player:usedSkillTimes(bianguan.name, Player.HistoryRound) == 0 then
      local room = player.room
      if room:getCardArea(data.fromCard) == Card.Processing then
        return true
      end
      for _, result in pairs(data.results) do
        if room:getCardArea(result.toCard) == Card.Processing then
          return true
        end
      end
    end
  end,
  on_use = function (skill, event, target, player, data)
    local room = player.room
    local cards = {}
    if room:getCardArea(data.fromCard) == Card.Processing then
      table.insertTable(cards, Card:getIdList(data.fromCard))
    end
    for _, result in pairs(data.results) do
      if room:getCardArea(result.toCard) == Card.Processing then
        table.insertTableIfNeed(cards, Card:getIdList(result.toCard))
      end
    end
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, bianguan.name, nil, true, player.id)
  end,
})

-- 第二个效果
bianguan:addEffect(fk.Death, {
  global = false,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(bianguan.name, false, true) and
      #table.filter(player.room.alive_players, function (p)
        return not p:isKongcheng()
      end) > 1
  end,
  on_use = function (skill, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return not p:isKongcheng()
    end)
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    local src = targets[1]
    table.remove(targets, 1)
    local pindian = U.jointPindian(src, targets, bianguan.name)
    for _, p in ipairs(room:getAlivePlayers()) do
      if pindian.winner ~= p and (p == pindian.from or pindian.results[p.id]) and not p.dead then
        room:loseHp(p, 1, "mini__bianguan")
      end
    end
  end,
})

return bianguan
