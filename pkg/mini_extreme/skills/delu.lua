local delu = fk.CreateSkill {
  name = "mini_delu"
}

Fk:loadTranslationTable{
  ['mini_delu'] = '得鹿',
  ['#mini_delu'] = '得鹿：你可与任意名体力值不大于你的角色共同拼点，<br />赢的角色依次获得没赢的角色区域内随机一张牌',
  ['#mini_delu_delay'] = '得鹿',
  [':mini_delu'] = '出牌阶段限一次，你可与任意名体力值不大于你的角色进行一次<a href=>逐鹿</a>，赢的角色依次获得没赢的角色区域内随机一张牌。此次你拼点的牌点数+X（X为参加拼点的角色数）。',
  ['$mini_delu1'] = '今吾得鹿中原，欲请诸雄会猎四方！',
  ['$mini_delu2'] = '天下所图者为何？哼！不过吾彀中之物尔！',
}

delu:addEffect('active', {
  name = "mini_delu",
  prompt = "#mini_delu",
  anim_type = "control",
  can_use = function(self, player)
    return player:usedSkillTimes(delu.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  min_target_num = 1,
  max_target_num = 99,
  target_filter = function(self, player, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return to_select ~= player.id and target.hp <= player.hp and player:canPindian(target)
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = effect.tos
    local pd = U.jointPindian(player, table.map(targets, Util.Id2PlayerMapper), delu.name)
    local winner = pd.winner
    if winner then
      table.insert(targets, player.id)
      table.removeOne(targets, winner.id)
      if winner == player then player:broadcastSkillInvoke("guixin") end -- 彩蛋
      if winner.dead then return false end
      room:sortPlayersByAction(targets)
      for _, pid in ipairs(targets) do
        local p = room:getPlayerById(pid)
        if not p:isAllNude() then
          local id = table.random(p:getCardIds{ Player.Hand, Player.Equip, Player.Judge})
          room:obtainCard(winner, id, false, fk.ReasonPrey)
          room:delay(100)
        end
      end
    end
  end,
})

delu:addEffect(fk.PindianCardsDisplayed, {
  name = "#mini_delu_delay",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return data.from == player and data.reason == delu.name
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.fromCard.number = math.min(data.fromCard.number + #data.tos + 1, 13)
  end,
})

return delu
