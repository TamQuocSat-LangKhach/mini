local jikai = fk.CreateSkill {
  name = "jikai",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["jikai"] = "激慨",
  [":jikai"] = "锁定技，你的回合外，其他角色不能响应你使用的牌；你的回合内，你不能响应其他角色使用的牌。",

  ["$jikai1"] = "",
  ["$jikai2"] = "",
}

jikai:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(jikai.name) and (data.card.trueName == "slash" or data.card:isCommonTrick()) then
      if player.room.current == player then
        return target ~= player and (data.card:isCommonTrick() or table.contains(data.tos, player))
      else
        return target == player
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(jikai.name)
    data.disresponsiveList = data.disresponsiveList or {}
    if room.current == player then
      room:notifySkillInvoked(player, jikai.name, "negative")
      table.insertIfNeed(data.disresponsiveList, player)
    else
      room:notifySkillInvoked(player, jikai.name, "offensive")
      for _, p in ipairs(room:getOtherPlayers(player, false)) do
        table.insertIfNeed(data.disresponsiveList, p)
      end
    end
  end,
})

return jikai
