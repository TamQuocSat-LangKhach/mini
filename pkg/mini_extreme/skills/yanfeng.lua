local yanfeng = fk.CreateSkill {
  name = "mini__yanfeng"
}

Fk:loadTranslationTable{
  ['mini__yanfeng'] = '炎锋',
  ['#mini__yanfeng'] = '炎锋：你可以将一张牌当无距离限制的火【杀】使用',
  ['mini__yanfeng1'] = '对%src造成1点伤害，你随机弃置一张牌',
  ['mini__yanfeng2'] = '%src摸一张牌，其本回合对你使用的下一张【杀】无效',
  [':mini__yanfeng'] = '<a href=>奋武技</a>，出牌阶段，你可以将一张牌当无距离限制的火【杀】使用。若此【杀】未造成伤害且仅指定唯一目标，你令目标选择一项：1.对你造成1点伤害，然后其随机弃置一张牌；2.令你摸一张牌，本回合你对其使用的下一张【杀】无效。',
}

yanfeng:addEffect('viewas', {
  anim_type = "offensive",
  prompt = "#mini__yanfeng",
  times = function(self, player)
    return 1 + player:getMark("mini__yanfeng_strive_times-round") - player:usedSkillTimes(yanfeng.name, Player.HistoryRound)
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("fire__slash")
    card.skillName = yanfeng.name
    card:addSubcard(cards[1])
    return card
  end,
  after_use = function (self, player, use)
    local room = player.room
    if player.dead or use.damageDealt or #TargetGroup:getRealTargets(use.tos) ~= 1 then return end
    local to = room:getPlayerById(TargetGroup:getRealTargets(use.tos)[1])
    if to.dead then return end
    local choice = room:askToChoice(to, {
      choices = {"mini__yanfeng1:"..player.id, "mini__yanfeng2:"..player.id},
      skill_name = yanfeng.name,
    })
    if string.sub(choice, 14, 14) == "1" then
      room:damage{
        from = to,
        to = player,
        damage = 1,
        skillName = yanfeng.name,
      }
      if not to.dead then
        local cards = table.filter(to:getCardIds("he"), function (id)
          return not to:prohibitDiscard(id)
        end)
        if #cards > 0 then
          room:throwCard(table.random(cards), yanfeng.name, to, to)
        end
      end
    else
      room:addTableMarkIfNeed(player, "mini__yanfeng-turn", to.id)
      player:drawCards(1, yanfeng.name)
    end
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(yanfeng.name, Player.HistoryRound) < (1 + player:getMark("mini__yanfeng_strive_times-round"))
  end,
})

yanfeng:addEffect('targetmod', {
  bypass_distances = function (self, player, skill, card, to)
    return card and table.contains(card.skillNames, "mini__yanfeng")
  end,
})

yanfeng:addEffect(fk.PreCardEffect, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return data.from == player.id and data.card.trueName == "slash" and
      table.contains(player:getTableMark("mini__yanfeng-turn"), data.to)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:removeTableMark(player, "mini__yanfeng-turn", data.to)
    return true
  end,

  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("#mini__yanfeng_strive_times-round") < 4
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "mini__yanfeng_strive_times-round", 1)
  end,
})

return yanfeng
