local miniTongxin = fk.CreateSkill {
  name = "mini_tongxin",
  tags = { Skill.Rhyme },
}

Fk:loadTranslationTable{
  ["mini_tongxin"] = "同心",
  [":mini_tongxin"] = "<a href='rhyme_skill'>韵律技</a>，出牌阶段限一次，平：你可以令一名其他角色交给你一张手牌，然后若其手牌数不大于你，" ..
  "其摸一张牌；仄：你可以交给一名其他角色一张手牌，然后若其手牌数不小于你，你对其造成1点伤害。<br>转韵：出牌阶段，使用本回合未使用过的类型的牌。",

  ["#mini_tongxin-level"] = "同心：令一名角色交给你一张手牌，然后若其手牌数不大于你，其摸一张牌",
  ["#mini_tongxin-oblique"] = "同心：交给一名其他角色一张手牌，然后若其手牌数不小于你，你对其造成1点伤害",
  ["#mini_tongxin-give"] = "同心：你需交给 %src 一张手牌",

  ["$mini_tongxin1"] = "嘘~心悦何须盟誓，二人同心足矣。",
  ["$mini_tongxin2"] = "看！公瑾与我，如钱之两面，此方口自然为心！",
}

local miniUtil = require "packages/mini/mini_util"

-- 主动技能
miniTongxin:addEffect("active", {
  anim_type = "control",
  card_num = function(self, player)
    if player:getSwitchSkillState(miniTongxin.name, false) == fk.SwitchYang then
      return 0
    else
      return 1
    end
  end,
  target_num = 1,
  prompt = function(self, player)
    if player:getSwitchSkillState(miniTongxin.name, false) == fk.SwitchYang then
      return "#mini_tongxin-level"
    else
      return "#mini_tongxin-oblique"
    end
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(miniTongxin.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    if player:getSwitchSkillState(miniTongxin.name, false) == fk.SwitchYang then
      return false
    else
      return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
    end
  end,
  target_filter = function(self, player, to_select, selected)
    if #selected == 0 and to_select ~= player then
      if player:getSwitchSkillState(miniTongxin.name, false) == fk.SwitchYang then
        return not to_select:isKongcheng()
      else
        return true
      end
    end
  end,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = miniTongxin.name
    local player = effect.from
    local target = effect.tos[1]
    if player:getSwitchSkillState(skillName, false) == fk.SwitchYang then
      local card = room:askToCards(
        target,
        {
          min_num = 1,
          max_num = 1,
          skill_name = skillName,
          prompt = "#mini_tongxin-give:" .. player.id,
          cancelable = false,
        }
      )
      room:obtainCard(player, card[1], false, fk.ReasonGive, target, skillName)
      if target:isAlive() and target:getHandcardNum() <= player:getHandcardNum() then
        target:drawCards(1, skillName)
      end
    else
      room:obtainCard(target, effect.cards[1], false, fk.ReasonGive, player, skillName)
      if target:isAlive() and target:getHandcardNum() >= player:getHandcardNum() then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          skillName = skillName,
        }
      end
    end
  end,
})

-- 触发技能
miniTongxin:addEffect(fk.CardUsing, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(miniTongxin.name, true) and player.phase ~= Player.NotActive
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("mini_tongxin-turn")
    if player.phase == Player.Play and not table.contains(mark, data.card:getTypeString()) then
      miniUtil.changeRhyme(room, player, "mini_tongxin")
    end
    table.insertIfNeed(mark, data.card:getTypeString())
    room:setPlayerMark(player, "mini_tongxin-turn", mark)
  end,
})

return miniTongxin
