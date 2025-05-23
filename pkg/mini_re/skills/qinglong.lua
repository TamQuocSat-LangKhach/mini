local qinglong = fk.CreateSkill{
  name = "mini__qinglong",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["mini__qinglong"] = "青龙",
  [":mini__qinglong"] = "锁定技，若你的装备区里没有武器牌，你视为装备着【青龙偃月刀】。",
}

qinglong:addEffect(fk.CardEffectCancelledOut, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qinglong.name) and
      data.card.trueName == "slash" and not data.to.dead and
      Fk.skills["#blade_skill"]:isEffectable(player)
  end,
  on_use = function (self, event, target, player, data)
    Fk.skills["#blade_skill"]:doCost(event, target, player, data)
  end,
})

qinglong:addEffect("atkrange", {
  fixed_func = function (self, from)
    if from:hasSkill(qinglong.name) and #from:getEquipments(Card.SubtypeWeapon) == 0 then
      return 3
    end
  end,
})

return qinglong
