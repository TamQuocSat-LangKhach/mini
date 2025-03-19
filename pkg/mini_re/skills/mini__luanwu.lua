local mini__luanwu = fk.CreateSkill {
  name = "mini__luanwu"
}

Fk:loadTranslationTable{
  ['mini__luanwu'] = '乱武',
  ['#mini__luanwu-use'] = '乱武：对除贾诩以外距离最小的一名角色使用【杀】，否则失去1点体力',
  [':mini__luanwu'] = '限定技，出牌阶段，你可以获得一张【杀】，然后令所有角色选择一项：1. 对除你以外距离最小的另一名角色使用【杀】；2. 失去1点体力。',
}

mini__luanwu:addEffect('active', {
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(mini__luanwu.name, Player.HistoryGame) == 0
  end,
  card_filter = function() return false end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:broadcastSkillInvoke("luanwu")
    local cids = room:getCardsFromPileByRule("slash")
    if #cids > 0 then
      room:obtainCard(player, cids[1], false, fk.ReasonPrey)
    end
    local targets = room:getAlivePlayers()
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    for _, target in ipairs(targets) do
      if not target.dead then
        local other_players = room:getOtherPlayers(target)
        local luanwu_targets = table.map(table.filter(other_players, function(p2)
          return table.every(other_players, function(p1)
            return target:distanceTo(p1) >= target:distanceTo(p2)
          end) and p2 ~= player
        end), Util.IdMapper)
        local use = room:askToUseCard(target, {
          skill_name = "slash",
          pattern = "slash",
          prompt = "#mini__luanwu-use",
          cancelable = true,
          extra_data = { exclusive_targets = luanwu_targets }
        })
        if use then
          use.extraUse = true
          room:useCard(use)
        else
          room:loseHp(target, 1, mini__luanwu.name)
        end
      end
    end
  end,
})

return mini__luanwu
