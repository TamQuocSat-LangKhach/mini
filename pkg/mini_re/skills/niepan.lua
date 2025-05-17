local niepan = fk.CreateSkill {
  name = "mini__niepan",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["mini__niepan"] = "涅槃",
  [":mini__niepan"] = "限定技，当你处于濒死状态时，你可以弃置区域里的所有牌，然后摸三张牌并将体力回复至3点。"..
  "若如此做，本局游戏你造成的伤害均视为火焰伤害。",

  ["$mini__niepan1"] = "",
  ["$mini__niepan2"] = "",
}

niepan:addEffect(fk.AskForPeaches, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(niepan.name) and player.dying and
      player:usedSkillTimes(niepan.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:throwAllCards("hej")
    if player.dead then return end
    player:drawCards(3, niepan.name)
    if player.dead then return end
    if player.hp < 3 and player:isWounded() then
      room:recover{
        who = player,
        num = 3 - player.hp,
        recoverBy = player,
        skillName = niepan.name,
      }
    end
  end,
})

niepan:addEffect(fk.DamageInflicted, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(niepan.name, Player.HistoryGame) > 0 and
      data.damageType ~= fk.FireDamage
  end,
  on_use = function(self, event, target, player, data)
    data.damageType = fk.FireDamage
  end,
})

return niepan
