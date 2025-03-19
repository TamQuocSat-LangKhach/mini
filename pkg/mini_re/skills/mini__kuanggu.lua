local mini__kuanggu = fk.CreateSkill {
  name = "mini__kuanggu"
}

Fk:loadTranslationTable{
  ['mini__kuanggu'] = '狂骨',
  [':mini__kuanggu'] = '锁定技，当你对距离1以内的一名角色造成1点伤害后，你回复1点体力并摸一张牌。',
  ['$mini__kuanggu1'] = '沙场驰骋，但求一败！',
  ['$mini__kuanggu2'] = '我自横扫天下，蔑视群雄又如何？',
}

mini__kuanggu:addEffect(fk.Damage, {
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(mini__kuanggu) and target == player and (data.extra_data or {}).kuanggucheak
  end,
  on_trigger = function(self, event, target, player, data)
    for i = 1, data.damage do
      if not player:hasSkill(mini__kuanggu) then break end
      skill:doCost(event, target, player, data)
    end
  end,
  on_use = function(self, event, target, player, data)
    if player:isWounded() then
      player.room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skill_name = mini__kuanggu.name
      })
    end
    if not player.dead then
      player:drawCards(1, mini__kuanggu.name)
    end
  end,
})

mini__kuanggu:addEffect(fk.BeforeHpChanged, {
  can_refresh = function(self, event, target, player, data)
    if data.damageEvent and player == data.damageEvent.from and (target == player or player:distanceTo(target) == 1) then
      return true
    end
  end,
  on_refresh = function(self, event, target, player, data)
    data.damageEvent.extra_data = data.damageEvent.extra_data or {}
    data.damageEvent.extra_data.kuanggucheak = true
  end,
})

return mini__kuanggu
