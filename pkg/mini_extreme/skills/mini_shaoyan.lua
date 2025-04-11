local miniShaoyan = fk.CreateSkill {
  name = "mini_shaoyan"
}

Fk:loadTranslationTable{
  ["mini_shaoyan"] = "韶颜",
  [":mini_shaoyan"] = "每回合限一次，当其他角色使用牌指定你为目标后，若其手牌数大于你，你摸一张牌。",

  ["$mini_shaoyan1"] = "揽二乔于东南？哼，痴人说梦！",
  ["$mini_shaoyan2"] = "有公瑾在，曹贼安可过江东天险？",
}

miniShaoyan:addEffect(fk.TargetSpecified, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return
      target ~= player and
      data.to == player and
      player:hasSkill(miniShaoyan.name) and
      data.from:getHandcardNum() > player:getHandcardNum() and
      player:usedSkillTimes(miniShaoyan.name, Player.HistoryTurn) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, miniShaoyan.name)
  end,
})

return miniShaoyan
