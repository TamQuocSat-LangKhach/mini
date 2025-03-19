local mini_xiaohu = fk.CreateSkill {
  name = "mini_xiaohu"
}

Fk:loadTranslationTable{
  ['mini_xiaohu'] = '虓虎',
  ['#mini_xiaohu-invoke'] = '虓虎：你可以弃置一张手牌，获得一张【杀】',
  [':mini_xiaohu'] = '你使用【杀】可以额外指定一个目标。出牌阶段开始时，你可以弃置一张手牌，获得一张【杀】。',
  ['$mini_xiaohu1'] = '趁势争利，所得远胜遵礼守义。',
  ['$mini_xiaohu2'] = '时合当取之，岂能踌躇不行？',
}

mini_xiaohu:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(mini_xiaohu.name) and player.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player)
    local card = player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = mini_xiaohu.name,
      cancelable = true,
      prompt = "#mini_xiaohu-invoke",
    })
    if #card > 0 then
      event:setCostData(skill, card)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:throwCard(event:getCostData(skill), mini_xiaohu.name, player, player)
    if not player.dead then
      local card = room:getCardsFromPileByRule("slash", 1, "allPiles")
      if #card > 0 then
        room:moveCards({
          ids = card,
          to = player.id,
          toArea = Card.PlayerHand,
          moveReason = fk.ReasonJustMove,
          proposer = player.id,
          skillName = mini_xiaohu.name,
        })
      end
    end
  end,
})

mini_xiaohu:addEffect('targetmod', {
  extra_target_func = function(self, player, skill)
    if player:hasSkill(mini_xiaohu.name) and skill.trueName == "slash_skill" then
      return 1
    end
  end,
})

return mini_xiaohu
