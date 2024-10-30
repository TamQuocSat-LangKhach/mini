local extension = Package("mini_re")
extension.extensionName = "mini"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["mini_re"] = "小程序-修改",
  ["mini_ex"] = "小程序界",
  ["mini_sp"] = "小程序SP",
}

local caocao = General(extension, "mini__caocao", "wei", 4)
local mini__jianxiong = fk.CreateTriggerSkill{
  name = "mini__jianxiong",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and data.card and player.phase ~= Player.NotActive and 
    not table.contains(type(player:getMark("@$mini__jianxiong-turn")) == "table" and player:getMark("@$mini__jianxiong-turn") or {}, data.card.trueName) and 
    table.every(data.card:isVirtual() and data.card.subcards or {data.card.id}, function(id) return player.room:getCardArea(id) == Card.Processing end) and not player.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("guixin")
    local record = type(player:getMark("@$mini__jianxiong-turn")) == "table" and player:getMark("@$mini__jianxiong-turn") or {}
    table.insert(record, data.card.trueName)
    room:setPlayerMark(player, "@$mini__jianxiong-turn", record)
    room:obtainCard(player, data.card, true, fk.ReasonJustMove)
  end
}
caocao:addSkill(mini__jianxiong)
caocao:addSkill("hujia") -- 村
Fk:loadTranslationTable{
  ["mini__caocao"] = "曹操",
  ["mini__jianxiong"] = "奸雄",
  [":mini__jianxiong"] = "当你于你的回合内使用牌造成伤害后，你可以获得造成伤害的牌（每回合每牌名的牌限一次）。",

  ["@$mini__jianxiong-turn"] = "奸雄",
}

local lvmeng = General(extension, "mini__lvmeng", "wu", 4)
local mini__keji = fk.CreateTriggerSkill{
  name = "mini__keji",
  anim_type = "drawcard",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.type == Card.TypeBasic and player.phase == Player.Play
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
    player.room:addPlayerMark(player, MarkEnum.AddMaxCardsInTurn, 1)
  end,
}
lvmeng:addSkill(mini__keji)
Fk:loadTranslationTable{
  ["mini__lvmeng"] = "吕蒙",
  ["mini__keji"] = "克己",
  [":mini__keji"] = "当你使用一张基本牌时，若此时为你的出牌阶段，你摸一张牌，本回合的手牌上限+1。",
}

local sunshangxiang = General(extension, "mini__sunshangxiang", "wu", 3, 3, General.Female)
local mini__jieyin = fk.CreateActiveSkill{
  name = "mini__jieyin",
  anim_type = "support",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected < 1
  end,
  target_filter = function(self, to_select, selected)
    return Fk:currentRoom():getPlayerById(to_select).gender == General.Male and #selected < 1 and to_select ~= Self.id
  end,
  target_num = 1,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, from, from)
    if not from.dead then
      from:drawCards(1, self.name)
    end
    if not to.dead then
      to:drawCards(1, self.name)
    end
  end
}
sunshangxiang:addSkill(mini__jieyin)
sunshangxiang:addSkill("xiaoji")
Fk:loadTranslationTable{
  ["mini__sunshangxiang"] = "孙尚香",
  ["mini__jieyin"] = "结姻",
  [":mini__jieyin"] = "出牌阶段限一次，你可以弃置一张牌并选择一名男性角色，你与其各摸一张牌。",
}

local xiahouyuan = General(extension, "mini__xiahouyuan", "wei", 4)
local shensu = fk.CreateTriggerSkill{
  name = "mini__shensu",
  anim_type = "offensive",
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and not player:prohibitUse(Fk:cloneCard("slash")) then
      if (data.to == Player.Judge and not player.skipped_phases[Player.Draw]) or data.to == Player.Play then
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local slash = Fk:cloneCard("slash")
    local max_num = slash.skill:getMaxTargetNum(player, slash)
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not player:isProhibited(p, slash) then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 or max_num == 0 then return end
    local tos = room:askForChoosePlayers(player, targets, 1, max_num, data.to == Player.Judge and "#mini__shensu1-choose" or "#mini__shensu2-choose", self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.to == Player.Judge then
      player:skip(Player.Judge)
      player:skip(Player.Draw)
    else
      player:skip(Player.Play)
    end
    local slash = Fk:cloneCard("slash")
    slash.skillName = self.name
    room:useCard({
      from = target.id,
      tos = table.map(self.cost_data, function(pid) return { pid } end),
      card = slash,
      extraUse = true,
    })
    return true
  end,

  refresh_events = {fk.TargetSpecified, fk.CardUseFinished},
  can_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUseFinished then
      return (data.extra_data or {}).miniShensuNullified
    else
      return table.contains(data.card.skillNames, self.name) and room:getPlayerById(data.to):isAlive()
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUseFinished then
      for key, num in pairs(data.extra_data.miniShensuNullified) do
        local p = room:getPlayerById(tonumber(key))
        if p:getMark(fk.MarkArmorNullified) > 0 then
          room:removePlayerMark(p, fk.MarkArmorNullified, num)
        end
      end

      data.miniShensuNullified = nil
    else
      room:addPlayerMark(room:getPlayerById(data.to), fk.MarkArmorNullified)

      data.extra_data = data.extra_data or {}
      data.extra_data.miniShensuNullified = data.extra_data.miniShensuNullified or {}
      data.extra_data.miniShensuNullified[tostring(data.to)] = (data.extra_data.miniShensuNullified[tostring(data.to)] or 0) + 1
    end
  end,
}
xiahouyuan:addSkill(shensu)
Fk:loadTranslationTable{
  ["mini__xiahouyuan"] = "夏侯渊",
  ["mini__shensu"] = "神速",
  [":mini__shensu"] = "①判定阶段开始前，你可跳过此阶段和摸牌阶段来视为使用无视防具的普【杀】。②出牌阶段开始前，你可跳过此阶段来视为使用无视防具的普【杀】。",

  ["#mini__shensu1-choose"] = "神速：你可以跳过判定阶段和摸牌阶段，视为使用一张无距离限制、无视防具的【杀】",
  ["#mini__shensu2-choose"] = "神速：你可以跳过出牌阶段，视为使用一张无距离限制、无视防具的【杀】",
}

local weiyan = General(extension, "mini__weiyan", "shu", 4)
local mini__kuanggu = fk.CreateTriggerSkill{
  name = "mini__kuanggu",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and (data.extra_data or {}).kuanggucheak
  end,
  on_trigger = function(self, event, target, player, data)
    for i = 1, data.damage do
      if not player:hasSkill(self) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_use = function(self, event, target, player, data)
    if player:isWounded() then
      player.room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
    if not player.dead then
      player:drawCards(1, self.name)
    end
  end,

  refresh_events = {fk.BeforeHpChanged},
  can_refresh = function(self, event, target, player, data)
    if data.damageEvent and player == data.damageEvent.from and (target == player or player:distanceTo(target) == 1) then
      return true
    end
  end,
  on_refresh = function(self, event, target, player, data)
    data.damageEvent.extra_data = data.damageEvent.extra_data or {}
    data.damageEvent.extra_data.kuanggucheak = true
  end,
}
weiyan:addSkill(mini__kuanggu)
Fk:loadTranslationTable{
  ["mini__weiyan"] = "魏延",
  ["mini__kuanggu"] = "狂骨",
  [":mini__kuanggu"] = "锁定技，当你对距离1以内的一名角色造成1点伤害后，你回复1点体力并摸一张牌。",

  ["$mini__kuanggu1"] = "沙场驰骋，但求一败！",
  ["$mini__kuanggu2"] = "我自横扫天下，蔑视群雄又如何？",
  ["~mini__weiyan"] = "怨气，终难平……",
}

local pangde = General(extension, "mini__pangde", "qun", 4)
local jianchu = fk.CreateTriggerSkill{
  name = "mini__jianchu",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return end
    local to = player.room:getPlayerById(data.to)
    return data.card.trueName == "slash" and not to:isNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    local id = room:askForCardChosen(player, to, "he", self.name)
    room:throwCard({id}, self.name, to, player)
    local card = Fk:getCardById(id)
    if card.type == Card.TypeEquip then
      data.disresponsive = true
    else
      room:obtainCard(player.id, card, true)
    end
  end,
}
pangde:addSkill("mashu")
pangde:addSkill(jianchu)
Fk:loadTranslationTable{
  ["mini__pangde"] = "庞德",
  ["mini__jianchu"] = "鞬出",
  [":mini__jianchu"] = "当你使用【杀】指定目标后，你可弃置其一张牌，若此牌：为装备牌，其不能使用【闪】抵消此【杀】；不为装备牌，你获得此牌。",
}

local menghuo = General(extension, "mini__menghuo", "shu", 4)
local mini__huoshou = fk.CreateTriggerSkill{
  name = "mini__huoshou",
  mute = true,
  events = {fk.PreCardEffect, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and data.card and data.card.trueName == "savage_assault" then
      if event == fk.PreCardEffect then
        return data.to == player.id
      else
        return target ~= player and not player:isKongcheng()
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.PreCardEffect then
      return true
    else
      local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, nil, "#mini__huoshou-ask::" .. target.id, true)
      if #card > 0 then
        self.cost_data = card
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.PreCardEffect then
      room:notifySkillInvoked(player, self.name, "defensive")
      return true
    else
      room:notifySkillInvoked(player, self.name, "offensive")
      room:doIndicate(player.id, {target.id})
      room:throwCard(self.cost_data, self.name, player, player)
      data.damage = data.damage + 1
    end
  end,
}

local mini__zaiqi = fk.CreateTriggerSkill{
  name = "mini__zaiqi",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw and player:usedSkillTimes(self.name, Player.HistoryGame) < 7
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cids = room:getNCards(player:usedSkillTimes(self.name, Player.HistoryGame))
    room:moveCards{
      ids = cids,
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
    }
    room:delay(2000)
    local cards, choices = {}, {}
    for _, id in ipairs(cids) do
      local card = Fk:getCardById(id)
      local cardType = card:getColorString()
      if cards[cardType] == nil then
        table.insert(choices, cardType)
      end
      cards[cardType] = cards[cardType] or {}
      table.insert(cards[cardType], id)
    end
    local choice = room:askForChoice(player, choices, self.name, "#mini__zaiqi-ask", false)
    room:obtainCard(player.id, cards[choice], true, fk.ReasonJustMove)
    room:addPlayerMark(player, "@mini__zaiqi")
    cids = table.filter(cids, function(id) return room:getCardArea(id) == Card.Processing end)
    room:moveCardTo(cids, Card.DiscardPile, nil, fk.ReasonJustMove)
    return true
  end,
}
menghuo:addSkill(mini__huoshou)
menghuo:addSkill(mini__zaiqi)
Fk:loadTranslationTable{
  ["mini__menghuo"] = "孟获",
  ["mini__huoshou"] = "祸首",
  [":mini__huoshou"] = "【南蛮入侵】对你无效。其他角色受到【南蛮入侵】的伤害时，你可以弃置一张手牌，令此伤害+1。",
  ["mini__zaiqi"] = "再起",
  [":mini__zaiqi"] = "每局限七次，摸牌阶段，你可以改为亮出牌堆顶的X+1张牌，然后获得其中一种颜色的所有牌（X为本技能已发动的次数）。",

  ["#mini__huoshou-ask"] = "祸首：你可以弃置一张牌，令 %dest 受到的伤害+1",
  ["@mini__zaiqi"] = "再起",
  ["#mini__zaiqi-ask"] = "再起：选择一种颜色，获得该颜色的所有牌",
}

local jiaxu = General(extension, "mini__jiaxu", "qun", 3)
local mini__wansha = fk.CreateTriggerSkill{
  name = "mini__wansha",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and table.find(player.room.alive_players, function(p) return p.hp > 1 end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p) return p.hp > 1 end), Util.IdMapper)
    if #targets == 0 then return false end
    local target = room:askForChoosePlayers(player, targets, 1, 1, "#mini__wansha-ask", self.name, false)
    self.cost_data = target[1]
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("wansha")
    local target = room:getPlayerById(self.cost_data)
    room:setPlayerMark(player, "@mini__wansha-phase", target.general)
    room:setPlayerMark(player, "_mini__wansha-phase", target.id)
    room:loseHp(target, 1, self.name)
  end,

  refresh_events = {fk.EnterDying},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self) and player.phase ~= Player.NotActive
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:notifySkillInvoked(player, self.name)
    player:broadcastSkillInvoke("wansha")
  end,
}
local mini__wansha_prohibit = fk.CreateProhibitSkill{
  name = "#mini__wansha_prohibit",
  prohibit_use = function(self, player, card)
    if card.name == "peach" and not player.dying then
      local invoke, ret
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p.phase ~= Player.NotActive and p:hasSkill(mini__wansha) then
          invoke = true
        end
        if p.dying then
          ret = true
        end
      end
      return invoke and ret
    end
  end,
}
local mini__wansha_recover = fk.CreateTriggerSkill{
  name = "#mini__wansha_recover",
  events = {fk.EventPhaseEnd},
  frequency = Skill.Compulsory,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player == target and target:getMark("_mini__wansha-phase") ~= 0 and not player.room:getPlayerById(player:getMark("_mini__wansha-phase")).dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local target = room:getPlayerById(player:getMark("_mini__wansha-phase"))
    if not target.dead then
      room:recover({
        who = target,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
  end,
}
mini__wansha:addRelatedSkill(mini__wansha_prohibit)
mini__wansha:addRelatedSkill(mini__wansha_recover)

local mini__luanwu = fk.CreateActiveSkill{
  name = "mini__luanwu",
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
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
        local use = room:askForUseCard(target, "slash", "slash", "#mini__luanwu-use", true, {exclusive_targets = luanwu_targets})
        if use then
          use.extraUse = true
          room:useCard(use)
        else
          room:loseHp(target, 1, self.name)
        end
      end
    end
  end,
}
jiaxu:addSkill(mini__wansha)
jiaxu:addSkill(mini__luanwu)
jiaxu:addSkill("weimu")
Fk:loadTranslationTable{
  ["mini__jiaxu"] = "贾诩",
  ["mini__wansha"] = "完杀",
  [":mini__wansha"] = "锁定技，你的回合内，若有角色处于濒死状态，不处于濒死状态的其他角色，不能使用【桃】。出牌阶段开始时，你令一名体力值大于1的角色失去1点体力，出牌阶段结束时，其回复1点体力。",
  ["mini__luanwu"] = "乱武",
  [":mini__luanwu"] = "限定技，出牌阶段，你可以获得一张【杀】，然后令所有角色选择一项：1. 对除你以外距离最小的另一名角色使用【杀】；2. 失去1点体力。",

  ["#mini__wansha-ask"] = "完杀：令一名体力值大于1的角色失去1点体力，出牌阶段结束时，其回复1点体力",
  ["@mini__wansha-phase"] = "完杀",
  ["#mini__luanwu-use"] = "乱武：对除贾诩以外距离最小的一名角色使用【杀】，否则失去1点体力",
}

local mini__godzhugeliang = General(extension, "mini__godzhugeliang", "god", 3)
local mini__qixing = fk.CreateTriggerSkill{
  name = "mini__qixing",
  anim_type = "defensive",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|8~13",
    }
    room:judge(judge)
    if judge.card.number > 7 and not player.dead then
      room:recover { num = 1, skillName = self.name, who = player, recoverBy = player}
    end
  end,
}
mini__godzhugeliang:addSkill(mini__qixing)
local mini__tianfa = fk.CreateTriggerSkill{
  name = "mini__tianfa",
  anim_type = "offensive",
  events = {fk.TurnEnd, fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.CardUseFinished then
        return player.phase == Player.Play and data.card.type == Card.TypeTrick and player:getMark("mini__tianfa_count-turn") > 1
      else
        return player:getMark("@mini__punish-turn") > 0
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.CardUseFinished then return true end
    local n = player:getMark("@mini__punish-turn")
    local tos = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), Util.IdMapper), 1, n, "#mini__tianfa-choose:::"..n, self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUseFinished then
      room:setPlayerMark(player, "mini__tianfa_count-turn", 0)
      room:addPlayerMark(player, "@mini__punish-turn", 1)
    else
      local tos = self.cost_data
      room:sortPlayersByAction(tos)
      for _, pid in ipairs(tos) do
        local p = room:getPlayerById(pid)
        if not p.dead then
          room:damage { from = player, to = p, damage = 1, skillName = self.name }
        end
      end
    end
  end,

  refresh_events = {fk.CardUseFinished},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and data.card.type == Card.TypeTrick
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "mini__tianfa_count-turn", 1)
  end,
}
mini__godzhugeliang:addSkill(mini__tianfa)
mini__godzhugeliang:addSkill("mini_jifeng")
Fk:loadTranslationTable{
  ["mini__godzhugeliang"] = "神诸葛亮",
  ["mini__qixing"] = "七星",
  [":mini__qixing"] = "每轮限一次，当你进入濒死状态时，你可以进行判定，若判定结果的点数大于7，你回复1点体力。",
  ["mini__tianfa"] = "天罚",
  [":mini__tianfa"] = "你每于出牌阶段使用两张锦囊后，你于本回合内获得1枚“罚”标记。回合结束时，你可以对至多X名其他角色依次造成1点伤害（X为“罚”数）。",
  ["@mini__punish-turn"] = "罚",
  ["#mini__tianfa-choose"] = "天罚：你可以对至多 %arg 名其他角色依次造成1点伤害",
}

local zhaoyun = General(extension, "mini_ex__zhaoyun", "shu", 4)
local longdan = fk.CreateViewAsSkill{
  name = "mini_ex__longdan",
  pattern = "slash,jink",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    local _c = Fk:getCardById(to_select)
    local c
    if _c.trueName == "slash" then
      c = Fk:cloneCard("jink")
    elseif _c.name == "jink" then
      c = Fk:cloneCard("slash")
    else
      return false
    end
    return (Fk.currentResponsePattern == nil and Self:canUse(c)) or (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(c))
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local _c = Fk:getCardById(cards[1])
    local c
    if _c.trueName == "slash" then
      c = Fk:cloneCard("jink")
    elseif _c.name == "jink" then
      c = Fk:cloneCard("slash")
    end
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function(self, player, use)
    if use.card.trueName == "slash" then use.extraUse = true end
    player:broadcastSkillInvoke("ex__longdan")
  end,
}
local yajiao = fk.CreateTriggerSkill{
  name = "mini_ex__yajiao",
  anim_type = "drawcard",
  events = {fk.CardUsing, fk.CardResponding},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.NotActive and U.IsUsingHandcard(player, data)
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("yajiao")
    player:drawCards(1, self.name)
  end
}
zhaoyun:addSkill(longdan)
zhaoyun:addSkill(yajiao)
Fk:loadTranslationTable{
  ["mini_ex__zhaoyun"] = "界赵云",
  ["mini_ex__longdan"] = "龙胆",
  [":mini_ex__longdan"] = "你可将【杀】当【闪】、【闪】当【杀】使用或打出，以此使用的【杀】不计入次数。",
  ["mini_ex__yajiao"] = "涯角",
  [":mini_ex__yajiao"] = "当你于回合外使用或打出手牌时，你可摸一张牌。",
}

local mini__xushu = General(extension, "mini__xushu", "shu", 3)
local wuyan = fk.CreateTriggerSkill{
  name = "mini__wuyan",
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.type == Card.TypeTrick
  end,
  on_use = Util.TrueFunc,
}
mini__xushu:addSkill(wuyan)
mini__xushu:addSkill("jujian") -- 删了“复原武将牌”而已，因为小程序没翻面
Fk:loadTranslationTable{
  ["mini__xushu"] = "徐庶",
  ["mini__wuyan"] = "无言",
  [":mini__wuyan"] = "锁定技，当你受到锦囊牌造成的伤害时，防止此伤害。",

  ["$mini__wuyan1"] = "别跟我说话！我想静静……",
  ["$mini__wuyan2"] = "不忠不孝之人，不敢开口。",
  ["$jujian_mini__xushu1"] = "大汉中兴，皆系此人。",
  ["$jujian_mini__xushu2"] = "大贤不可屈就，将军需当亲往。",
  ["~mini__xushu"] = "曹营无知己，夜夜思故人。",
}

local caochong = General(extension, "mini__caochong", "wei", 3)
local mini__renxin = fk.CreateTriggerSkill{
  name = "mini__renxin",
  anim_type = "support",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.hp <= data.damage and target ~= player and not player:isNude() and player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, nil, "#mini__renxin-ask::" .. target.id, true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    player:broadcastSkillInvoke("renxin")
    room:throwCard(self.cost_data, self.name, player, player)
    if not player.dead then
      room:damage{
        from = data.from,
        to = player,
        damage = data.damage,
        damageType = data.type,
        skillName = self.name,
        card = data.card,
      }
    end
    return true
  end,
}
caochong:addSkill("chengxiang")
caochong:addSkill(mini__renxin)
Fk:loadTranslationTable{
  ["mini__caochong"] = "曹冲",
  ["mini__renxin"] = "仁心",
  [":mini__renxin"] = "每轮限一次，当其他角色受到不小于其体力值的伤害时，你可以弃置一张牌将此伤害转移给你。",

  ["#mini__renxin-ask"] = "仁心：你可以弃置一张牌，将 %dest 受到的伤害转移给你",
}

local caoxiu = General(extension, "mini__caoxiu", "wei", 4)
caoxiu:addSkill("qianju")
local qingxi = fk.CreateTriggerSkill{
  name = "mini__qingxi",
  anim_type = "offensive",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to and data.to ~= player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getAttackRange()
    if n > data.to:getHandcardNum() then
      data.damage = data.damage + 1
    else
      if #room:askForDiscard(data.to, n, n, false, self.name, true, ".", "#qingxi-discard:::"..n) == n then
        if #player:getEquipments(Card.SubtypeWeapon) > 0 then
          room:throwCard(player:getEquipments(Card.SubtypeWeapon), self.name, player, data.to)
        end
      else
        data.damage = data.damage + 1
      end
    end
  end,
}
caoxiu:addSkill(qingxi)
Fk:loadTranslationTable{
  ["mini__caoxiu"] = "曹休",
  ["mini__qingxi"] = "倾袭",
  [":mini__qingxi"] = "当你对其他角色造成伤害时，你可以令其选择一项：1.弃置X张手牌，然后弃置你装备区里的武器牌（X为你的攻击范围）；2.令此伤害+1。",
}

local zhangxingcai = General(extension, "mini__zhangxingcai", "shu", 3, 3, General.Female)
local mini__shenxian = fk.CreateTriggerSkill{
  name = "mini__shenxian",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    for _, move in ipairs(data) do
      local from = move.from and player.room:getPlayerById(move.from) or nil
      if from and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).type == Card.TypeBasic then
            return true
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local targets = {}
    for _, move in ipairs(data) do
      local from = move.from and player.room:getPlayerById(move.from) or nil
      if from and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).type == Card.TypeBasic then
            table.insertIfNeed(targets, from.id)
          end
        end
      end
    end
    for i = 1, #targets do
      if not player:hasSkill(self) then break end
      self:doCost(event, nil, player, data)
    end
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("shenxian")
    player:drawCards(1, self.name)
  end,
}

local mini__qiangwu = fk.CreateActiveSkill{
  name = "mini__qiangwu",
  anim_type = "offensive",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    room:setPlayerMark(player, "@mini__qiangwu-turn", Fk:getCardById(effect.cards[1]).number)
  end,
}
local mini__qiangwu_buff = fk.CreateTargetModSkill{
  name = "#mini__qiangwu_buff",
  residue_func = function(self, player, skill, scope, card)
    return (player:getMark("@mini__qiangwu-turn") ~= 0 and skill.trueName == "slash_skill" and card.number > player:getMark("@mini__qiangwu-turn") and scope == Player.HistoryPhase) and 998 or 0
  end,
  distance_limit_func = function(self, player, skill, card)
    return (player:getMark("@mini__qiangwu-turn") ~= 0 and skill.trueName == "slash_skill" and card.number > player:getMark("@mini__qiangwu-turn")) and 998 or 0
  end,
}
mini__qiangwu:addRelatedSkill(mini__qiangwu_buff)
zhangxingcai:addSkill(mini__shenxian)
zhangxingcai:addSkill(mini__qiangwu)
Fk:loadTranslationTable{
  ["mini__zhangxingcai"] = "张星彩",
  ["mini__shenxian"] = "甚贤",
  [":mini__shenxian"] = "当有角色因弃置而失去基本牌后，你可以摸一张牌。",
  ["mini__qiangwu"] = "枪舞",
  [":mini__qiangwu"] = "出牌阶段限一次，你可以弃置一张手牌，然后本回合你使用点数大于弃置牌的【杀】不计入次数且无距离限制。",

  ["@mini__qiangwu-turn"] = "枪舞",
}

local jiangwei = General(extension, "mini_sp__jiangwei", "wei", 4)
local kunfen = fk.CreateTriggerSkill{
  name = "mini_sp__kunfen",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(player, 1, self.name)
    if not player.dead then player:drawCards(2, self.name) end
  end,
}
local fengliang = fk.CreateTriggerSkill{
  name = "mini_sp__fengliang",
  anim_type = "defensive",
  events = {fk.EnterDying},
  frequency = Skill.Wake,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player.dying
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    if not player.dead then
      room:recover({
        who = player,
        num = 3 - player.hp,
        recoverBy = player,
        skillName = self.name
      })
      room:handleAddLoseSkills(player, "m_ex__tiaoxin", nil)
    end
  end,
}
jiangwei:addSkill(kunfen)
jiangwei:addSkill(fengliang)
jiangwei:addRelatedSkill("m_ex__tiaoxin")
Fk:loadTranslationTable{
  ["mini_sp__jiangwei"] = "姜维",
  ["mini_sp__kunfen"] = "困奋",
  [":mini_sp__kunfen"] = "结束阶段开始时，你可失去1点体力，然后摸两张牌。",
  ["mini_sp__fengliang"] = "逢亮",
  [":mini_sp__fengliang"] = "觉醒技，当你进入濒死状态时，你减1点体力上限并将体力值回复至3点，获得〖挑衅〗。",
}

return extension
