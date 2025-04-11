local miniXiangzhi = fk.CreateSkill {
  name = "mini_xiangzhi",
  tags = { Skill.Rhyme },
}

Fk:loadTranslationTable{
  ["mini_xiangzhi"] = "相知",
  [":mini_xiangzhi"] = "<a href='rhyme_skill'>韵律技</a>，出牌阶段限一次，平：你摸一张牌；仄：你回复1点体力。<br>转韵：你发动〖节烈〗后。",

  ["#mini_xiangzhi-level"] = "相知：你可以摸一张牌",
  ["#mini_xiangzhi-oblique"] = "相知：你可以回复1点体力",
  ["@@mini_xiangzhi"] = "相知",

  ["$mini_xiangzhi1"] = "衣带逐水去，绿川盼君留。",
  ["$mini_xiangzhi2"] = "溪边坐流水，与君共清欢。",
}

-- 主动技能部分
miniXiangzhi:addEffect("active", {
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  prompt = function(self, player)
    if player:getSwitchSkillState(miniXiangzhi.name, false) == fk.SwitchYang then
      return "#mini_xiangzhi-level"
    else
      return "#mini_xiangzhi-oblique"
    end
  end,
  can_use = function(self, player)
    return
      player:usedSkillTimes(miniXiangzhi.name, Player.HistoryPhase) == 0 and
      (
        player:getSwitchSkillState(miniXiangzhi.name, false) == fk.SwitchYang or
        player:isWounded()
      )
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = miniXiangzhi.name
    local player = effect.from
    if player:getSwitchSkillState(skillName, false) == fk.SwitchYang then
      player:drawCards(1, skillName)
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if table.contains(p:getTableMark("@@mini_xiangzhi"), player.id) and p:isAlive() then
          room:doIndicate(player, { p })
          p:drawCards(1, skillName)
          room:removeTableMark(p, "@@mini_xiangzhi", player.id)
        end
      end
    else
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = skillName,
      }
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if table.contains(p:getTableMark("@@mini_xiangzhi"), player.id) and p:isAlive() then
          room:doIndicate(player, { p })
          if p:isWounded() then
            room:recover{
              who = p,
              num = 1,
              recoverBy = player,
              skillName = skillName,
            }
          end
          room:removeTableMark(p, "@@mini_xiangzhi", player.id)
        end
      end
    end
  end,
})

miniXiangzhi:addLoseEffect(function(self, player)
  local room = player.room
  for _, p in ipairs(room.alive_players) do
    room:removeTableMark(p, "@@mini_xiangzhi", player.id)
  end
end)

return miniXiangzhi
