local mini_jielie = fk.CreateSkill {
  name = "mini_jielie"
}

Fk:loadTranslationTable{
  ['mini_jielie'] = '节烈',
  ['#mini_jielie'] = '节烈：令一名其他角色执行一项',
  ['mini_jielie1'] = '使用一张手牌',
  ['mini_jielie2'] = '其下次获得“相知”效果',
  ['#mini_jielie-use'] = '节烈：你可以使用一张牌，若为红色【杀】，%src 失去1点体力且可再次发动“节烈”',
  ['@@mini_xiangzhi'] = '相知',
  ['mini_xiangzhi'] = '相知',
  [':mini_jielie'] = '出牌阶段限一次，你可以选择一项，令一名其他角色：1.其可以使用一张手牌，若此牌为红色【杀】，则你失去1点体力，然后你可以再次发动〖节烈〗；2.你下次发动〖相知〗时，令其获得相同效果。',
  ['$mini_jielie1'] = '此生逢伯符，足以慰平生。',
  ['$mini_jielie2'] = '所幸遇郎君，流离得良人。',
}

mini_jielie:addEffect('active', {
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#mini_jielie",
  interaction = function()
    return UI.ComboBox {choices = {"mini_jielie1", "mini_jielie2"}}
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(mini_jielie.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if self.interaction.data == "mini_jielie1" then
      local use = room:askToUseCard(target, {
        skill_name = "#mini_jielie-use:" .. player.id,
        pattern = ".^(jink,nullification)|.|.|hand",
        cancelable = true
      })
      if use then
        room:useCard(use)
        if not player.dead and use.card.trueName == "slash" and use.card.color == Card.Red then
          room:loseHp(player, 1, mini_jielie.name)
          if not player.dead then
            player:setSkillUseHistory(mini_jielie.name, 0, Player.HistoryPhase)
          end
        end
      end
    else
      local mark = target:getMark("@@mini_xiangzhi")
      if mark == 0 then mark = {} end
      table.insertIfNeed(mark, player.id)
      room:setPlayerMark(target, "@@mini_xiangzhi", mark)
    end
    if not player.dead and player:hasSkill("mini_xiangzhi", true) then
      changeRhyme(room, player, "mini_xiangzhi")
    end
  end,
})

return mini_jielie
