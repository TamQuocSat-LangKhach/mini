local xuehen = fk.CreateSkill{
  name = "mini__xuehen",
}

Fk:loadTranslationTable{
  ["mini__xuehen"] = "雪恨",
  [":mini__xuehen"] = "出牌阶段限一次，你可以选择至多X名角色，你令这些角色进入连环状态（X为你已损失的体力值且至少为1），"..
  "然后对其中一名角色造成1点火焰伤害。",

  ["#mini__xuehen"] = "雪恨：选择至多%arg名角色，横置其武将牌，然后对其中一名角色造成1点火焰伤害",
  ["#mini__xuehen-choose"] = "雪恨：对其中一名角色造成1点火焰伤害",

  ["$mini__xuehen1"] = "便用此刀，为父亲报仇！",
  ["$mini__xuehen2"] = "贼子，血偿之日已到！",
}

xuehen:addEffect("active", {
  anim_type = "offensive",
  prompt = function (self, player)
    return "#mini__xuehen:::"..math.max(1, player:getLostHp())
  end,
  card_num = 0,
  min_target_num = 1,
  max_target_num = function (self, player)
    return math.max(1, player:getLostHp())
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(xuehen.name, Player.HistoryTurn) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected < math.max(1, player:getLostHp())
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = table.simpleClone(effect.tos)
    room:sortByAction(targets)
    for _, p in ipairs(targets) do
      if not p.dead and not p.chained then
        p:setChainState(true)
      end
    end
    targets = table.filter(targets, function(p)
      return not p.dead
    end)
    if #targets == 0 or player.dead then return end
    local to = targets[1]
    if #targets > 1 then
      to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = xuehen.name,
        prompt = "#mini__xuehen-choose",
        cancelable = false,
      })[1]
    end
    room:damage{
      from = player,
      to = to,
      damage = 1,
      skillName = xuehen.name,
      damageType = fk.FireDamage,
    }
  end,
})

return xuehen
