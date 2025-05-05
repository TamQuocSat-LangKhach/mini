local miniBianguan = fk.CreateSkill {
  name = "mini__bianguan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["mini__bianguan"] = "变观",
  [":mini__bianguan"] = "锁定技，当你每轮首次参与<a href='zhuluPindian'>逐鹿</a>后，你获得本次逐鹿拼点牌中的所有伤害牌和基本牌；" ..
  "当你死亡时，令场上所有存活角色进行一次逐鹿，所有败者失去1点体力。",
}

local U = require "packages/utility/utility"

miniBianguan:addEffect(fk.PindianFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if
      data.subType == "zhulu" and
      player:hasSkill(miniBianguan.name) and
      (target == player or data.results[player]) and
      player:usedEffectTimes(self.name, Player.HistoryRound) == 0
    then
      local room = player.room
      if (data.fromCard.is_damage_card or data.fromCard.type == Card.TypeBasic) and
        room:getCardArea(data.fromCard) == Card.Processing then
        return true
      end
      for _, result in pairs(data.results) do
        if (result.toCard.is_damage_card or result.toCard.type == Card.TypeBasic) and
          room:getCardArea(result.toCard) == Card.Processing then
          return true
        end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = {}
    if (data.fromCard.is_damage_card or data.fromCard.type == Card.TypeBasic) and
      room:getCardArea(data.fromCard) == Card.Processing then
      table.insertTable(cards, Card:getIdList(data.fromCard))
    end
    for _, result in pairs(data.results) do
      if (result.toCard.is_damage_card or result.toCard.type == Card.TypeBasic) and
        room:getCardArea(result.toCard) == Card.Processing then
        table.insertTableIfNeed(cards, Card:getIdList(result.toCard))
      end
    end
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, miniBianguan.name, nil, true, player)
  end,
})

miniBianguan:addEffect(fk.Death, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(miniBianguan.name, false, true) and
      #table.filter(player.room.alive_players, function (p)
        return not p:isKongcheng()
      end) > 1
  end,
  on_use = function (self, event, target, player, data)
    ---@type string
    local skillName = miniBianguan.name
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return not p:isKongcheng()
    end)
    room:doIndicate(player, targets)
    local src = targets[1]
    table.remove(targets, 1)
    local pindian = U.startZhuLu(src, targets, skillName)
    for _, p in ipairs(room:getAlivePlayers()) do
      if pindian.winner ~= p and (p == pindian.from or pindian.results[p]) and p:isAlive() then
        room:loseHp(p, 1, skillName)
      end
    end
  end,
})

return miniBianguan
