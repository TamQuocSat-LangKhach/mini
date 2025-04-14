local miniKuanggu = fk.CreateSkill {
  name = "mini__kuanggu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["mini__kuanggu"] = "狂骨",
  [":mini__kuanggu"] = "锁定技，当你对距离1以内的一名角色造成1点伤害后，你回复1点体力并摸一张牌。",

  ["$mini__kuanggu1"] = "沙场驰骋，但求一败！",
  ["$mini__kuanggu2"] = "我自横扫天下，蔑视群雄又如何？",
}

miniKuanggu:addEffect(fk.Damage, {
  anim_type = "drawcard",
  trigger_times = function (self, event, target, player, data)
    return data.damage
  end,
  can_trigger = function(self, event, target, player, data)
    return target == player and (data.extra_data or {}).miniKuangguCheck and player:hasSkill(miniKuanggu.name)
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = miniKuanggu.name
    if player:isWounded() then
      player.room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skill_name = skillName,
      }
    end
    if player:isAlive() then
      player:drawCards(1, skillName)
    end
  end,
})

miniKuanggu:addEffect(fk.BeforeHpChanged, {
  can_refresh = function(self, event, target, player, data)
    return data.damageEvent and player == data.damageEvent.from and player:distanceTo(target) <= 1
  end,
  on_refresh = function(self, event, target, player, data)
    data.damageEvent.extra_data = data.damageEvent.extra_data or {}
    data.damageEvent.extra_data.miniKuangguCheck = true
  end,
})

return miniKuanggu
