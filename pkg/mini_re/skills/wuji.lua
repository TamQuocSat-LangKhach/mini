local wuji = fk.CreateSkill {
  name = "mini__wuji",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable {
  ["mini__wuji"] = "武继",
  [":mini__wuji"] = "觉醒技，结束阶段，若本回合你造成过至少3点伤害，你加1点体力上限并回复1点体力，然后获得技能〖武圣〗。",

  ["$mini__wuji1"] = "青龙刀何在！",
  ["$mini__wuji2"] = "征战在即，父亲佑我！",
}

wuji:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wuji.name) and
      player.phase == Player.Finish and
      player:usedSkillTimes(wuji.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    local n = 0
    player.room.logic:getActualDamageEvents(1, function(e)
      local damage = e.data
      if damage.from == player then
        n = n + damage.damage
      end
    end)
    return n > 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    if player:isWounded() and not player.dead then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = wuji.name
      }
    end
    if player.dead then return end
    room:handleAddLoseSkills(player, "ex__wusheng")
  end,
})

return wuji
