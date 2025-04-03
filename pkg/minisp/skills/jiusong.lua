local jiusong = fk.CreateSkill {
  name = "jiusong"
}

Fk:loadTranslationTable{
  ["jiusong"] = "酒颂",
  [":jiusong"] = "①你可将一张锦囊牌当【酒】使用。②当一名角色使用【酒】时，你获得1枚“醉”。（“醉”至多3枚）",

  ["#jiusong"] = "酒颂：你可将一张锦囊牌当【酒】使用",
  ["@liuling_drunk"] = "醉",

  ["$jiusong1"] = "大人以天地为一朝，以万期为须臾。",
  ["$jiusong2"] = "以天为幕，以地为席！",
}

jiusong:addEffect("viewas", {
  pattern = "analeptic",
  prompt = "#jiusong",
  card_filter = function(self, player, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).type == Card.TypeTrick
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("analeptic")
    c.skillName = jiusong.name
    c:addSubcard(cards[1])
    return c
  end,
})

jiusong:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jiusong.name) and data.card.name == "analeptic" and player:getMark("@liuling_drunk") < 3
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@liuling_drunk")
  end,
})

jiusong:addLoseEffect(function(self, player)
  player.room:setPlayerMark(player, "@liuling_drunk", 0)
end)

return jiusong
