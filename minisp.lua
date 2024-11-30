local extension = Package("minisp")
extension.extensionName = "mini"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["minisp"] = "小程序专属",
}

local liuling = General(extension, "liuling", "qun", 3)
local jiusong = fk.CreateViewAsSkill{
  name = "jiusong",
  pattern = "analeptic",
  prompt = "#jiusong",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).type == Card.TypeTrick
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("analeptic")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}
local jiusong_trig = fk.CreateTriggerSkill{
  name = "#jiusong_trig",
  events = {fk.CardUsing},
  main_skill = jiusong,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.name == "analeptic" and player:getMark("@liuling_drunk") < 3
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@liuling_drunk")
  end,

  refresh_events = {fk.EventLoseSkill},
  can_refresh = function (self, event, target, player, data)
    return target == player and data == jiusong and player:getMark("@liuling_drunk") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@liuling_drunk", 0)
  end,
}
jiusong:addRelatedSkill(jiusong_trig)
local maotao = fk.CreateTriggerSkill{
  name = "maotao",
  events = {fk.AfterCardTargetDeclared},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:getMark("@liuling_drunk") > 0 and target ~= player
    and #U.getActualUseTargets(player.room, data, event) == 1
    and table.every(player.room.alive_players, function(p) return not p.dying end)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#maotao-ask::"..data.from..":".. data.card:toLogString())
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, "@liuling_drunk")
    local targetsID = {}
    for _, p in ipairs(room.alive_players) do
      if not table.contains(TargetGroup:getRealTargets(data.tos), p.id) and U.canTransferTarget(p, data, false) then
        table.insert(targetsID, p.id)
      end
    end
    if #targetsID > 0 then
      local toId = table.random(targetsID)
      room:doIndicate(player.id, {toId})
      local tos = {toId}
      data.tos = table.map(data.tos, function (t) -- 日月戟
        t[1] = toId
        return t
      end)
    else
      local cids = room:getCardsFromPileByRule(".|.|.|.|.|trick")
      if #cids > 0 then
        room:obtainCard(player, cids[1], false, fk.ReasonPrey)
      end
    end
  end,
}

local bishi = fk.CreateProhibitSkill{
  name = "bishi",
  frequency = Skill.Compulsory,
  is_prohibited = function(self, from, to, card)
    if to:hasSkill(self) then
      return card.is_damage_card and card.type == Card.TypeTrick
    end
  end,
}

liuling:addSkill(jiusong)
liuling:addSkill(maotao)
liuling:addSkill(bishi)

Fk:loadTranslationTable{
  ["liuling"] = "刘伶",
  ["jiusong"] = "酒颂",
  [":jiusong"] = "①你可将一张锦囊牌当【酒】使用。②当一名角色使用【酒】时，你获得1枚“醉”。（“醉”至多3枚）",
  ["maotao"] = "酕醄",
  [":maotao"] = "当其他角色使用牌时，若目标数为1且没有处于濒死状态的角色，你可弃1枚“醉”，若此牌有其他合法目标，令此牌改为随机指定一个合法目标（不受距离限制），否则你从牌堆中获得一张锦囊牌。", -- 〖酕醄〗若能改变目标，则必定会改变目标。
  ["bishi"] = "避仕",
  [":bishi"] = "锁定技，你不能成为伤害类锦囊牌的目标。",

  ["@liuling_drunk"] = "醉",
  ["#jiusong_trig"] = "酒颂",
  ["#jiusong"] = "酒颂：你可将一张锦囊牌当【酒】使用",
  ["#maotao-ask"] = "酕醄：你可弃1枚“醉”标记，随机改变%dest使用的%arg的目标",

  ["$jiusong1"] = "大人以天地为一朝，以万期为须臾。",
  ["$jiusong2"] = "以天为幕，以地为席！",
  ["$maotao1"] = "痛饮酕醄，醉生梦死！",
  ["$maotao2"] = "杜康既为酒圣，吾定为醉侯！",
  ["$bishi1"] = "往矣！吾将曳尾于涂中。",
  ["$bishi2"] = "仕途多舛，哪有醉卧山野痛快！",
  ["~liuling"] = "哈……呼……（醉后鼾声渐小的声音）",
}

local wangrong = General(extension, "wangrong", "wei", 3)

local jianlin = fk.CreateTriggerSkill{
  name = "jianlin",
  anim_type = "drawcard",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    local room = player.room
    local cards = {}
    local use_cards = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      local parent_event = e.parent
      for _, move in ipairs(e.data) do
        if move.toArea == Card.Processing then
          if move.from == player.id and (move.moveReason == fk.ReasonUse or move.moveReason == fk.ReasonResonpse) then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                table.insertIfNeed(use_cards, info.cardId)
              end
            end
          end
        elseif move.toArea == Card.DiscardPile then
          if move.from == player.id then
            if move.moveReason == fk.ReasonDiscard then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand then
                  table.insertIfNeed(cards, info.cardId)
                end
              end
            end
          elseif #use_cards > 0 and (move.moveReason == fk.ReasonUse or move.moveReason == fk.ReasonResonpse) then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.Processing and table.contains(use_cards, info.cardId) then
                table.insertIfNeed(cards, info.cardId)
              end
            end
          end
        end
      end
      return false
    end, Player.HistoryTurn)
    cards = table.filter(cards, function (id)
      return room:getCardArea(id) == Card.DiscardPile and Fk:getCardById(id).type == Card.TypeBasic
    end)
    if #cards > 0 then
      self.cost_data = cards
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:askForCardChosen(player, player, { card_data = { { self.name, self.cost_data } } }, self.name, "#jianlin-card")
    room:obtainCard(player, card, true, fk.ReasonJustMove, player.id, self.name)
  end,
}
wangrong:addSkill(jianlin)

local sixiao_other = fk.CreateActiveSkill{
  name = "sixiao_other&",
  mute = true,
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  prompt = "#sixiao-active",
  can_use = function(self, player)
    if player:getMark("sixiao_invoked-turn") == 0 then
      return table.find(Fk:currentRoom().alive_players, function (p)
        return p:getMark("sixiao_to") == player.id and not p:isKongcheng()
      end)
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:setPlayerMark(player, "sixiao_invoked-turn", 1)
    local tos = table.filter(room.alive_players, function (p)
      return p:getMark("sixiao_to") == player.id and not p:isKongcheng()
    end)
    if #tos == 0 then return end
    local to = tos[1]
    if #tos > 1 then
      to = room:getPlayerById(
        room:askForChoosePlayers(player, table.map(tos, Util.IdMapper), 1, 1, "#sixiao-from", self.name, false)[1]
      )
    end
    to:broadcastSkillInvoke("sixiao")
    room:notifySkillInvoked(to, "sixiao")
    room:doIndicate(player.id, {to.id})
    local cards = to:getCardIds("h")
    local use = U.askForUseRealCard(room, player, cards, ".", self.name, nil, {expand_pile = cards, bypass_times = false, extraUse = false})
    if use and not to.dead then
      to:drawCards(1, "sixiao")
    end
  end,
}
Fk:addSkill(sixiao_other)
local sixiao = fk.CreateTriggerSkill{
  name = "sixiao",
  anim_type = "support",
  events = {fk.GameStart, fk.AskForCardUse},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if event == fk.GameStart then return true end
    return not player:isKongcheng() and player:getMark("sixiao_to") == target.id and target:getMark("sixiao_invoked-turn") == 0
    and data.pattern
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.GameStart then return true end
    return player.room:askForSkillInvoke(target, self.name, nil, "#sixiao-resp:"..player.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      local targets = table.map(room:getOtherPlayers(player), Util.IdMapper)
      if #targets > 0 then
        local tos = room:askForChoosePlayers(player, targets, 1, 1, "#sixiao-choose", self.name, false)
        if #tos > 0 then
          local to = room:getPlayerById(tos[1])
          room:setPlayerMark(player, "@sixiao", to.general)
          room:setPlayerMark(player, "sixiao_to", to.id)
          room:handleAddLoseSkills(to, "sixiao_other&", nil, false, true)
        end
      end
    else
      room:setPlayerMark(target, "sixiao_invoked-turn", 1)
      room:doIndicate(target.id, {player.id})
      -- copy jixiang
      local extra_data = data.extraData
      local isAvailableTarget = function(card, p)
        if extra_data then
          if type(extra_data.must_targets) == "table" and #extra_data.must_targets > 0 and
              not table.contains(extra_data.must_targets, p.id) then
            return false
          end
          if type(extra_data.exclusive_targets) == "table" and #extra_data.exclusive_targets > 0 and
              not table.contains(extra_data.exclusive_targets, p.id) then
            return false
          end
        end
        return not target:isProhibited(p, card) and card.skill:modTargetFilter(p.id, {}, target.id, card, true)
      end
      local findCardTarget = function(card)
        local tos = {}
        for _, p in ipairs(room.alive_players) do
          if isAvailableTarget(card, p) then
            table.insert(tos, p.id)
          end
        end
        return tos
      end
      local cids = room:askForCard(target, 1, 1, false, self.name, true, data.pattern, "#sixiao-card:"..player.id, player:getCardIds("h"))
      --local cids = U.askforChooseCardsAndChoice(target, cards, {"OK"}, self.name, "#sixiao-card:"..player.id, {"Cancel"}, 1, 1, allcards)
      if #cids == 0 then return false end
      local card = Fk:getCardById(cids[1])
      data.result = {
        from = target.id,
        card = card,
      }
      if card.skill:getMinTargetNum() == 1 then
        local tos = findCardTarget(card)
        if #tos == 1 then
          data.result.tos = {{tos[1]}}
        elseif #tos > 1 then
          data.result.tos = {room:askForChoosePlayers(target, tos, 1, 1, "#sixiao-target:::"..card:toLogString(), self.name, false, true)}
        else
          return false
        end
      end
      if data.eventData then
        data.result.toCard = data.eventData.toCard
        data.result.responseToEvent = data.eventData.responseToEvent
      end
      player:drawCards(1, self.name) -- FIXEME: drawcard should be delayed
      return true
    end
  end,

  refresh_events = {fk.BuryVictim, fk.EventLoseSkill},
  can_refresh = function (self, event, target, player, data)
    if player:getMark("sixiao_to") ~= 0 and target == player then
      return (event == fk.BuryVictim) or (data == self)
    end
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(player:getMark("sixiao_to"))
    if to and table.every(room:getOtherPlayers(player), function (p)
      return p:getMark("sixiao_to") ~= to.id
    end) then
      room:handleAddLoseSkills(to, "-sixiao_other&", nil, false, true)
    end
    room:setPlayerMark(player, "@sixiao", 0)
    room:setPlayerMark(player, "sixiao_to", 0)
  end,
}
wangrong:addSkill(sixiao)
Fk:loadTranslationTable{
  ["wangrong"] = "王戎",
  ["#wangrong"] = "善发谈端",
  ["jianlin"] = "俭吝",
  [":jianlin"] = "一名角色的回合结束后，若你本回合有基本牌因使用、打出或弃置而进入弃牌堆，你可以选择其中一张获得之。",
  ["#jianlin-card"] = "俭吝：选择一张获得",

  ["sixiao"] = "死孝",
  [":sixiao"] = "游戏开始时，你选择一名其他角色。每名角色的回合限一次，当其需要使用除【无懈可击】以外的牌时，其可以观看你的手牌，并可以选择其中一张牌使用之，然后你摸一张牌。",
  ["@sixiao"] = "死孝",
  ["#sixiao_trigger"] = "死孝",
  ["#sixiao-choose"] = "死孝：选择一名其他角色，其每回合可以使用一张你的手牌！",
  ["#sixiao-active"] = "你可观看对你发动“死孝”的角色的手牌，使用其中一张牌！",
  ["sixiao_other&"] = "死孝",
  [":sixiao_other&"] = "每回合限一次，当你需要使用除【无懈可击】以外的牌时，你可以观看拥有“死孝”的角色的手牌，并可以选择其中一张牌使用之，然后令其摸一张牌。",
  ["#sixiao-resp"] = "死孝：你可观看 %src 的手牌，若有你需要使用的牌，你可使用之！",
  ["#sixiao-card"] = "死孝：你可从 %src 的手牌中选择一张使用",
  ["#sixiao-target"] = "死孝：选择使用 %arg 的目标角色",
  ["#sixiao-from"] = "你要发动谁的“死孝”?",

  ["$jianlin1"] = "吾性至俭，不能自奉，何况遗人？",
  ["$jianlin2"] = "以财自污，则免清高之祸。",
  ["$sixiao1"] = "风木之悲，痛彻肺腑。",
  ["$sixiao2"] = "外容毁悴，内心神伤。",
  ["~wangrong"] = "自阮，嵇云亡，为世所羁，实有所叹。",
}

local xiangxiu = General(extension, "xiangxiu", "wei", 3, 3, General.Female)

local miaoxi = fk.CreateActiveSkill{
  name = "miaoxi",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  prompt = "#miaoxi",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and table.contains(Self.player_cards[Player.Hand], to_select)
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and Self.id ~= to_select and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
    and #selected_cards == 1
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    local toCards = room:askForCard(to, 1, 1, false, self.name, false)
    player:showCards(effect.cards)
    to:showCards(toCards)
    local myCard, toCard = Fk:getCardById(effect.cards[1]), Fk:getCardById(toCards[1])
    if myCard.color == toCard.color then
      room:obtainCard(player, toCard, true, fk.ReasonPrey, player.id, self.name)
    end
    if myCard.type == toCard.type and not to.dead then
      room:loseHp(to, 1, self.name)
    end
    if myCard.number == toCard.number and player:getMark("miaoxi-turn") == 0 then
      room:setPlayerMark(player, "miaoxi-turn", 1)
      player:setSkillUseHistory(self.name, 0, Player.HistoryPhase)
    end
  end,
}
xiangxiu:addSkill(miaoxi)

local sijiu = fk.CreateTriggerSkill{
  name = "sijiu",
  events = {fk.RoundEnd},
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(self) then
      return #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.from and move.from ~= move.to and move.to == player.id and move.toArea == Card.PlayerHand then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                return true
              end
            end
          end
        end
        return false
      end, Player.HistoryRound) > 0
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    if player.dead then return end
    local targets = table.filter(room:getOtherPlayers(player, false), function (p) return not p:isKongcheng() end)
    if #targets == 0 then return false end
    local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#sijiu-choose", self.name, false)
    if #tos > 0 then
      local to = room:getPlayerById(tos[1])
      U.viewCards(player, to.player_cards[Player.Hand], self.name, "$ViewCardsFrom:"..to.id)
    end
  end,
}
xiangxiu:addSkill(sijiu)

Fk:loadTranslationTable{
  ["xiangxiu"] = "向秀",

  ["miaoxi"] = "妙析",
  [":miaoxi"] = "出牌阶段限一次，你可以选择一名其他角色，与其同时展示一张手牌，若这些牌：颜色相同，你获得其的展示牌；类别相同，其失去1点体力；点数相同，〖妙析〗视为未发动且此项本回合失效。",
  ["#miaoxi"] = "妙析：请选择一张手牌并指定一名其他角色，与其共同展示一张手牌",

  ["sijiu"] = "思旧",
  [":sijiu"] = "每轮结束时，若你本轮获得过其他角色的牌，你可以摸一张牌并观看一名其他角色的手牌。",
  ["#sijiu-choose"] = "思旧：观看一名其他角色的手牌",

  ["$miaoxi1"] = "物各自造而无所待焉，此天地之正也。",
  ["$miaoxi2"] = "天性所受，各有本分，不可逃，亦不可加。",
  ["$sijiu1"] = "悼嵇生之永辞兮，顾日影而弹琴。",
  ["$sijiu2"] = "托运遇于领会兮，寄余命于寸阴。",
  ["~xiangxiu"] = "",
}

return extension
