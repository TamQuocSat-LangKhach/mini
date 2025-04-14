local miniSpFengliang = fk.CreateSkill {
  name = "mini_sp__fengliang",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["mini_sp__fengliang"] = "逢亮",
  [":mini_sp__fengliang"] = "觉醒技，当你进入濒死状态时，你减1点体力上限并将体力值回复至3点，获得〖挑衅〗。",
}

miniSpFengliang:addEffect(fk.EnterDying, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(miniSpFengliang.name) and
      player:usedSkillTimes(miniSpFengliang.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player.dying
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    if player:isAlive() then
      room:recover{
        who = player,
        num = 3 - player.hp,
        recoverBy = player,
        skillName = miniSpFengliang.name
      }
      if player:isAlive() then
        room:handleAddLoseSkills(player, "m_ex__tiaoxin")
      end
    end
  end,
})

return miniSpFengliang
