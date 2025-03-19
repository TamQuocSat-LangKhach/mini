local hongtu = fk.CreateSkill {
  name = "mini_zunbei"
}

Fk:loadTranslationTable{
  ['mini_zunbei'] = '尊北',
  ['#mini_zunbei'] = '尊北：你可与所有其他角色共同拼点，<br/>若有胜者，则胜者视为使用一张【万箭齐发】，此牌结算结束后，你摸X张牌（X为受到此牌伤害的角色数）；<br/>没有胜者，则此技能视为此阶段未发动过',
  [':mini_zunbei'] = '出牌阶段限一次，你可与所有其他角色进行一次<a href=>逐鹿</a>，然后若此次“逐鹿”：有胜者，则胜者视为使用一张【万箭齐发】，此牌结算结束后，你摸X张牌（X为受到此牌伤害的角色数）；没有胜者，则此技能视为此阶段未发动过。',
  ['$mini_zunbei1'] = '今据四州之地，足以称雄。',
  ['$mini_zunbei2'] = '昔讨董卓，今肃河北，吾当为汉室首功。',
}

hongtu:addEffect('active', {
  anim_type = "offensive",
  prompt = "#mini_zunbei",
  can_use = function(self, player)
    return player:usedSkillTimes(skill.name, Player.HistoryPhase) == 0 and table.find(Fk:currentRoom().alive_players, function(p)
      return player:canPindian(p) and player ~= p
    end)
  end,
  target_filter = Util.FalseFunc,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = table.filter(room.alive_players, function(p)
      return player:canPindian(p) and player ~= p
    end)
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    local pd = U.jointPindian(player, targets, skill.name)
    local winner = pd.winner
    if winner and not winner.dead then
      local card = Fk:cloneCard("archery_attack")
      if not U.canUseCard(room, winner, card) then return end
      local tos = table.map(table.filter(room.alive_players, function(p)
        return winner:canUseTo(card, p, { bypass_times = true, bypass_distances = true })
      end), Util.IdMapper)
      local use = { ---@type CardUseStruct
        from = winner.id,
        tos = table.map(tos, function(id) return {id} end),
        card = card,
        extraUse = true,
      }
      room:useCard(use)
      if use.damageDealt and not player.dead then
        local num = 0
        for _, id in ipairs(tos) do
          if use.damageDealt[id] then
            num = num + use.damageDealt[id]
          end
        end
        player:drawCards(num, skill.name)
      end
    elseif not winner then
      player:setSkillUseHistory(skill.name, 0, Player.HistoryPhase)
    end
  end,
})

return hongtu
