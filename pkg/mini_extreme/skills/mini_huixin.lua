local miniHuixin = fk.CreateSkill {
  name = "mini_huixin"
}

Fk:loadTranslationTable{
  ["mini_huixin"] = "慧心",
  [":mini_huixin"] = "回合开始时，若你装备区里的牌的数量为：偶数，此回合你拥有〖集智〗；奇数，此回合你拥有〖祭风〗。",

  ["$mini_huixin1"] = "星霜岂堪渡，蕙心自娟娟。",
  ["$mini_huixin2"] = "清心澄若水，兰蕙寄芳姿。",
}

miniHuixin:addEffect(fk.TurnStart, {
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = miniHuixin.name
    local room = player.room
    local num = #player:getCardIds("e")
    room:handleAddLoseSkills(player, num % 2 == 0 and "jizhi" or "mini_jifeng", skillName)
    local logic = room.logic
    logic:getCurrentEvent():findParent(GameEvent.Turn):addExitFunc(function()
      room:handleAddLoseSkills(player, "-jizhi|-mini_jifeng", skillName)
    end)
  end,
})

return miniHuixin
