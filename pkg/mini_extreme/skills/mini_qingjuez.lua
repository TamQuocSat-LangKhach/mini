local miniQingjuez = fk.CreateSkill {
  name = "mini__qingjuez",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["mini__qingjuez"] = "清绝",
  [":mini__qingjuez"] = "限定技，当你进入濒死状态时，你可以回复体力至1点并跳过下个摸牌阶段。",
}

miniQingjuez:addEffect(fk.EnterDying, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(miniQingjuez.name) and
      player.hp < 1 and
      player:usedSkillTimes(miniQingjuez.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "mini__qingjuez", 1)
    room:recover{
      who = player,
      num = 1 - player.hp,
      recoverBy = player,
      skillName = miniQingjuez.name,
    }
  end,
})

miniQingjuez:addEffect(fk.EventPhaseChanging, {
  can_refresh = function (skill, event, target, player, data)
    return
      target == player and
      not data.skipped and
      data.phase == Player.Draw and
      player:getMark("mini__qingjuez") > 0
  end,
  on_refresh = function (skill, event, target, player, data)
    player.room:setPlayerMark(player, "mini__qingjuez", 0)
    data.skipped = true
  end,
})

return miniQingjuez
