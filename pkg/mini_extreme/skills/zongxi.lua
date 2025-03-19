local zongxi = fk.CreateSkill {
  name = "mini__zongxi",
}

Fk:loadTranslationTable{
  ['mini__zongxi'] = '纵阋',
  ['#mini__zongxi'] = '纵阋：将至多三张牌置于牌堆顶，令等量名角色共同拼点',
  [':mini__zongxi'] = '出牌阶段限一次，你可将至多三张牌以任意顺序置于牌堆顶，然后令X名角色进行<a href=>逐鹿</a>（X为你以此法置于牌堆的牌数+1），赢的角色摸两张牌。“逐鹿”结束后，你获得其他角色的“逐鹿”牌。',
  ['$mini__zongxi1'] = '承位者当以才德为先，无需遵长幼之序。',
  ['$mini__zongxi2'] = '太子当取诸子中之贤者，可稳一国之气运。',
}

zongxi:addEffect('active', {
  anim_type = "control",
  min_card_num = 1,
  min_target_num = 2,
  prompt = "#mini__zongxi",
  card_filter = function(self, player, to_select, selected)
    return #selected < 3 and table.contains(player.player_cards[Player.Hand], to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    local to = Fk:currentRoom():getPlayerById(to_select)
    if #selected_cards > 0 and #selected < (#selected_cards + 1) and not to:isKongcheng() then
      return to_select == player.id or self:canPindian(player, to)
    end
  end,
  feasible = function(self, player, selected, selected_cards)
    return #selected > 1 and #selected == (#selected_cards + 1)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(zongxi.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:sortPlayersByAction(effect.tos)
    local tos = table.map(effect.tos, Util.Id2PlayerMapper)
    local cards = effect.cards
    if #cards > 1 then
      cards = room:askToGuanxing(player, {
        cards = cards,
        top_limit = {0, 0},
        skill_name = zongxi.name,
        skip = true,
      }).top
    end
    if #cards > 0 then
      room:moveCards({
        ids = table.reverse(cards),
        from = player.id,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = zongxi.name,
        proposer = player.id,
      })
    end
    tos = table.filter(tos, function(p) return not p.dead and not p:isKongcheng() end)
    if #tos < 2 then return end
    local first = table.remove(tos, 1)
    local pd = U.jointPindian(first, tos, zongxi.name)
    local winner = pd.winner
    if winner and not winner.dead then
      winner:drawCards(2, zongxi.name)
    end
    if player.dead then return end
    local ids = {}
    if pd.from ~= player then
      local cid = pd.fromCard:getEffectiveId()
      if cid and room:getCardArea(cid) == Card.DiscardPile then
        table.insert(ids, cid)
      end
    end
    for _, pid in ipairs(effect.tos) do
      if pd.results[pid] and pd.results[pid].toCard then
        local cid = pd.results[pid].toCard:getEffectiveId()
        if cid and room:getCardArea(cid) == Card.DiscardPile then
          table.insert(ids, cid)
        end
      end
    end
    room:obtainCard(player, ids, true, fk.ReasonJustMove, player.id, zongxi.name)
  end,
})

return zongxi
