local miniDelu = fk.CreateSkill {
  name = "mini_delu"
}

Fk:loadTranslationTable{
  ["mini_delu"] = "得鹿",
  [":mini_delu"] = "出牌阶段限一次，你可与任意名体力值不大于你的角色进行一次<a href='zhuluPindian'>逐鹿</a>，赢的角色依次获得没赢的角色区域内随机一张牌。" ..
  "此次你拼点的牌点数+X（X为参加拼点的角色数）。",

  ["#mini_delu"] = "得鹿：你可与任意名体力值不大于你的角色共同拼点，<br />赢的角色依次获得没赢的角色区域内随机一张牌",
 
  ["$mini_delu1"] = "今吾得鹿中原，欲请诸雄会猎四方！",
  ["$mini_delu2"] = "天下所图者为何？哼！不过吾彀中之物尔！",
}

local U = require "packages/utility/utility"

miniDelu:addEffect("active", {
  prompt = "#mini_delu",
  anim_type = "control",
  can_use = function(self, player)
    return player:usedSkillTimes(miniDelu.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  min_target_num = 1,
  max_target_num = 99,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return to_select ~= player and to_select.hp <= player.hp and player:canPindian(to_select)
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = miniDelu.name
    local player = effect.from

    local pd = U.startZhuLu(player, effect.tos, skillName)
    local winner = pd.winner
    if winner then
      local targets = table.simpleClone(effect.tos)
      table.insert(targets, player)
      table.removeOne(targets, winner)
      if winner == player then player:broadcastSkillInvoke("guixin") end -- 彩蛋
      if not winner:isAlive() then
        return false
      end

      room:sortByAction(targets)
      for _, p in ipairs(targets) do
        if not p:isAllNude() then
          local id = table.random(p:getCardIds("hej"))
          room:obtainCard(winner, id, false, fk.ReasonPrey, winner, skillName)
          room:delay(100)
        end
      end
    end
  end,
})

miniDelu:addEffect(fk.PindianCardsDisplayed, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return data.from == player and data.reason == miniDelu.name
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.fromCard.number = math.min(data.fromCard.number + #data.tos + 1, 13)
  end,
})

return miniDelu
