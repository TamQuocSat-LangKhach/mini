local liegong = fk.CreateSkill {
  name = "mini__liegong",
}

Fk:loadTranslationTable{
  ["mini__liegong"] = "烈弓",
  [":mini__liegong"] = "你使用【杀】无距离限制。当你使用【杀】指定目标后，若其手牌数不大于你，此【杀】不能被其响应。",
}

liegong:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(liegong.name) and
      data.card.trueName == "slash" and data.to:getHandcardNum() <= player:getHandcardNum()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.use.disresponsiveList = data.use.disresponsiveList or {}
    table.insertIfNeed(data.use.disresponsiveList, data.to)
  end,
})

liegong:addEffect("targetmod", {
  bypass_distances =  function(self, player, skill, card, target)
    return player:hasSkill(liegong.name) and skill.trueName == "slash_skill"
  end,
})

return liegong