local ganlu = fk.CreateSkill {
  name = "mini__ganlu"
}

Fk:loadTranslationTable{
  ['mini__ganlu'] = '甘露',
  ['#mini__ganlu-active'] = '甘露：你可以弃置一张手牌，然后选择一项：1.移动场上一张装备区内的牌；2.将牌堆或弃牌堆中随机一张装备牌置入你的装备区',
  ['mini__ganlu_move'] = '移动场上一张装备区内的牌',
  ['mini__ganlu_put'] = '将随机一张装备牌置入你的装备区',
  ['#mini__ganlu-move'] = '甘露：移动场上一张装备区内的牌',
  [':mini__ganlu'] = '出牌阶段限一次，你可以弃置一张手牌，然后选择一项：1.移动场上一张装备区内的牌；2.将牌堆或弃牌堆中随机一张装备牌置入你的装备区。',
}

ganlu:addEffect('active', {
  prompt = "#mini__ganlu-active",
  anim_type = "control",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(ganlu.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) == Player.Hand and not player:prohibitDiscard(to_select)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, ganlu.name, player, player)
    if not player.dead then
      local choices = {}
      if #room:canMoveCardInBoard() > 0 then
        table.insert(choices, "mini__ganlu_move")
      end
      local cards = table.connect(room.draw_pile, room.discard_pile)
      for _, id in ipairs(cards) do
        local sub_type = Fk:getCardById(id).sub_type
        if Fk:getCardById(id).type == Card.TypeEquip and player:hasEmptyEquipSlot(sub_type) then
          table.insert(choices, "mini__ganlu_put")
          break
        end
      end
      if #choices == 0 then return end
      local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = ganlu.name
      })
      if choice == "mini__ganlu_move" then
        local targets = room:askToChooseToMoveCardInBoard(player, {
          skill_name = ganlu.name,
          flag = "e"
        })
        if #targets ~= 0 then
          room:askToMoveCardInBoard(player, {
            target_one = targets[1],
            target_two = targets[2],
            skill_name = ganlu.name,
            flag = "e",
          })
        end
      else
        local equipMap = {}
        for _, id in ipairs(cards) do
          local sub_type = Fk:getCardById(id).sub_type
          if Fk:getCardById(id).type == Card.TypeEquip and player:hasEmptyEquipSlot(sub_type) then
            local list = equipMap[tostring(sub_type)] or {}
            table.insert(list, id)
            equipMap[tostring(sub_type)] = list
          end
        end
        local types = {}
        for k, _ in pairs(equipMap) do
          table.insert(types, k)
        end
        if #types == 0 then return end
        types = table.random(types)
        local put = table.random(equipMap[types])
        room:moveCardIntoEquip(player, put, ganlu.name, false, player)
      end
    end
  end,
})

return ganlu
