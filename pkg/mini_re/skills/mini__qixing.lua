local mini__qixing = fk.CreateSkill {
  name = "mini__qixing"
}

Fk:loadTranslationTable{
  ['mini__qixing'] = '七星',
  [':mini__qixing'] = '每轮限一次，当你进入濒死状态时，你可以进行判定，若判定结果的点数大于7，你回复1点体力。',
}

mini__qixing:addEffect(fk.EnterDying, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(mini__qixing.name) and player:usedSkillTimes(mini__qixing.name, Player.HistoryRound) == 0
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local judge = {
      who = player,
      reason = mini__qixing.name,
      pattern = ".|8~13",
    }
    room:judge(judge)
    if judge.card.number > 7 and not player.dead then
      room:recover { num = 1, skillName = mini__qixing.name, who = player, recoverBy = player}
    end
  end,
})

return mini__qixing
