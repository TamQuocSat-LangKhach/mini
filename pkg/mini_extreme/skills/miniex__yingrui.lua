local miniex__yingrui = fk.CreateSkill {
  name = "miniex__yingrui"
}

Fk:loadTranslationTable{
  ['miniex__yingrui'] = '英锐',
  ['@mini_moulue'] = '谋略值',
  [':miniex__yingrui'] = '摸牌阶段结束时，或当你杀死一名角色后，你获得4点<a href=>谋略值</a>。',
  ['$miniex__yingrui1'] = '有吾筹谋，岂有败战之理？',
  ['$miniex__yingrui2'] = '坚铠精械，正为今日之战！'
}

miniex__yingrui:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player)
    if not player:hasSkill(miniex__yingrui.name) or player:getMark("@mini_moulue") >= 5 then return end
    return player == target and player.phase == Player.Draw
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    handleMoulue(player.room, player, 4)
  end,
})

miniex__yingrui:addEffect(fk.Deathed, {
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(miniex__yingrui.name) or player:getMark("@mini_moulue") >= 5 then return end
    return data.damage and data.damage.from == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    handleMoulue(player.room, player, 4)
  end,
})

return miniex__yingrui
