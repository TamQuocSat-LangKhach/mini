local miniExLongdan = fk.CreateSkill {
  name = "mini_ex__longdan"
}

Fk:loadTranslationTable{
  ["mini_ex__longdan"] = "龙胆",
  [":mini_ex__longdan"] = "你可将【杀】当【闪】、【闪】当【杀】使用或打出，以此使用的【杀】不计入次数。",
}

miniExLongdan:addEffect("viewas", {
  pattern = "slash,jink",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected == 1 then return false end
    local _c = Fk:getCardById(to_select)
    local c
    if _c.trueName == "slash" then
      c = Fk:cloneCard("jink")
    elseif _c.name == "jink" then
      c = Fk:cloneCard("slash")
    else
      return false
    end
    return
      (Fk.currentResponsePattern == nil and player:canUse(c)) or
      (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(c))
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then
      return nil
    end
    local _c = Fk:getCardById(cards[1])
    local c
    if _c.trueName == "slash" then
      c = Fk:cloneCard("jink")
    elseif _c.name == "jink" then
      c = Fk:cloneCard("slash")
    end
    c.skillName = miniExLongdan.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function(self, player, use)
    if use.card.trueName == "slash" then use.extraUse = true end
    player:broadcastSkillInvoke("ex__longdan")
  end,
})

return miniExLongdan
