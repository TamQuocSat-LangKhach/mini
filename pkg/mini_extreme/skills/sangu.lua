local sangu = fk.CreateSkill {
  name = "mini_sangu"
}

Fk:loadTranslationTable{
  ['mini_sangu'] = '三顾',
  ['@mini_sangu'] = '三顾',
  ['@mini_moulue'] = '谋略值',
  [':mini_sangu'] = '锁定技，每当有三张牌指定你为目标后，你获得3点<a href=>谋略值</a>，然后你观看牌堆顶的三张牌并将这些牌置于牌堆顶或牌堆底。',
  ['$mini_sangu1'] = '大梦先觉，感三顾之诚，布天下三分。',
  ['$mini_sangu2'] = '卧龙初晓，铭鱼水之情，托死生之志。',
}

sangu:addEffect(fk.TargetConfirmed, {
  global = false,
  anim_type = "special",
  frequency = Skill.Compulsory,

  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sangu) and
      player:getMark("@mini_sangu") > 0 and player:getMark("@mini_sangu") % 3 == 0
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@mini_sangu", 0)
    if player:getMark("@mini_moulue") < 5 then
      handleMoulue(room, player, 3)
    end
    room:askToGuanxing(player, {cards = room:getNCards(3), skill_name = sangu.name})
  end,

  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(sangu)
  end,

  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@mini_sangu", 1)
  end
})

return sangu
