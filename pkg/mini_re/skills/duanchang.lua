local duanchang = fk.CreateSkill {
  name = "mini__duanchang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["mini__duanchang"] = "断肠",
  [":mini__duanchang"] = "锁定技，当你死亡时，杀死你的角色本局游戏不能使用【桃】。",

  ["@@mini__duanchang"] = "断肠",

  ["$mini__duanchang1"] = "",
  ["$mini__duanchang2"] = "",
}

duanchang:addEffect(fk.Death, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(duanchang.name, false, true) and
      data.killer and not data.killer.dead
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {data.killer}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(data.killer, "@@mini__duanchang", 1)
  end,
})

duanchang:addEffect("prohibit", {
  prohibit_use = function (self, player, card)
    return card and player:getMark("@@mini__duanchang") > 0 and card.name == "peach"
  end,
})

return duanchang
