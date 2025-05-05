local huxiao = fk.CreateSkill{
  name = "mini__huxiao",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["mini__huxiao"] = "虎啸",
  [":mini__huxiao"] = "锁定技，当你对一名角色造成火焰伤害后，你与其各摸一张牌，然后本回合你对其使用牌无次数限制。",

  ["@@mini__huxiao-turn"] = "虎啸",

  ["$mini__huxiao1"] = "关门打狗，看你们往哪里走！",
  ["$mini__huxiao2"] = "杀尽吴狗，以报父仇！",
}

huxiao:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huxiao.name) and
      data.damageType == fk.FireDamage
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, huxiao.name)
    if data.to.dead then return end
    data.to:drawCards(1, huxiao.name)
    if player.dead or data.to.dead then return end
    player.room:addTableMarkIfNeed(data.to, "@@mini__huxiao-turn", player.id)
  end,
})

huxiao:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and table.contains(to:getTableMark("@@mini__huxiao-turn"), player.id)
  end,
})

return huxiao
