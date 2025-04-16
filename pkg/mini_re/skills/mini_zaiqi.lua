local miniZaiqi = fk.CreateSkill {
  name = "mini__zaiqi"
}

Fk:loadTranslationTable{
  ["mini__zaiqi"] = "再起",
  [":mini__zaiqi"] = "每局限七次，摸牌阶段，你可以改为亮出牌堆顶的X+1张牌，然后获得其中一种颜色的所有牌（X为本技能已发动的次数）。",

  ["#mini__zaiqi-ask"] = "再起：选择一种颜色，获得该颜色的所有牌",
  ["@mini__zaiqi"] = "再起",
}

miniZaiqi:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(miniZaiqi.name) and
      player.phase == Player.Draw and
      player:usedSkillTimes(miniZaiqi.name, Player.HistoryGame) < 7
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = miniZaiqi.name
    local room = player.room
    data.phase_end = true

    local cids = room:getNCards(player:usedSkillTimes(skillName, Player.HistoryGame))
    room:turnOverCardsFromDrawPile(player, cids, skillName)
    room:delay(2000)

    local cards, choices = {}, {}
    for _, id in ipairs(cids) do
      local card = Fk:getCardById(id)
      local cardType = card:getColorString()
      if not cards[cardType] then
        table.insert(choices, cardType)
      end
      cards[cardType] = cards[cardType] or {}
      table.insert(cards[cardType], id)
    end
    local choice = room:askToChoice(
      player,
      {
        choices = choices,
        skill_name = skillName,
        prompt = "#mini__zaiqi-ask",
      }
    )
    room:obtainCard(player, cards[choice], true, fk.ReasonPrey, player, skillName)
    room:addPlayerMark(player, "@mini__zaiqi")
    room:cleanProcessingArea(cids)
  end,
})

return miniZaiqi
