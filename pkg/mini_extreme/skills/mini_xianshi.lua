local miniXianshi = fk.CreateSkill {
  name = "mini_xianshi"
}

Fk:loadTranslationTable{
  ["mini_xianshi"] = "先识",
  [":mini_xianshi"] = "每轮限一次，一名角色的摸牌阶段开始时，你可观看牌堆顶的三张牌并用任意张手牌交换其中等量张牌。",

  ["#mini_xianshi-exchange"] = "先识：观看牌堆顶的三张牌并用任意张手牌交换",

  ["$mini_xianshi1"] = "见识通达，以全乱世之机。",
  ["$mini_xianshi2"] = "储先谋后，万事皆成。",
}

miniXianshi:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return
      player:hasSkill(miniXianshi.name) and
      target.phase == Player.Draw and
      player:usedSkillTimes(miniXianshi.name, Player.HistoryRound) == 0
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = miniXianshi.name
    local room = player.room
    local cids = room:askToArrangeCards(
      player,
      {
        card_map = { room:getNCards(3), player:getCardIds(Player.Hand), "pile_draw", "$Hand" },
        prompt = "#mini_xianshi-exchange",
        free_arrange = true,
        skill_name = skillName,
      }
    )
    room:swapCardsWithPile(player, cids[1], cids[2], skillName, "Top")
  end,
})

return miniXianshi
