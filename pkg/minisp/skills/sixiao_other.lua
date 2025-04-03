local sixiaoOther = fk.CreateSkill {
  name = "sixiao_other&"
}

Fk:loadTranslationTable{
  ["sixiao_other&"] = "死孝",
  ["#sixiao-active"] = "你可观看对你发动“死孝”的角色的手牌，使用其中一张牌！",
  ["#sixiao-from"] = "你要发动谁的“死孝”?",
  ["sixiao"] = "死孝",
  [":sixiao_other&"] = "每回合限一次，当你需要使用除【无懈可击】以外的牌时，你可以观看拥有“死孝”的角色的手牌，并可以选择其中一张牌使用之，然后令其摸一张牌。",
}

sixiaoOther:addEffect("active", {
  name = "sixiao_other&",
  mute = true,
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  prompt = "#sixiao-active",
  can_use = function(self, player)
    if player:getMark("sixiao_invoked-turn") == 0 then
      return table.find(Fk:currentRoom().alive_players, function (p)
        return p:getMark("sixiao_to") == player.id and not p:isKongcheng()
      end)
    end
  end,
  target_filter = function(self, player, to_select)
    return to_select:getMark("sixiao_to") == player.id and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    room:setPlayerMark(player, "sixiao_invoked-turn", 1)

    to:broadcastSkillInvoke("sixiao")
    room:notifySkillInvoked(to, "sixiao")
    room:doIndicate(player, { to })

    local cards = to:getCardIds("h")
    local use = room:askToUseRealCard(
      player,
      {
        pattern = cards,
        skill_name = "sixiao",
        extra_data = {
          bypass_times = false,
          extraUse = false,
          expand_pile = cards,
        },
      }
    )
    if use and to:isAlive() then
      to:drawCards(1, "sixiao")
    end
  end,
})

return sixiaoOther
