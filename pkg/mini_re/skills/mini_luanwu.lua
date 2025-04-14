local miniLuanwu = fk.CreateSkill {
  name = "mini__luanwu",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["mini__luanwu"] = "乱武",
  [":mini__luanwu"] = "限定技，出牌阶段，你可以获得一张【杀】，然后令所有角色选择一项：1. 对除你以外距离最小的另一名角色使用【杀】；2. 失去1点体力。",

  ["#mini__luanwu-use"] = "乱武：对除%src以外距离最小的一名角色使用【杀】，否则失去1点体力",
}

miniLuanwu:addEffect("active", {
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(miniLuanwu.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = miniLuanwu.name
    local player = effect.from
    local cids = room:getCardsFromPileByRule("slash")
    if #cids > 0 then
      room:obtainCard(player, cids, false, fk.ReasonPrey, player, skillName)
    end

    local targets = room:getAlivePlayers()
    room:doIndicate(player, targets)
    for _, target in ipairs(targets) do
      if target:isAlive() then
        local other_players = room:getOtherPlayers(target)
        local luanwu_targets = table.map(table.filter(other_players, function(p2)
          return table.every(other_players, function(p1)
            return target:distanceTo(p1) >= target:distanceTo(p2)
          end) and p2 ~= player
        end), Util.IdMapper)

        local use = room:askToUseCard(
          target,
          {
            skill_name = "slash",
            pattern = "slash",
            prompt = "#mini__luanwu-use:" .. player.id,
            extra_data = { exclusive_targets = luanwu_targets }
          }
        )
        if use then
          use.extraUse = true
          room:useCard(use)
        else
          room:loseHp(target, 1, skillName)
        end
      end
    end
  end,
})

return miniLuanwu
