local qingjuez = fk.CreateSkill {
  name = "mini__qingjuez"
}

Fk:loadTranslationTable{
  ['mini__qingjuez'] = '清绝',
  [':mini__qingjuez'] = '限定技，当你进入濒死状态时，你可以回复体力至1点并跳过下个摸牌阶段。',
}

qingjuez:addEffect(fk.EnterDying, {
  anim_type = "defensive",
  frequency = Skill.Limited,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player.hp < 1 and
      player:usedSkillTimes(qingjuez.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "mini__qingjuez", 1)
    room:recover{
      who = player,
      num = 1 - player.hp,
      recoverBy = player,
      skillName = qingjuez.name,
    }
  end,

  can_refresh = function (skill, event, target, player, data)
    return target == player and data.to == Player.Draw and player:getMark("mini__qingjuez") > 0
  end,
  on_refresh = function (skill, event, target, player, data)
    player.room:setPlayerMark(player, "mini__qingjuez", 0)
    player:skip(Player.Draw)
  end,
})

return qingjuez
