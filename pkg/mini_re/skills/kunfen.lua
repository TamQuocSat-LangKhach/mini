local kunfen = fk.CreateSkill {
  name = "mini_sp__kunfen"
}

Fk:loadTranslationTable{
  ['mini_sp__kunfen'] = '困奋',
  [':mini_sp__kunfen'] = '结束阶段开始时，你可失去1点体力，然后摸两张牌。',
}

kunfen:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player)
    player.room:loseHp(player, 1, skill.name)
    if not player.dead then 
      player:drawCards(2, skill.name) 
    end
  end,
})

return kunfen
