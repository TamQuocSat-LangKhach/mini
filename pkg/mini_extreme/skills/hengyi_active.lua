local hengyi = fk.CreateSkill {
  name = "mini__hengyi_active"
}

Fk:loadTranslationTable{
  ['mini__hengyi_active'] = '恒毅',
  ['mini__hengyi_give'] = '令一名角色获得失去的牌',
}

hengyi:addEffect('active', {
  expand_pile = function (self, player)
    return player:getTableMark("mini__hengyi-tmp")
  end,
  interaction = function (skill, player)
    local choices = {"draw2"}
    if table.find(player:getTableMark("mini__hengyi-tmp"), function (id)
      return not table.contains({Card.Void, Card.PlayerSpecial}, Fk:currentRoom():getCardArea(id))
    end) then
      table.insert(choices, 1, "mini__hengyi_give")
    end
    return UI.ComboBox {choices = choices }
  end,
  card_filter = function(self, player, to_select, selected)
    if skill.interaction.data == "draw2" then
      return false
    else
      return #selected == 0 and table.contains(player:getTableMark("mini__hengyi-tmp"), to_select) and
        not table.contains({Card.Void, Card.PlayerSpecial}, Fk:currentRoom():getCardArea(to_select))
    end
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if skill.interaction.data == "draw2" then
      return false
    else
      return #selected == 0 and to_select ~= player.id
    end
  end,
  feasible = function (skill, player, selected, selected_cards)
    if skill.interaction.data == "draw2" then
      return #selected == 0 and #selected_cards == 0
    else
      return #selected == 1 and #selected_cards == 1
    end
  end,
})

return hengyi
