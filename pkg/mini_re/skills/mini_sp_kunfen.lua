local miniSpKunfen = fk.CreateSkill {
  name = "mini_sp__kunfen"
}

Fk:loadTranslationTable{
  ["mini_sp__kunfen"] = "困奋",
  [":mini_sp__kunfen"] = "结束阶段开始时，你可失去1点体力，然后摸两张牌。",
}

miniSpKunfen:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(miniSpKunfen.name) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = miniSpKunfen.name
    player.room:loseHp(player, 1, skillName)
    if player:isAlive() then
      player:drawCards(2, skillName)
    end
  end,
})

return miniSpKunfen
