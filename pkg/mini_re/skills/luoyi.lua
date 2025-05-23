local luoyi = fk.CreateSkill {
  name = "mini__luoyi",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable{
  ["mini__luoyi"] = "裸衣",
  [":mini__luoyi"] = "当你使用【杀】或【决斗】造成伤害时，你可以弃置一张牌，令此伤害+1。",

  ["#mini__luoyi-invoke"] = "烈淬刀：你可以弃置一张牌，令你对 %dest 造成的伤害+1",
}

luoyi:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(luoyi.name) and data.card and
      table.contains({"slash", "duel"}, data.card.trueName)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = luoyi.name,
      cancelable = true,
      prompt = "#mini__luoyi-invoke::" .. data.to.id,
      skip = true,
    })
    if #cards > 0 then
      event:setCostData(self, {tos = {data.to}, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:throwCard(event:getCostData(self).cards, luoyi.name, player, player)
    data:changeDamage(1)
  end,
})

return luoyi
