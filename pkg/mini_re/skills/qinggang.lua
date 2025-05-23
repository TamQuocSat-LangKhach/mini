local qinggang = fk.CreateSkill{
  name = "mini__qinggang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["mini__qinggang"] = "青釭",
  [":mini__qinggang"] = "锁定技，若你的装备区里没有武器牌，你视为装备着【青釭剑】。",
}

qinggang:addEffect(fk.TargetSpecified, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qinggang.name) and
      data.card and data.card.trueName == "slash" and not data.to.dead and
      Fk.skills["#qinggang_sword_skill"]:isEffectable(player)
  end,
  on_use = function (self, event, target, player, data)
    Fk.skills["#qinggang_sword_skill"]:doCost(event, target, player, data)
  end,
})

qinggang:addEffect("atkrange", {
  fixed_func = function (self, from)
    if from:hasSkill(qinggang.name) and #from:getEquipments(Card.SubtypeWeapon) == 0 then
      return 2
    end
  end,
})

return qinggang
