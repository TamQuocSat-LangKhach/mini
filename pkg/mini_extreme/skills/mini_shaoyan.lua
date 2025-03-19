local mini_shaoyan = fk.CreateSkill {
  name = "mini_shaoyan"
}

Fk:loadTranslationTable{
  ['mini_shaoyan'] = '韶颜',
  [':mini_shaoyan'] = '每回合限一次，当你成为其他角色使用牌的目标后，若其手牌数大于你，你摸一张牌。',
  ['$mini_shaoyan1'] = '揽二乔于东南？哼，痴人说梦！',
  ['$mini_shaoyan2'] = '有公瑾在，曹贼安可过江东天险？',
}

mini_shaoyan:addEffect(fk.TargetConfirmed, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mini_shaoyan.name) and player:getRoom():getPlayerById(data.from):getHandcardNum() > player:getHandcardNum() and
      player:usedSkillTimes(mini_shaoyan.name, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, mini_shaoyan.name)
  end,
})

return mini_shaoyan
