local zhujiu = fk.CreateSkill {
  name = "mini_zhujiu"
}

Fk:loadTranslationTable{
  ['mini_zhujiu'] = '煮酒',
  ['#mini_zhujiu'] = '煮酒：你可选择一名其他角色，你与其同时选择一张手牌并交换，<br />若这两张牌颜色相同/不同，你回复1点体力/你对其造成1点伤害',
  ['#askForZhujiu'] = '煮酒：选择一张手牌交换',
  [':mini_zhujiu'] = '出牌阶段限一次，你可选择一名其他角色，你与其同时选择一张手牌并交换，若这两张牌颜色相同/不同，你回复1点体力/你对其造成1点伤害。',
  ['$mini_zhujiu1'] = '天下风云几多事，青梅煮酒论英雄。',
  ['$mini_zhujiu2'] = '玄德久历四方，可识天下英雄？'
}

zhujiu:addEffect('active', {
  can_use = function(self, player)
    return player:usedSkillTimes(zhujiu.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  target_num = 1,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected == 1 then return false end
    local target = Fk:currentRoom():getPlayerById(to_select)
    return to_select ~= player.id and not target:isKongcheng()
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local result = room:askToJointCards({player, target}, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = zhujiu.name,
      cancelable = false,
      pattern = ".|.|.|hand",
      prompt = "#askForZhujiu"
    })
    local fromCard, toCard = result[player.id][1], result[target.id][1]
    U.swapCards(room, player, player, target, {fromCard}, {toCard}, zhujiu.name)
    if Fk:getCardById(fromCard):compareColorWith(Fk:getCardById(toCard)) then
      if player:isWounded() and not player.dead then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = zhujiu.name
        }
      end
    elseif not player.dead and not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = zhujiu.name,
      }
    end
  end,
})

return zhujiu
