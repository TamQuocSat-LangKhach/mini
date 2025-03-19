local mini_xiangzhi = fk.CreateSkill {
  name = "mini_xiangzhi"
}

Fk:loadTranslationTable{
  ['mini_xiangzhi'] = '相知',
  ['#mini_xiangzhi-level'] = '相知：你可以摸一张牌',
  ['#mini_xiangzhi-oblique'] = '相知：你可以回复1点体力',
  ['@@mini_xiangzhi'] = '相知',
  [':mini_xiangzhi'] = '<a href=>韵律技</a>，出牌阶段限一次，平：你摸一张牌；仄：你回复1点体力。<br>转韵：你发动〖节烈〗后。',
  ['$mini_xiangzhi1'] = '衣带逐水去，绿川盼君留。',
  ['$mini_xiangzhi2'] = '溪边坐流水，与君共清欢。',
}

-- 主动技能部分
mini_xiangzhi:addEffect('active', {
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  prompt = function(self, player)
    if player:getSwitchSkillState(mini_xiangzhi.name, false) == fk.SwitchYang then
      return "#mini_xiangzhi-level"
    else
      return "#mini_xiangzhi-oblique"
    end
  end,
  can_use = function(self, player)
    if player:usedSkillTimes(mini_xiangzhi.name, Player.HistoryPhase) == 0 then
      if player:getSwitchSkillState(mini_xiangzhi.name, false) == fk.SwitchYang then
        return true
      else
        return player:isWounded()
      end
    end
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    if player:getSwitchSkillState(mini_xiangzhi.name, false) == fk.SwitchYang then
      player:drawCards(1, mini_xiangzhi.name)
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if table.contains(p:getTableMark("@@mini_xiangzhi"), player.id) and p:isAlive() then
          room:doIndicate(player.id, {p.id})
          p:drawCards(1, mini_xiangzhi.name)
          room:removeTableMark(p, "@@mini_xiangzhi", player.id)
        end
      end
    else
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = mini_xiangzhi.name
      })
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if table.contains(p:getTableMark("@@mini_xiangzhi"), player.id) and p:isAlive() then
          room:doIndicate(player.id, {p.id})
          if p:isWounded() then
            room:recover({
              who = p,
              num = 1,
              recoverBy = player,
              skillName = mini_xiangzhi.name
            })
          end
          room:removeTableMark(p, "@@mini_xiangzhi", player.id)
        end
      end
    end
  end,
})

-- 触发技能部分
mini_xiangzhi:addEffect(fk.EventLoseSkill | fk.Death, {
  can_refresh = function(self, event, target, player, data)
    if player == target then
      if event == fk.EventLoseSkill then
        return data.name == mini_xiangzhi.name
      else
        return player:hasSkill(mini_xiangzhi.name, true, true)
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      room:removeTableMark(p, "@@mini_xiangzhi", player.id)
    end
  end,
})

return mini_xiangzhi
