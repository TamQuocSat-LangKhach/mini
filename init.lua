local extension = Package("mini")
local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["mini"] = "小程序",
  ["miniex"] = "小程序",
  ["mini_sp"] = "小程序",
}

local lvbu = General(extension, "miniex__lvbu", "qun", 4)
local mini_xiaohu = fk.CreateTriggerSkill{
  name = "mini_xiaohu",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, false, self.name, true, ".", "#mini_xiaohu-invoke", true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    if not player.dead then
      local card = room:getCardsFromPileByRule("slash", 1, "allPiles")
      if #card > 0 then
        room:moveCards({
          ids = card,
          to = player.id,
          toArea = Card.PlayerHand,
          moveReason = fk.ReasonJustMove,
          proposer = player.id,
          skillName = self.name,
        })
      end
    end
  end,
}
local mini_xiaohu_targetmod = fk.CreateTargetModSkill{
  name = "#mini_xiaohu_targetmod",
  extra_target_func = function(self, player, skill)
    if player:hasSkill("mini_xiaohu") and skill.trueName == "slash_skill" then
      return 1
    end
  end,
}
mini_xiaohu:addRelatedSkill(mini_xiaohu_targetmod)
lvbu:addSkill("wushuang")
lvbu:addSkill(mini_xiaohu)
Fk:loadTranslationTable{
  ["miniex__lvbu"] = "极吕布",
  ["mini_xiaohu"] = "虓虎",
  [":mini_xiaohu"] = "你使用【杀】可以额外指定一个目标。出牌阶段开始时，你可以弃置一张手牌，获得一张【杀】。",
  ["#mini_xiaohu-invoke"] = "虓虎：你可以弃置一张手牌，获得一张【杀】",
}

local daqiao = General(extension, "miniex__daqiao", "wu", 3, 3, General.Female)
local mini_xiangzhi = fk.CreateActiveSkill{
  name = "mini_xiangzhi",
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  prompt = function(self)
    if Self:getSwitchSkillState("mini_xiangzhi", false) == fk.SwitchYang then
      return "#mini_xiangzhi-ping"
    else
      return "#mini_xiangzhi-ze"
    end
  end,
  can_use = function(self, player)
    if player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 then
      if player:getSwitchSkillState("mini_xiangzhi", false) == fk.SwitchYang then
        return true
      else
        return player:isWounded()
      end
    end
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    if player:getSwitchSkillState("mini_xiangzhi", false) == fk.SwitchYang then
      player:drawCards(1, self.name)
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if p:getMark("@@mini_xiangzhi") ~= 0 then
          local mark = p:getMark("@@mini_xiangzhi")
          if table.contains(mark, player.id) then
            room:doIndicate(player.id, {p.id})
            p:drawCards(1, self.name)
            table.removeOne(mark, player.id)
            if #mark == 0 then mark = 0 end
            room:setPlayerMark(p, "@@mini_xiangzhi", mark)
          end
        end
      end
    else
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if p:getMark("@@mini_xiangzhi") ~= 0 then
          local mark = p:getMark("@@mini_xiangzhi")
          if table.contains(mark, player.id) then
            room:doIndicate(player.id, {p.id})
            if p:isWounded() then
              room:recover({
                who = p,
                num = 1,
                recoverBy = player,
                skillName = self.name
              })
            end
            table.removeOne(mark, player.id)
            if #mark == 0 then mark = 0 end
            room:setPlayerMark(p, "@@mini_xiangzhi", mark)
          end
        end
      end
    end
  end,
}
local mini_xiangzhi_record = fk.CreateTriggerSkill{
  name = "#mini_xiangzhi_record",

  refresh_events = {fk.EventLoseSkill, fk.Death},
  can_refresh = function(self, event, target, player, data)
    if player == target then
      if event == fk.EventLoseSkill then
        return data.name == "mini_xiangzhi"
      else
        return player:hasSkill("mini_xiangzhi", true, true)
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      if p:getMark("@@mini_xiangzhi") ~= 0 then
        local mark = p:getMark("@@mini_xiangzhi")
        if table.contains(mark, player.id) then
          table.removeOne(mark, player.id)
          if #mark == 0 then mark = 0 end
          room:setPlayerMark(p, "@@mini_xiangzhi", mark)
        end
      end
    end
  end,
}
local mini_jielie = fk.CreateActiveSkill{
  name = "mini_jielie",
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#mini_jielie",
  interaction = function()
    return UI.ComboBox {choices = {"mini_jielie1", "mini_jielie2"}}
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if self.interaction.data == "mini_jielie1" then
      local use = room:askForUseCard(target, ".", "^(jink,nullification)|.|.|hand", "#mini_jielie-use:"..player.id, true)
      if use then
        room:useCard(use)
        if not player.dead and use.card.trueName == "slash" and use.card.color == Card.Red then
          room:loseHp(player, 1, self.name)
          if not player.dead then
            player:setSkillUseHistory(self.name, 0, Player.HistoryPhase)
          end
        end
      end
    else
      local mark = target:getMark("@@mini_xiangzhi")
      if mark == 0 then mark = {} end
      table.insertIfNeed(mark, player.id)
      room:setPlayerMark(target, "@@mini_xiangzhi", mark)
    end
    if not player.dead and player:hasSkill("mini_xiangzhi", true) then
      room:setPlayerMark(player, MarkEnum.SwithSkillPreName .. "mini_xiangzhi", player:getSwitchSkillState("mini_xiangzhi", true))
      room:notifySkillInvoked(player, "mini_xiangzhi", "switch")
      player:setSkillUseHistory("mini_xiangzhi", 0, Player.HistoryPhase)
    end
  end,
}
mini_xiangzhi:addRelatedSkill(mini_xiangzhi_record)
daqiao:addSkill(mini_xiangzhi)
daqiao:addSkill(mini_jielie)
Fk:loadTranslationTable{
  ["miniex__daqiao"] = "极大乔",
  ["mini_xiangzhi"] = "相知",
  [":mini_xiangzhi"] = "韵律技，出牌阶段限一次，平：你摸一张牌；仄：你回复1点体力。<br>转韵：你发动〖节烈〗后。<br>"..
  "<font color='grey'>\"<b>韵律技</b>\"<br>一种特殊的技能，分为“平”和“仄”两种状态。游戏开始时，韵律技处于“平”状态；满足“转韵”条件后，"..
  "韵律技会转换到另一个状态，且重置技能发动次数。",
  ["mini_jielie"] = "节烈",
  [":mini_jielie"] = "出牌阶段限一次，你可以选择一项，令一名其他角色：1.其可以使用一张手牌，若此牌为红色【杀】，则你失去1点体力，"..
  "然后你可以再次发动〖节烈〗；2.你下次发动〖相知〗时，令其获得相同效果。",
  ["#mini_xiangzhi-ping"] = "相知：你可以摸一张牌",
  ["#mini_xiangzhi-ze"] = "相知：你可以回复1点体力",
  ["#mini_jielie"] = "节烈：令一名其他角色执行一项",
  ["mini_jielie1"] = "使用一张手牌",
  ["mini_jielie2"] = "其下次获得“相知”效果",
  ["#mini_jielie-use"] = "节烈：你可以使用一张牌，若为红色【杀】，%src 失去1点体力且可再次发动“节烈”",
  ["@@mini_xiangzhi"] = "相知",

  ["$mini_xiangzhi1"] = "衣带逐水去，绿川盼君留。",
  ["$mini_xiangzhi2"] = "溪边坐流水，与君共清欢。",
  ["$mini_jielie1"] = "此生逢伯符，足以慰平生。",
  ["$mini_jielie2"] = "所幸遇郎君，流离得良人。",
  ["~miniex__daqiao"] = "忆君如流水，日夜无歇时……",
}

local xiaoqiao = General(extension, "miniex__xiaoqiao", "wu", 3, 3, General.Female)
local mini_tongxin = fk.CreateActiveSkill{
  name = "mini_tongxin",
  anim_type = "control",
  card_num = function()
    if Self:getSwitchSkillState("mini_tongxin", false) == fk.SwitchYang then
      return 0
    else
      return 1
    end
  end,
  target_num = 1,
  prompt = function(self)
    if Self:getSwitchSkillState("mini_tongxin", false) == fk.SwitchYang then
      return "#mini_tongxin-ping"
    else
      return "#mini_tongxin-ze"
    end
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    if Self:getSwitchSkillState("mini_tongxin", false) == fk.SwitchYang then
      return false
    else
      return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
    end
  end,
  target_filter = function(self, to_select, selected)
    if #selected == 0 and to_select ~= Self.id then
      if Self:getSwitchSkillState("mini_tongxin", false) == fk.SwitchYang then
        return not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
      else
        return true
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if player:getSwitchSkillState("mini_tongxin", false) == fk.SwitchYang then
      local card = room:askForCard(target, 1, 1, false, self.name, false, ".", "#mini_tongxin-give:"..player.id)
      room:obtainCard(player.id, card[1], false, fk.ReasonGive)
      if not target.dead and target:getHandcardNum() <= player:getHandcardNum() then
        target:drawCards(1, self.name)
      end
    else
      room:obtainCard(target.id, effect.cards[1], false, fk.ReasonGive)
      if not target.dead and target:getHandcardNum() >= player:getHandcardNum() then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,
}
local mini_tongxin_record = fk.CreateTriggerSkill{
  name = "#mini_tongxin_record",

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill("mini_tongxin", true) and player.phase ~= Player.NotActive
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getMark("mini_tongxin-turn")
    if mark == 0 then mark = {} end
    if player.phase == Player.Play and not table.contains(mark, data.card:getTypeString()) then
      room:setPlayerMark(player, MarkEnum.SwithSkillPreName .. "mini_tongxin", player:getSwitchSkillState("mini_tongxin", true))
      room:notifySkillInvoked(player, "mini_tongxin", "switch")
      player:setSkillUseHistory("mini_tongxin", 0, Player.HistoryPhase)
    end
    table.insertIfNeed(mark, data.card:getTypeString())
    room:setPlayerMark(player, "mini_tongxin-turn", mark)
  end,
}
local mini_shaoyan = fk.CreateTriggerSkill{
  name = "mini_shaoyan",
  anim_type = "drawcard",
  events ={fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.room:getPlayerById(data.from):getHandcardNum() > player:getHandcardNum() and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
mini_tongxin:addRelatedSkill(mini_tongxin_record)
xiaoqiao:addSkill(mini_tongxin)
xiaoqiao:addSkill(mini_shaoyan)
Fk:loadTranslationTable{
  ["miniex__xiaoqiao"] = "极小乔",
  ["mini_tongxin"] = "同心",
  [":mini_tongxin"] = "韵律技，出牌阶段限一次，平：你可以令一名其他角色交给你一张手牌，然后若其手牌数不大于你，其摸一张牌；"..
  "仄：你可以交给一名其他角色一张手牌，然后若其手牌数不小于你，你对其造成1点伤害。<br>转韵：出牌阶段，使用本回合未使用过的类型的牌。<br>"..
  "<font color='grey'>\"<b>韵律技</b>\"<br>一种特殊的技能，分为“平”和“仄”两种状态。游戏开始时，韵律技处于“平”状态；满足“转韵”条件后，"..
  "韵律技会转换到另一个状态，且重置技能发动次数。",
  ["mini_shaoyan"] = "韶颜",
  [":mini_shaoyan"] = "每回合限一次，当你成为其他角色使用牌的目标后，若其手牌数大于你，你摸一张牌。",
  ["#mini_tongxin-ping"] = "同心：令一名角色交给你一张手牌，然后若其手牌数不大于你，其摸一张牌",
  ["#mini_tongxin-ze"] = "同心：交给一名其他角色一张手牌，然后若其手牌数不小于你，你对其造成1点伤害",
  ["#mini_tongxin-give"] = "同心：你需交给 %src 一张手牌",

  ["$mini_tongxin1"] = "嘘~心悦何须盟誓，二人同心足矣。",
  ["$mini_tongxin2"] = "看！公瑾与我，如钱之两面，此方口自然为心！",
  ["$mini_shaoyan1"] = "揽二乔于东南？哼，痴人说梦！",
  ["$mini_shaoyan2"] = "有公瑾在，曹贼安可过江东天险？",
  ["~miniex__xiaoqiao"] = "公瑾，好想你再拥我入怀……",
}

---@param room Room
---@param player ServerPlayer
---@param num integer @ 可以为负
local function handleMiaolue(room, player, num)
  local n = player:getMark("@mini_moulue") or 0
  room:setPlayerMark(player, "@mini_moulue", math.min(math.max(n + num, 0), 5))
  room:handleAddLoseSkills(player, player:getMark("@mini_moulue") > 0 and "mini_miaoji" or "-mini_miaoji", nil, false, true)
end

local guojia = General(extension, "miniex__guojia", "wei", 3)
local mini_suanlve = fk.CreateTriggerSkill{
  name = "mini_suanlve",
  anim_type = "special",
  events = {fk.GameStart, fk.EventPhaseStart, fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.GameStart then
        return player:getMark("@mini_moulue") < 5
      elseif event == fk.EventPhaseStart then
        return target == player and player.phase == Player.Start and player:getMark("@mini_moulue") > player:getHandcardNum()
      elseif event == fk.TurnEnd then
        if player:getMark("@mini_moulue") >= 5 then return end
        local x = 0
        local room = player.room
        local logic = room.logic
        local e = logic:getCurrentEvent()
        local end_id = e.id
        local events = logic.event_recorder[GameEvent.UseCard] or Util.DummyTable
        for i = #events, 1, -1 do
          e = events[i]
          if e.id <= end_id then break end
          local use = e.data[1]
          if use.from == player.id then
            x = x + 1
          end
        end
        events = logic.event_recorder[GameEvent.RespondCard] or Util.DummyTable
        for i = #events, 1, -1 do
          e = events[i]
          if e.id <= end_id then break end
          local use = e.data[1]
          if use.from == player.id then
            x = x + 1
          end
        end
        return x >= player.hp
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      handleMiaolue(room, player, 3)
    elseif event == fk.EventPhaseStart then
      player:drawCards(1, self.name)
    elseif event == fk.TurnEnd then
      handleMiaolue(room, player, player.hp)
    end
  end,
}
local mini_dingce = fk.CreateViewAsSkill{
  name = "mini_dingce",
  pattern = ".",
  interaction = function()
    local names = {}
      local card = Fk:cloneCard(Self:getMark("mini_dingce-turn"))
      if ((Fk.currentResponsePattern == nil and card.skill:canUse(Self, card) and not Self:prohibitUse(card)) or
        (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
        names = {Self:getMark("mini_dingce-turn")}
      end
    if #names == 0 then return end
    return UI.ComboBox {choices = names}
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function(self, player, use)
    handleMiaolue(player.room, player, - (player:usedSkillTimes(self.name, Player.HistoryRound) + 1))
  end,
  enabled_at_play = function(self, player)
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 or player:getMark("mini_dingce-turn") == 0 or player:isNude() or
      player:getMark("@mini_moulue") < player:usedSkillTimes(self.name, Player.HistoryRound) + 1 then return false end
    local card = Fk:cloneCard(player:getMark("mini_dingce-turn"))
    if card.skill:canUse(Self, card) and not Self:prohibitUse(card) then
      return true
    end
  end,
  enabled_at_response = function(self, player, response)
    if response or player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 or player:getMark("mini_dingce-turn") == 0 or player:isNude() or
      player:getMark("@mini_moulue") < player:usedSkillTimes(self.name, Player.HistoryRound) + 1 then return false end
    local card = Fk:cloneCard(player:getMark("mini_dingce-turn"))
    if card.skill:canUse(Self, card) and not Self:prohibitUse(card) then
      return true
    end
  end,
}
local mini_dingce_record = fk.CreateTriggerSkill{
  name = "#mini_dingce_record",

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and (data.card.type == Card.TypeBasic or data.card:isCommonTrick())
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "mini_dingce-turn", data.card.name)
  end,
}
local mini_miaoji = fk.CreateViewAsSkill{
  name = "mini_miaoji",
  pattern = "dismantlement,nullification,ex_nihilo",
  interaction = function()
    local all_names, names = {"dismantlement", "nullification", "ex_nihilo"}, {}
    for _, name in ipairs(all_names) do
      if Self:getMark("@mini_moulue") >= table.indexOf(all_names, name) then
        local card = Fk:cloneCard(name)
        if ((Fk.currentResponsePattern == nil and card.skill:canUse(Self, card) and not Self:prohibitUse(card)) or
            (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
          table.insertIfNeed(names, name)
        end
      end
    end
    if #names == 0 then return end
    return UI.ComboBox {choices = names}
  end,
  card_filter = function()
    return false
  end,
  view_as = function(self, cards)
    if not self.interaction.data then return nil end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    local names = {"dismantlement", "nullification", "ex_nihilo"}
    handleMiaolue(player.room, player, - table.indexOf(names, use.card.trueName))
  end,
  enabled_at_play = function(self, player)
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return false end
    local names = {"dismantlement", "nullification", "ex_nihilo"}
    for _, name in ipairs(names) do
      if player:getMark("@mini_moulue") >= table.indexOf(names, name) then
        local card = Fk:cloneCard(name)
        if Self:canUse(card) and not Self:prohibitUse(card) then
          return true
        end
      end
    end
  end,
  enabled_at_response = function(self, player, response)
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return false end
    local names = {"dismantlement", "nullification", "ex_nihilo"}
    for _, name in ipairs(names) do
      if player:getMark("@mini_moulue") >= table.indexOf(names, name) then
        local card = Fk:cloneCard(name)
        if Self:canUse(card) and not Self:prohibitUse(card) then
          return true
        end
      end
    end
  end,
}
guojia:addSkill(mini_suanlve)
mini_dingce:addRelatedSkill(mini_dingce_record)
guojia:addSkill(mini_dingce)
guojia:addRelatedSkill(mini_miaoji)
Fk:loadTranslationTable{
  ["miniex__guojia"] = "极郭嘉",
  ["mini_suanlve"] = "算略",
  [":mini_suanlve"] = "游戏开始时，你获得3点谋略值。准备阶段，若谋略值大于你的手牌数，你摸一张牌。"..
  "每个回合结束时，若你本回合使用或打出过的牌数不小于体力值，你获得等同于体力值的谋略值。"..
  "<br><font color='grey'>#\"<b>谋略值</b>\"：谋略值上限为5，有谋略值的角色拥有〖妙计〗。</font>",
  ["mini_dingce"] = "定策",
  [":mini_dingce"] = "每回合限一次，你可以消耗X+1点谋略值（X为你本轮发动此技能的次数），将一张牌当你本回合使用的上一张基本牌或普通锦囊牌使用。",
  ["mini_miaoji"] = "妙计",
  [":mini_miaoji"] = "每回合限一次，你可以消耗1~3点谋略值，视为使用对应的牌：1.【过河拆桥】；2.【无懈可击】；3.【无中生有】。",
  ["@mini_moulue"] = "谋略值",
}

local machao = General(extension, "miniex__machao", "qun", 4)

local qipao = fk.CreateTriggerSkill{
  name = "mini_qipao",
  events = {fk.TargetSpecified},
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and not player.room:getPlayerById(data.to).dead 
  end,
  on_cost = function(self, event, target, player, data)
    return target.room:askForSkillInvoke(player, self.name, data, "#mini_qipao-ask::" .. data.to)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local target = room:getPlayerById(data.to)
    local choices = {"mini_qipao_invalid"}
    if #target:getCardIds(Player.Equip) > 0 then table.insert(choices, 1, "mini_qipao_discard") end
    local choice = room:askForChoice(target, choices, self.name)
    if choice == "mini_qipao_discard" then
      target:throwAllCards("e")
    else
      data.disresponsive = true
      room:setPlayerMark(target, MarkEnum.UncompulsoryInvalidity .. "-turn", 1)
    end
  end,
}

local zhuixi = fk.CreateTriggerSkill{
  name = "mini_zhuixi",
  events = {fk.EventPhaseStart},
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and target.phase == Player.Finish and table.every(player.room.alive_players, function(p) return player:inMyAttackRange(p) or player == p end) and not player:prohibitUse(Fk:cloneCard("slash"))
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local slash = Fk:cloneCard("slash")
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not player:isProhibited(p, slash) then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#mini_zhuixi-ask", self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local slash = Fk:cloneCard("slash")
    slash.skillName = self.name
    player.room:useCard{
      from = target.id,
      tos = table.map(self.cost_data, function(pid) return { pid } end),
      card = slash,
      extraUse = true,
    }
  end,
}
local mini_zhuixi_distance = fk.CreateDistanceSkill{
  name = "#mini_zhuixi_distance",
  fixed_func = function(self, from, to)
    if from:hasSkill(self) and #to:getEquipments(Card.SubtypeDefensiveRide) == 0 and #to:getEquipments(Card.SubtypeDefensiveRide) == 0 then
      return 1
    end
  end,
}
zhuixi:addRelatedSkill(mini_zhuixi_distance)

machao:addSkill(qipao)
machao:addSkill(zhuixi)

Fk:loadTranslationTable{
  ["miniex__machao"] = "极马超",
  ["mini_qipao"] = "弃袍",
  [":mini_qipao"] = "当你使用【杀】指定目标后，你可令其选择一项：1. 弃置装备区内的所有牌（至少一张）；2. 此回合非锁定技失效且不能响应此【杀】。",
  ["mini_zhuixi"] = "追袭",
  [":mini_zhuixi"] = "①结束阶段，若其他角色均处于你的攻击范围内，你可选择一名角色，视为对其使用【杀】。②你至装备区里没有坐骑牌的角色的距离视为1。",

  ["#mini_qipao-ask"] = "你可对 %dest 发动“弃袍”",
  ["mini_qipao_discard"] = "弃置装备区内的所有牌",
  ["mini_qipao_invalid"] = "此回合非锁定技失效且不能响应此【杀】",
  ["@@mini_qipao-turn"] = "弃袍",
  ["#mini_qipao_dr"] = "弃袍",
  ["#mini_zhuixi-ask"] = "追袭：你可选择一名角色，视为对其使用【杀】",
}

local zhugeliang = General(extension, "miniex__zhugeliang", "shu", 3)
local sangu = fk.CreateTriggerSkill{
  name = "mini_sangu",
  events = {fk.TargetConfirmed},
  anim_type = "special",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@mini_sangu") // 3 == 1 and player:getMark("@mini_moulue") < 5
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@mini_sangu", 0)
    handleMiaolue(player.room, player, 3)
    room:askForGuanxing(player, room:getNCards(3), nil, {0, 0}, self.name)
  end,

  refresh_events = {fk.TargetConfirmed},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) 
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@mini_sangu", 1)
  end,
}

local yanshi = fk.CreateActiveSkill{
  name = "mini_yanshi",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  target_num = 0,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local top = room:getNCards(1)
    local bottom = room:getNCards(1, "bottom")
    local id = room:askForCardChosen(player, player, {
      card_data = {
        {"Top", top},
        {"Bottom", bottom},
      }
    }, self.name, "#mini_yanshi-ask")
    if id == bottom[1] then
      table.insert(room.draw_pile, 1, top[1])
    else
      table.insert(room.draw_pile, bottom[1])
    end
    room:obtainCard(player, id, false)
    if room:getCardArea(id) == Card.PlayerHand and room:getCardOwner(id) == player then
      room:setCardMark(Fk:getCardById(id), "@@mini_yanshi", 1)
    end
  end,
}
local yanshi_delay = fk.CreateTriggerSkill{
  name = "#mini_yanshi_delay",
  refresh_events = {fk.CardUsing, fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    return event == fk.AfterCardsMove or (player == target and player:hasSkill(yanshi.name))
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUsing then
      local num = #table.filter(Card:getIdList(data.card), function(id)
        return Fk:getCardById(id):getMark("@@mini_yanshi") > 0
      end)
      if num > 0 then
        room:notifySkillInvoked(player, "mini_yanshi", "special")
        table.forEach(Card:getIdList(data.card), function(id)
          return room:setCardMark(Fk:getCardById(id), "@@mini_yanshi", 0)
        end)
        player:setSkillUseHistory("mini_yanshi", 0, Player.HistoryPhase)
      end
    else
      for _, move in ipairs(data) do
        if move.from == player.id and move.moveReason ~= fk.ReasonUse then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              room:setCardMark(Fk:getCardById(info.cardId), "@@mini_yanshi", 0)
            end
          end
        end
      end
    end
  end,
}
yanshi:addRelatedSkill(yanshi_delay)

zhugeliang:addSkill(sangu)
zhugeliang:addSkill(yanshi)
zhugeliang:addRelatedSkill("mini_miaoji")

Fk:loadTranslationTable{
  ["miniex__zhugeliang"] = "极诸葛亮",
  ["mini_sangu"] = "三顾",
  [":mini_sangu"] = "锁定技，每当有三张牌指定你为目标后，你获得3点“谋略值”，然后你观看牌堆顶的三张牌并将这些牌置于牌堆顶。"..
  "<br><font color='grey'>#\"<b>谋略值</b>\"：谋略值上限为5，有谋略值的角色拥有〖妙计〗。</font>",
  ["mini_yanshi"] = "演势",
  [":mini_yanshi"] = "出牌阶段限一次，你可以观看牌堆顶和牌堆底的各一张牌，并获得其中一张。当你于此阶段使用此牌时，〖演势〗于此阶段内视为未发动过。",

  ["@mini_sangu"] = "三顾",
  ["@@mini_yanshi"] = "演势",
  ["#mini_yanshi-ask"] = "演势：观看牌堆顶和牌堆底的各一张牌，并选择获得其中一张",
}

local huangyueying = General(extension, "miniex__huangyueying", "shu", 3, 3, General.Female)
local miaobi = fk.CreateTriggerSkill{
  name = "mini_miaobi",
  events = {fk.CardUseFinished, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if event == fk.CardUseFinished then
      if not (player:hasSkill(self) and player.phase == Player.Play
      and data.card.type == Card.TypeTrick and U.isPureCard(data.card) and not table.contains(U.getMark(player, "_mini_miaobi_used-turn"), data.card.trueName)) then return false end 
      local room = player.room
      if room:getCardArea(data.card) ~= Card.Processing then return false end
      local targets = {}
      for _, pid in ipairs(TargetGroup:getRealTargets(data.tos)) do
        local p = room:getPlayerById(pid)
        if not p.dead then
          table.insertIfNeed(targets, pid)
        end
      end
      if #targets > 0 then
        self.cost_data = targets
        return true
      end
    else
      return #player:getPile("mini_miaobi_penmanship") > 0 and player.phase == Player.Start
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.CardUseFinished then
      local targets = self.cost_data
      local room = player.room
      if #targets == 1 then
        if room:askForSkillInvoke(player, self.name, data, "#mini_miaobi_only-ask::" .. targets[1] .. ":" .. data.card:toLogString()) then
          self.cost_data = targets[1]
          return true
        end
      else
        local target = player.room:askForChoosePlayers(player, targets, 1, 1, "#mini_miaobi-ask:::" .. data.card:toLogString(), self.name)
        if #target > 0 then
          self.cost_data = target[1]
          return true
        end
      end
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUseFinished then
      local record = U.getMark(player, "_mini_miaobi_used-turn")
      table.insert(record, data.card.trueName)
      room:setPlayerMark(player, "_mini_miaobi_used-turn", record)
      local target = room:getPlayerById(self.cost_data)
      target:addToPile("mini_miaobi_penmanship", data.card, true, self.name)
      if table.contains(target:getPile("mini_miaobi_penmanship"), data.card.id) then
        record = U.getMark(target, "_mini_miaobi")
        record[tostring(player.id)] = record[tostring(player.id)] or {}
        table.insert(record[tostring(player.id)], data.card.id)
        room:setPlayerMark(target, "_mini_miaobi", record)
      end
    else
      local record = player:getMark("_mini_miaobi")
      for k, v in pairs(record) do
        local from = room:getPlayerById(tonumber(k))
        local cards = table.filter(v, function (cid)
          return table.contains(player:getPile("mini_miaobi_penmanship"), cid)
        end)
        if not from.dead and #cards > 0 then 
          local c = {}
          if player ~= from then
            c = room:askForCard(player, 1, 1, true, self.name, true, ".|.|.|.|.|trick", "#mini_miaobi_delay:" .. from.id)
          end
          if #c > 0 then
            room:moveCardTo(c, Card.PlayerHand, from, fk.ReasonGive, self.name, nil, true, from.id)
            room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, "mini_miaobi_penmanship", true, player.id)
          else
            for _, cid in ipairs(cards) do
              local card = Fk:getCardById(cid)
              if from:canUse(card) and not from:prohibitUse(card) and not from:isProhibited(player, card) and
                  (card.skill:modTargetFilter(player.id, {}, from.id, card, false)) then
                local tos = { {player.id} }
                if card.skill:getMinTargetNum() == 2 then
                  local targets = table.filter(room.alive_players, function (p)
                    return card.skill:targetFilter(p.id, {player.id}, {}, card)
                  end)
                  if #targets > 0 then
                    local to_slash = room:askForChoosePlayers(from, table.map(targets, function (p)
                      return p.id
                    end), 1, 1, "#mini_miaobi-choose::"..player.id..":"..card:toLogString(), self.name, false)
                    if #to_slash > 0 then
                      table.insert(tos, to_slash)
                    end
                  end
                end

                if #tos >= card.skill:getMinTargetNum() then
                  room:useCard({
                    from = from.id,
                    tos = tos,
                    card = card,
                  })
                end
              end
            end
          end
        elseif #cards > 0 then
          room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, "mini_miaobi_penmanship", true, player.id)
        end
      end
      room:setPlayerMark(player, "_mini_miaobi", 0)
    end
  end,
}
local huixin = fk.CreateTriggerSkill{
  name = "mini_huixin",
  anim_type = "drawcard",
  mute = true,
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.type == Card.TypeTrick and player:getMark("@@mini_huixin-turn") == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if player.phase == Player.NotActive then
      room:notifySkillInvoked(player, self.name, "drawcard")
      player:drawCards(1, self.name)
    else
      room:notifySkillInvoked(player, self.name, "special")
      room:setPlayerMark(player, "@@mini_huixin-turn", 1)
    end
  end,
}
local huixinBuff = fk.CreateTargetModSkill{
  name = "#mini_huixin-buff",
  bypass_distances = function(self, player, skill, card, to)
    return player:getMark("@@mini_huixin-turn") > 0
  end,
}
huixin:addRelatedSkill(huixinBuff)

huangyueying:addSkill(miaobi)
huangyueying:addSkill(huixin)

Fk:loadTranslationTable{
  ["miniex__huangyueying"] = "极黄月英",
  ["mini_miaobi"] = "妙笔",
  [":mini_miaobi"] = "当你于出牌阶段内使用的、非转化且非虚拟的锦囊牌结算结束后，你可将此牌置于其中一个目标角色的武将牌上（每牌名每回合限一次）。拥有“妙笔”牌的角色的准备阶段，其选择一项：1. 交给你一张锦囊牌，将“妙笔”牌置入弃牌堆；2. 你对其依次使用“妙笔”牌。",
  ["mini_huixin"] = "慧心",
  [":mini_huixin"] = "当你于回合内/外使用锦囊牌时，你于此回合使用牌无距离限制/你摸一张牌。",

  ["#mini_miaobi_only-ask"] = "妙笔：你可将%arg置于%dest的武将牌上",
  ["#mini_miaobi-ask"] = "妙笔：你可将%arg置于一个目标角色的武将牌上",
  ["mini_miaobi_penmanship"] = "妙笔",
  ["#mini_miaobi_delay"] = "妙笔：将一张锦囊牌交给 %src，否则其对你依次使用“妙笔”牌",
  ["#mini_miaobi-choose"] = "妙笔：选择对%dest使用的%arg的副目标",
  ["@@mini_huixin-turn"] = "慧心",
}

local miniex__caocao = General(extension, "miniex__caocao", "wei", 4)
local delu = fk.CreateActiveSkill{
  name = "mini_delu",
  anim_type = "control",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  min_target_num = 1,
  max_target_num = 99,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return to_select ~= Self.id and target.hp <= Self.hp and not target:isKongcheng()
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = effect.tos
    local pd = player:pindian(table.map(targets, Util.Id2PlayerMapper), self.name)
    local pdNum = {}
    pdNum[player.id] = pd.fromCard.number
    table.forEach(targets, function(pid) pdNum[pid] = pd.results[pid].toCard.number end)
    local winner, num = nil, nil
    for k, v in pairs(pdNum) do
      if num == nil or num < v then
        num = v
        winner = k
      elseif num == v then
        winner = nil
      end
    end
    if winner then
      table.insert(targets, player.id)
      table.removeOne(targets, winner)
      if winner == player.id then player:broadcastSkillInvoke("guixin") end -- 彩蛋
      winner = room:getPlayerById(winner)
      if winner.dead then return false end
      room:sortPlayersByAction(targets)
      for _, pid in ipairs(targets) do
        local p = room:getPlayerById(pid)
        if not p:isAllNude() then
          local id = room:askForCardChosen(winner, p, "hej", self.name)
          room:obtainCard(winner, id, false, fk.ReasonPrey)
        end
      end
    end
  end,
}
local delu_delay = fk.CreateTriggerSkill{
  name = "#mini_delu_delay",
  mute = true,
  events = {fk.PindianCardsDisplayed},
  can_trigger = function(self, event, target, player, data)
    return data.from == player and data.reason == "mini_delu"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.fromCard.number = math.min(data.fromCard.number + #data.tos + 1, 13)
  end,
}
delu:addRelatedSkill(delu_delay)

local zhujiu = fk.CreateActiveSkill{
  name = "mini_zhujiu",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  target_num = 1,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected == 1 then return false end
    local target = Fk:currentRoom():getPlayerById(to_select)
    return to_select ~= Self.id and not target:isKongcheng()
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local extraData = {
      num = 1,
      min_num = 1,
      include_equip = false,
      pattern = ".",
      reason = self.name,
    }
    local prompt = "#askForZhujiu"
    local data = { "choose_cards_skill", prompt, true, json.encode(extraData) }
    local fromCard, toCard
    local targets = {player, target}
    for _, to in ipairs(targets) do
      to.request_data = json.encode(data)
    end

    room:notifyMoveFocus(targets, "AskForCardChosen")
    room:doBroadcastRequest("AskForUseActiveSkill", targets)

    for _, p in ipairs(targets) do
      local discussionCard -- 论英雄也是论
      if p.reply_ready then
        local replyCard = json.decode(p.client_reply).card
        discussionCard = json.decode(replyCard).subcards[1]
      else
        discussionCard = p:getCardIds(Player.Hand)[1]
      end
      if p == player then fromCard = discussionCard else toCard = discussionCard end
    end

    U.swapCards(room, player, player, target, {fromCard}, {toCard}, self.name)

    if Fk:getCardById(fromCard):compareColorWith(Fk:getCardById(toCard)) then
      if player:isWounded() and not player.dead then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name
        }
      end
    elseif not player.dead and not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}

miniex__caocao:addSkill(delu)
miniex__caocao:addSkill(zhujiu)
miniex__caocao:addSkill("hujia") -- 村

Fk:loadTranslationTable{
  ["miniex__caocao"] = "极曹操",
  ["mini_delu"] = "得鹿",
  [":mini_delu"] = "出牌阶段限一次，你可与任意名体力值不大于你的角色进行一次“逐鹿”，赢的角色依次获得没赢的角色区域内的一张牌。此次你拼点的牌点数+X（X为参加拼点的角色数）。" ..
  "<br/><font color='grey'>#\"<b>逐鹿</b>\"<br/>即“共同拼点”，所有角色一起拼点比大小。",
  ["mini_zhujiu"] = "煮酒",
  [":mini_zhujiu"] = "出牌阶段限一次，你可选择一名其他角色，你与其同时选择一张手牌并交换，若这两张牌颜色相同/不同，你回复1点体力/你对其造成1点伤害。",

  ["#mini_delu_delay"] = "得鹿",
  ["#askForZhujiu"] = "煮酒：选择一张手牌交换",
}

local simayi = General(extension, "miniex__simayi", "wei", 3)

local yinren = fk.CreateTriggerSkill{
  name = "mini_yinren",
  anim_type = "defensive",
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to == Player.Play
    and not (player:hasSkill("ex__jianxiong") and player:hasSkill("xingshang") and player:hasSkill("mingjian"))
  end,
  on_use = function(self, event, target, player, data)
    player:skip(Player.Play)
    player:skip(Player.Discard)
    for _, s in ipairs{"ex__jianxiong", "xingshang", "mingjian"} do
      if not player:hasSkill(s) then
        player.room:handleAddLoseSkills(player, s, nil)
        break
      end
    end
  end,
}

local mini_duoquan_viewas = fk.CreateViewAsSkill{
  name = "mini_duoquan_viewas",
  card_filter = function(self, to_select, selected)
    if #selected == 0 then
      local ids = Self:getMark("mini_duoquan_cards")
      return type(ids) == "table" and table.contains(ids, to_select)
    end
  end,
  view_as = function(self, cards)
    if #cards == 1 then
      return Fk:getCardById(cards[1])
    end
  end,
}
Fk:addSkill(mini_duoquan_viewas)
local duoquan = fk.CreateTriggerSkill{
  name = "mini_duoquan",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(room:getOtherPlayers(player), Util.IdMapper)
    local target = room:askForChoosePlayers(player, targets, 1, 1, "#mini_duoquan", self.name, true, true)
    if #target > 0 then
      local cardType = room:askForChoice(player, {"basic", "trick", "equip"}, self.name)
      self.cost_data = {target[1], cardType}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local target = room:getPlayerById(self.cost_data[1])
    local cardType = self.cost_data[2]
    local record = U.getMark(target, "_mini_duoquan")
    local list = type(record[tostring(player.id)]) == "table" and record[tostring(player.id)] or {}
    table.insert(list, cardType)
    record[tostring(player.id)] = list
    room:setPlayerMark(target, "_mini_duoquan", record)
  end,
}
local duoquan_delay = fk.CreateTriggerSkill{
  name = "#mini_duoquan_delay",
  events = {fk.CardUsing},
  anim_type = "control",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target:getMark("_mini_duoquan") ~= 0 and target.phase == Player.Play and table.contains(target:getMark("_mini_duoquan")[tostring(player.id)] or {}, data.card:getTypeString()) 
    and target.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e) 
      local use = e.data[1]
      return use.from == target.id
    end, Player.HistoryPhase)[1].id == target.room.logic:getCurrentEvent().id
  end,
  on_use = function(self, event, target, player, data)
    local room = target.room
    room:doIndicate(player.id, {target.id})
    if data.toCard ~= nil then
      data.toCard = nil
    else
      data.nullifiedTargets = TargetGroup:getRealTargets(data.tos)
    end
    room:setPlayerMark(player, "mini_duoquan_cards", Card:getIdList(data.card))
    room.logic:getCurrentEvent():addCleaner(function(s)
      local ids = player:getMark("mini_duoquan_cards")
      for _, id in ipairs(ids) do
        if room:getCardArea(id) ~= Card.Processing then
          return false
        end
      end
      room:delay(800)
      local move_to_notify = {}   ---@type CardsMoveStruct
      move_to_notify.toArea = Card.PlayerHand
      move_to_notify.to = player.id
      move_to_notify.moveInfo = {}
      move_to_notify.moveReason = fk.ReasonJustMove
      for _, id in ipairs(ids) do
        table.insert(move_to_notify.moveInfo,
        { cardId = id, fromArea = Card.Void })
      end
      room:notifyMoveCards({player}, {move_to_notify})
      room:setPlayerMark(player, "mini_duoquan_cards", ids)
      local success, dat = room:askForUseActiveSkill(player, "mini_duoquan_viewas", "#mini_duoquan-invoke", true, Util.DummyTable, true)
      room:setPlayerMark(player, "mini_duoquan_cards", 0)
      move_to_notify = {}   ---@type CardsMoveStruct
      move_to_notify.from = player.id
      move_to_notify.toArea = Card.Void
      move_to_notify.moveInfo = {}
      move_to_notify.moveReason = fk.ReasonJustMove
      for _, id in ipairs(ids) do
        table.insert(move_to_notify.moveInfo,
        { cardId = id, fromArea = Card.PlayerHand})
      end
      room:notifyMoveCards({player}, {move_to_notify})
      if success then
        local card = Fk.skills["mini_duoquan_viewas"]:viewAs(dat.cards)
        player.room:useCard{
          from = player.id,
          tos = table.map(dat.targets, function(id) return {id} end),
          card = card,
        }
      end
    end)
  end,

  refresh_events = {fk.EventPhaseChanging},
  can_refresh = function(self, event, target, player, data)
    return player == target and target:getMark("_mini_duoquan") ~= 0 and data.from == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    target.room:setPlayerMark(target, "_mini_duoquan", 0)
  end,
}
duoquan:addRelatedSkill(duoquan_delay)

simayi:addSkill(yinren)
simayi:addSkill(duoquan)
simayi:addRelatedSkill("ex__jianxiong")
simayi:addRelatedSkill("xingshang")
simayi:addRelatedSkill("mingjian")

Fk:loadTranslationTable{
  ["miniex__simayi"] = "极司马懿",
  ["mini_yinren"] = "隐忍",
  [":mini_yinren"] = "回合开始时，你可跳过出牌阶段和弃牌阶段，然后获得以下技能中你没有的第一个技能：〖奸雄〗、〖行殇〗、〖明鉴〗。",
  ["mini_duoquan"] = "夺权",
  [":mini_duoquan"] = "结束阶段，你可秘密选择一名其他角色和一种类型，当其下个出牌阶段使用第一张牌时，若此牌的类型与你选择的类型相同，则你令其无效，然后当此牌结算完毕后，你可使用此牌对应的一张实体牌。", 
  
  ["#mini_duoquan"] = "夺权：你可秘密选择一名其他角色，确定后选择一种类型",
  ["#mini_duoquan-invoke"] = "是否使用夺权，使用其中的牌",
  ["#mini_duoquan_delay"] = "夺权",
  ["mini_duoquan_viewas"] = "夺权",
}

local liuling = General(extension, "liuling", "qun", 3)
local jiusong = fk.CreateViewAsSkill{
  name = "jiusong",
  pattern = "analeptic",
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
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.name == "analeptic" and player:getMark("@liuling_drunk") < 3
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@liuling_drunk")
  end,
}
jiusong:addRelatedSkill(jiusong_trig)
local maotao = fk.CreateTriggerSkill{
  name = "maotao",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:getMark("@liuling_drunk") > 0 and #TargetGroup:getRealTargets(data.tos) == 1 then
      return table.every(player.room.alive_players, function(p) return not p.dying end)
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#maotao-ask:::" .. data.card:toLogString())
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, "@liuling_drunk")

    -- copy from xxyheaven ❤
    local orig_to = data.tos[1]
    local targets = {}
    if #orig_to > 1 then
      --target_filter check, for collateral,diversion...
      local c_pid
      --FIXME：借刀需要补modTargetFilter，不给targetFilter传使用者真是离大谱，目前只能通过强制修改Self来实现
      local Notify_from = room:getPlayerById(data.from)
      Self = Notify_from
      for _, p in ipairs(room.alive_players) do
        if not player:isProhibited(p, data.card) and data.card.skill:modTargetFilter(p.id, {}, data.from, data.card, false) then
          local ho_spair_target = {}
          local ho_spair_check = true
          for i = 2, #orig_to, 1 do
            c_pid = orig_to[i]
            if not data.card.skill:targetFilter(c_pid, ho_spair_target, {}, data.card) then
              ho_spair_check = false
              break
            end
            table.insert(ho_spair_target, c_pid)
          end
          if ho_spair_check then
            table.insert(targets, p.id)
          end
        end
      end
    else
      for _, p in ipairs(room.alive_players) do
        if not player:isProhibited(p, data.card) and (data.card.sub_type == Card.SubtypeDelayedTrick or
        data.card.skill:modTargetFilter(p.id, {}, data.from, data.card, false)) then
          table.insert(targets, p.id)
        end
      end
    end
    if #targets > 0 then
      local random_target = table.random(targets)
      if random_target == orig_to[1] then
        local cids = room:getCardsFromPileByRule("analeptic")
        if #cids > 0 then
          room:obtainCard(player, cids[1], false, fk.ReasonPrey)
        end
      else
        orig_to[1] = random_target
        data.tos = {orig_to}
      end
    else
      data.tos = {}
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
  [":maotao"] = "当其他角色使用牌时，若目标数为1且没有处于濒死状态的角色，你可弃1枚“醉”标记，令此牌改为随机指定一个目标（不受距离限制）。若此目标与原目标相同，则你从牌堆中获得一张【酒】。",
  ["bishi"] = "避仕",
  [":bishi"] = "锁定技，你不能成为伤害类锦囊牌的目标。",

  ["@liuling_drunk"] = "醉",
  ["#jiusong_trig"] = "酒颂",
  ["#maotao-ask"] = "酕醄：你可1枚“醉”标记，随机改变%arg的目标",
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
    if data.damageEvent and player == data.damageEvent.from and player:distanceTo(target) < 2 then
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
  [":mini__kuanggu"] = "锁定技，当你对小于2以内的一名角色造成1点伤害后，你回复1点体力并摸一张牌。",

  ["$mini__kuanggu1"] = "沙场驰骋，但求一败！",
  ["$mini__kuanggu2"] = "我自横扫天下，蔑视群雄又如何？",
  ["~mini__weiyan"] = "怨气，终难平……",
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
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(cards[choice])
    room:obtainCard(player.id, dummy, true, fk.ReasonJustMove)
    room:addPlayerMark(player, "@mini__zaiqi")
    cids = table.filter(cids, function(id) return room:getCardArea(id) == Card.Processing end)
    room:moveCards{
      ids = cids,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonJustMove,
    }
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
        if p.phase ~= Player.NotActive and p:hasSkill(mini__wansha.name) then
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
      local other_players = room:getOtherPlayers(target)
      local luanwu_targets = table.map(table.filter(other_players, function(p2)
        return table.every(other_players, function(p1)
          return target:distanceTo(p1) >= target:distanceTo(p2)
        end) and p2 ~= player
      end), Util.IdMapper)
      local use = room:askForUseCard(target, "slash", "slash", "#mini__luanwu-use", true, {exclusive_targets = luanwu_targets})
      if use then
        room:useCard(use)
      else
        room:loseHp(target, 1, self.name)
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
    if #room:askForDiscard(data.to, n, n, false, self.name, true, ".", "#qingxi-discard:::"..n) == n then
      if player:getEquipment(Card.SubtypeWeapon) then
        room:throwCard({player:getEquipment(Card.SubtypeWeapon)}, self.name, player, data.to)
      end
    else
      data.damage = data.damage + 1
    end
  end,
}
caoxiu:addSkill(qingxi)
Fk:loadTranslationTable{
  ["mini__caoxiu"] = "曹休",
  ["mini__qingxi"] = "倾袭",
  [":mini__qingxi"] = "当你对其他角色造成伤害时，你可以令其选择一项：1.弃置X张手牌，然后弃置你装备区里的武器牌（X为你的攻击范围）；2.令此伤害+1。",
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

return extension
