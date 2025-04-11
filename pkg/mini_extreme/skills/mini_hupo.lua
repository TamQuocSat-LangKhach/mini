local miniHupo = fk.CreateSkill {
  name = "mini__hupo",
  tags = { Skill.Force },
}

Fk:loadTranslationTable{
  ["mini__hupo"] = "虎魄",
  [":mini__hupo"] = "<a href='MiniForceSkill'>奋武技</a>，出牌阶段，你可以展示你与一名其他角色的手牌，然后你选择一项：1.弃置你与其一个牌名的所有牌；2.获得其一张你没有的牌名的牌。",

  ["#mini__hupo"] = "虎魄：展示你与一名角色所有手牌，然后弃置其中一种牌或获得其一张牌",
  ["mini__hupo_discard"] = "弃置双方一个牌名的所有牌",
  ["mini__hupo_prey"] = "获得其一张你没有的牌名的牌",
  ["#mini__hupo-discard"] = "虎魄：选择要弃置的牌名",
  ["#mini__hupo-prey"] = "虎魄：获得 %dest 的一张牌",
}

local U = require "packages/utility/utility"

miniHupo:addEffect("active", {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#mini__hupo",
  times = function(self, player)
    return 1 + player:getMark("mini__hupo_force_times-round") - player:usedSkillTimes(miniHupo.name, Player.HistoryRound)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(miniHupo.name, Player.HistoryRound) < (1 + player:getMark("mini__hupo_force_times-round"))
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return
      #selected == 0 and
      to_select ~= player and
      not (player:isKongcheng() and to_select:isKongcheng())
  end,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = miniHupo.name
    local player = effect.from
    local target = effect.tos[1]
    if not player:isKongcheng() then
      player:showCards(player:getCardIds("h"))
    end
    if not target:isKongcheng() and target:isAlive() then
      target:showCards(target:getCardIds("h"))
    end
    if not (player:isAlive() and target:isAlive()) then return end
    local choices = {}
    if not (player:isNude() and target:isNude()) then
      table.insert(choices, "mini__hupo_discard")
    end
    local cards = table.filter(target:getCardIds("he"), function(id)
      return not table.find(player:getCardIds("he"), function(id2)
        return Fk:getCardById(id).trueName == Fk:getCardById(id2).trueName
      end)
    end)
    if #cards > 0 then
      table.insert(choices, "mini__hupo_prey")
    end
    if #choices == 0 then return end
    local choice = room:askToChoice(
      player,
      {
        choices = choices,
        skill_name = skillName,
      }
    )
    if choice == "mini__hupo_discard" then
      choices = {}
      for _, id in ipairs(player:getCardIds("he")) do
        if not player:prohibitDiscard(id) then
          table.insertIfNeed(choices, Fk:getCardById(id).trueName)
        end
      end
      for _, id in ipairs(target:getCardIds("he")) do
        table.insertIfNeed(choices, Fk:getCardById(id).trueName)
      end
      choice = room:askToChoice(
        player,
        {
          choices = choices,
          skill_name = skillName,
          prompt = "#mini__hupo-discard",
        }
      )
      local moves = {}
      local ids = table.filter(player:getCardIds("he"), function(id)
        return Fk:getCardById(id).trueName == choice and not player:prohibitDiscard(id)
      end)
      if #ids > 0 then
        table.insert(moves, {
          ids = ids,
          from = player,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonDiscard,
          skillName = skillName,
          proposer = player,
          moveVisible = true,
        })
      end
      ids = table.filter(target:getCardIds("he"), function(id)
        return Fk:getCardById(id).trueName == choice
      end)
      if #ids > 0 then
        table.insert(moves, {
          ids = ids,
          from = target,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonDiscard,
          skillName = skillName,
          proposer = player,
          moveVisible = true,
        })
      end
      room:moveCards(table.unpack(moves))
    else
      cards = U.askforChooseCardsAndChoice(player, cards, { "OK" }, skillName, "#mini__hupo-prey::" .. target.id)
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, skillName, nil, true, player)
    end
  end,
})

local miniHupoRecordSpec = {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("#mini__hupo_force_times-round") < 4
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "mini__hupo_force_times-round", data.damage)
  end,
}

miniHupo:addEffect(fk.Damage, miniHupoRecordSpec)

miniHupo:addEffect(fk.Damaged, miniHupoRecordSpec)

return miniHupo
