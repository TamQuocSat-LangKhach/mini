local miniZhujiu = fk.CreateSkill {
  name = "mini_zhujiu"
}

Fk:loadTranslationTable{
  ["mini_zhujiu"] = "煮酒",
  [":mini_zhujiu"] = "出牌阶段限一次，你可选择一名其他角色，你与其同时选择一张手牌并交换，若这两张牌颜色相同/不同，你回复1点体力/你对其造成1点伤害。",

  ["#mini_zhujiu"] = "煮酒：你可选择一名其他角色，你与其同时选择一张手牌并交换，<br />若这两张牌颜色相同/不同，你回复1点体力/你对其造成1点伤害",
  ["#askForZhujiu"] = "煮酒：选择一张手牌交换",

  ["$mini_zhujiu1"] = "天下风云几多事，青梅煮酒论英雄。",
  ["$mini_zhujiu2"] = "玄德久历四方，可识天下英雄？"
}

miniZhujiu:addEffect("active", {
  can_use = function(self, player)
    return player:usedSkillTimes(miniZhujiu.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  target_num = 1,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and not to_select:isKongcheng()
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = miniZhujiu.name
    local player = effect.from
    local target = effect.tos[1]
    local result = room:askToJointCards(
      player,
      {
        players = { player, target },
        min_num = 1,
        max_num = 1,
        skill_name = skillName,
        cancelable = false,
        pattern = ".|.|.|hand",
        prompt = "#askForZhujiu",
      }
    )
    local fromCard, toCard = result[player][1], result[target][1]
    room:swapCards(player, {
      {player, {fromCard}},
      {target, {toCard}},
    }, skillName)
    if Fk:getCardById(fromCard):compareColorWith(Fk:getCardById(toCard)) then
      if player:isWounded() and player:isAlive() then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = skillName,
        }
      end
    elseif player:isAlive() and target:isAlive() then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = skillName,
      }
    end
  end,
})

return miniZhujiu
