local qingshiz = fk.CreateSkill {
  name = "mini__qingshiz"
}

Fk:loadTranslationTable{
  ['mini__qingshiz'] = '情逝',
  ['#mini__qingshiz-invoke'] = '情逝：是否弃置你与 %dest 各%arg2张牌？若此%arg造成伤害则你摸牌',
  ['#mini__qingshiz-discard'] = '情逝：弃置 %dest %arg张牌',
  ['#mini__qingshiz_delay'] = '情逝',
  [':mini__qingshiz'] = '你对其他角色使用牌时，或其他角色对你使用牌时，若目标数为1，你可以弃置你与其各X张牌（不足则全弃），然后若此牌造成伤害，你摸X张牌（X为你已损失体力值且至少为1）。',
}

qingshiz:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qingshiz.name) and #TargetGroup:getRealTargets(data.tos) == 1 then
      if target == player then
        return TargetGroup:getRealTargets(data.tos)[1] ~= player.id
      else
        return TargetGroup:getRealTargets(data.tos)[1] == player.id
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local to = target.id
    if target == player then
      to = TargetGroup:getRealTargets(data.tos)[1]
    end
    if player.room:askToSkillInvoke(player, {
      skill_name = qingshiz.name,
      prompt = "#mini__qingshiz-invoke::"..to..":"..data.card:toLogString()..":"..math.max(1, player:getLostHp())
    }) then
      event:setCostData(skill, {tos = {to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = math.max(1, player:getLostHp())
    data.extra_data = data.extra_data or {}
    data.extra_data.mini__qingshiz = data.extra_data.mini__qingshiz or {}
    table.insertIfNeed(data.extra_data.mini__qingshiz, player.id)
    local to = room:getPlayerById(event:getCostData(skill).tos[1])
    room:askToDiscard(player, {
      min_num = n,
      max_num = n,
      include_equip = true,
      skill_name = qingshiz.name,
      cancelable = false,
      prompt = "#mini__qingshiz-discard::"..player.id..":"..n
    })
    if player.dead or to.dead or to:isNude() then return end
    local cards = to:getCardIds("he")
    if #cards > n then
      cards = room:askToChooseCards(player, {
        min_card_num = n,
        max_card_num = n,
        targets = {to},
        pattern = "he",
        skill_name = qingshiz.name,
        prompt = "#mini__qingshiz-discard::"..to.id..":"..n
      })
    end
    room:throwCard(cards, qingshiz.name, to, player)
  end,
})

qingshiz:addEffect(fk.CardUseFinished, {
  can_trigger = function(self, event, target, player, data)
    return data.damageDealt and data.extra_data and data.extra_data.mini__qingshiz and
      table.contains(data.extra_data.mini__qingshiz, player.id) and not player.dead
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(math.max(1, player:getLostHp()), qingshiz.name)
  end,
})

return qingshiz
