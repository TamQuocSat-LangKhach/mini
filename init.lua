local extension = Package("mini")

Fk:loadTranslationTable{
  ["mini"] = "小程序",
  ["miniex"] = "极",
}

local lvbu = General(extension, "miniex__lvbu", "qun", 4)
local mini_xiaohu = fk.CreateTriggerSkill{
  name = "mini_xiaohu",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Play and not player:isKongcheng()
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
  ["miniex__lvbu"] = "吕布",
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
  ["miniex__daqiao"] = "大乔",
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
    return target == player and player:hasSkill(self.name) and player.room:getPlayerById(data.from):getHandcardNum() > player:getHandcardNum() and
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
  ["miniex__xiaoqiao"] = "小乔",
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
}

local guojia = General(extension, "miniex__guojia", "wei", 3)
local mini_suanlve = fk.CreateTriggerSkill{
  name = "mini_suanlve",
  anim_type = "special",
  events = {fk.GameStart, fk.EventPhaseStart, fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      if event == fk.GameStart then
        return true
      elseif event == fk.EventPhaseStart then
        return target == player and player.phase == Player.Start and player:getMark("@guojia_moulve") > player:getHandcardNum()
      elseif event == fk.TurnEnd then
        return player:getMark("mini_suanlve-turn") >= player.hp
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      room:addPlayerMark(player, "@guojia_moulve", 3)
    elseif event == fk.EventPhaseStart then
      player:drawCards(1, self.name)
    elseif event == fk.TurnEnd then
      room:addPlayerMark(player, "@guojia_moulve", player.hp)
    end
  end,

  refresh_events = {fk.CardUsing, fk.CardResponding},
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "mini_suanlve-turn", 1)
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
    player.room:removePlayerMark(player, "@guojia_moulve", player:usedSkillTimes(self.name, Player.HistoryRound) + 1)
  end,
  enabled_at_play = function(self, player)
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 or player:getMark("mini_dingce-turn") == 0 or player:isNude() or
      player:getMark("@guojia_moulve") < player:usedSkillTimes(self.name, Player.HistoryRound) + 1 then return false end
    local card = Fk:cloneCard(player:getMark("mini_dingce-turn"))
    if card.skill:canUse(Self, card) and not Self:prohibitUse(card) then
      return true
    end
  end,
  enabled_at_response = function(self, player, response)
    if response or player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 or player:getMark("mini_dingce-turn") == 0 or player:isNude() or
      player:getMark("@guojia_moulve") < player:usedSkillTimes(self.name, Player.HistoryRound) + 1 then return false end
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
      if Self:getMark("@guojia_moulve") >= table.indexOf(all_names, name) then
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
    player.room:removePlayerMark(player, "@guojia_moulve", table.indexOf(names, use.card.trueName))
  end,
  enabled_at_play = function(self, player)
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return false end
    local names = {"dismantlement", "nullification", "ex_nihilo"}
    for _, name in ipairs(names) do
      if player:getMark("@guojia_moulve") >= table.indexOf(names, name) then
        local card = Fk:cloneCard(name)
        if card.skill:canUse(Self, card) and not Self:prohibitUse(card) then
          return true
        end
      end
    end
  end,
  enabled_at_response = function(self, player, response)
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return false end
    local names = {"dismantlement", "nullification", "ex_nihilo"}
    for _, name in ipairs(names) do
      if player:getMark("@guojia_moulve") >= table.indexOf(names, name) then
        local card = Fk:cloneCard(name)
        if card.skill:canUse(Self, card) and not Self:prohibitUse(card) then
          return true
        end
      end
    end
  end,
}
guojia:addSkill(mini_suanlve)
mini_dingce:addRelatedSkill(mini_dingce_record)
guojia:addSkill(mini_dingce)
guojia:addSkill(mini_miaoji)
Fk:loadTranslationTable{
  ["miniex__guojia"] = "郭嘉",
  ["mini_suanlve"] = "算略",
  [":mini_suanlve"] = "游戏开始时，你获得3点谋略值。准备阶段，若谋略值大于你的手牌数，你摸一张牌。"..
  "每个回合结束时，若你本回合使用或打出过的牌数不小于体力值，你获得等同于体力值的谋略值。",
  ["mini_dingce"] = "定策",
  [":mini_dingce"] = "每回合限一次，你可以消耗X+1点谋略值（X为你本轮发动此技能的次数），将一张牌当你本回合使用的上一张基本牌或普通锦囊牌使用。",
  ["mini_miaoji"] = "妙计",
  [":mini_miaoji"] = "每回合限一次，你可以消耗1~3点谋略值，视为使用对应的牌：1.【过河拆桥】；2.【无懈可击】；3.【无中生有】。",
  ["@guojia_moulve"] = "谋略值",
}

--应n神要求把喵藏在这里
local nya__caiwenji = General(extension, "nya_caiwenji", "qun", 3, 3, General.Female)
nya__caiwenji.total_hidden = true
nya__caiwenji:addSkill("ol_ex__beige")
nya__caiwenji:addSkill("duanchang")
nya__caiwenji:addSkill("chenqing")
nya__caiwenji:addSkill("mozhi")
nya__caiwenji:addSkill("shuangjia")
nya__caiwenji:addSkill("beifen")

local nya__diaochan = General(extension, "nya_diaochan", "qun", 3, 3, General.Female)
nya__diaochan.total_hidden = true
nya__diaochan:addSkill("lijian")
nya__diaochan:addSkill("ex__biyue")
nya__diaochan:addSkill("lihun")
nya__diaochan:addSkill("huoxin")
nya__diaochan:addSkill("meihun")

local nya__caifuren = General(extension, "nya_caifuren", "qun", 3, 3, General.Female)
nya__caifuren.total_hidden = true
nya__caifuren:addSkill("m_ex__qieting")
nya__caifuren:addSkill("xianzhou")

local nya__xingcai = General(extension, "nya_xingcai", "shu", 3, 3, General.Female)
nya__xingcai.total_hidden = true
nya__xingcai:addSkill("shenxian")
nya__xingcai:addSkill("qiangwu")

local nya__zhurong = General(extension, "nya_zhurong", "shu", 4, 4, General.Female)
nya__zhurong.total_hidden = true
nya__zhurong:addSkill("juxiang")
nya__zhurong:addSkill("lieren")
nya__zhurong:addSkill("ol_ex__changbiao")

local nya__huangyueying = General(extension, "nya_huangyueying", "shu", 3, 3, General.Female)
nya__huangyueying.total_hidden = true
nya__huangyueying:addSkill("ex__jizhi")
nya__huangyueying:addSkill("ex__qicai")
nya__huangyueying:addSkill("ty__jiqiao")
nya__huangyueying:addSkill("ty__linglong")

local nya__daqiao = General(extension, "nya_daqiao", "wu", 3, 3, General.Female)
nya__daqiao.total_hidden = true
nya__daqiao:addSkill("ex__guose")
nya__daqiao:addSkill("liuli")
nya__daqiao:addSkill("yanxiao")
nya__daqiao:addSkill("anxian")
nya__daqiao:addSkill("mini_xiangzhi")
nya__daqiao:addSkill("mini_jielie")

local nya__xiaoqiao = General(extension, "nya_xiaoqiao", "wu", 3, 3, General.Female)
nya__xiaoqiao.total_hidden = true
nya__xiaoqiao:addSkill("ol_ex__tianxiang")
nya__xiaoqiao:addSkill("ol_ex__hongyan")
nya__xiaoqiao:addSkill("ol_ex__piaoling")
nya__xiaoqiao:addSkill("mini_tongxin")
nya__xiaoqiao:addSkill("mini_shaoyan")

local nya__sunshangxiang = General(extension, "nya_sunshangxiang", "wu", 3, 3, General.Female)
nya__sunshangxiang.total_hidden = true
nya__sunshangxiang:addSkill("ex__jieyin")
nya__sunshangxiang:addSkill("xiaoji")
nya__sunshangxiang:addSkill("liangzhu")
nya__sunshangxiang:addSkill("fanxiang")

local nya__zhenji = General(extension, "nya_zhenji", "wei", 3, 3, General.Female)
nya__zhenji.total_hidden = true
nya__zhenji:addSkill("ex__luoshen")
nya__zhenji:addSkill("qingguo")

local nya__zhangchunhua = General(extension, "nya_zhangchunhua", "wei", 3, 3, General.Female)
nya__zhangchunhua.total_hidden = true
nya__zhangchunhua:addSkill("ty_ex__jueqing")
nya__zhangchunhua:addSkill("ty_ex__shangshi")

local nya__wangyi = General(extension, "nya_wangyi", "wei", 4, 4, General.Female)
nya__wangyi.total_hidden = true
nya__wangyi:addSkill("zhenlie")
nya__wangyi:addSkill("miji")

Fk:loadTranslationTable{
  ["nya"] = "喵",
  ["nya_caiwenji"] = "文姬喵",
  ["nya_diaochan"] = "貂蝉喵",
  ["nya_caifuren"] = "蔡夫人喵",
  ["nya_xingcai"] = "星彩喵",
  ["nya_zhurong"] = "祝融喵",
  ["nya_huangyueying"] = "月英喵",
  ["nya_daqiao"] = "大乔喵",
  ["nya_xiaoqiao"] = "小乔喵",
  ["nya_sunshangxiang"] = "香香喵",
  ["nya_zhenji"] = "甄姬喵",
  ["nya_zhangchunhua"] = "春华喵",
  ["nya_wangyi"] = "王异喵",
}

Fk:loadTranslationTable{
  ["miniex__guojia"] = "郭嘉",
  ["mini_suanlve"] = "算略",
  [":mini_suanlve"] = "游戏开始时，你获得3点谋略值。准备阶段，若谋略值大于你的手牌数，你摸一张牌。"..
  "每个回合结束时，若你本回合使用或打出过的牌数不小于体力值，你获得等同于体力值的谋略值。",
  ["mini_dingce"] = "定策",
  [":mini_dingce"] = "每回合限一次，你可以消耗X+1点谋略值（X为你本轮发动此技能的次数），将一张牌当你本回合使用的上一张基本牌或普通锦囊牌使用。",
  ["mini_miaoji"] = "妙计",
  [":mini_miaoji"] = "每回合限一次，你可以消耗1~3点谋略值，视为使用对应的牌：1.【过河拆桥】；2.【无懈可击】；3.【无中生有】。",
  ["@guojia_moulve"] = "谋略值",
}

local caocao = General(extension, "mini__caocao", "wei", 4)

local mini__jianxiong = fk.CreateTriggerSkill{
  name = "mini__jianxiong",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target == player and data.card and player.phase ~= Player.NotActive and 
    not table.contains(type(player:getMark("@$mini__jianxiong-turn")) == "table" and player:getMark("@$mini__jianxiong-turn") or {}, data.card.trueName) and 
    table.every(data.card:isVirtual() and data.card.subcards or {data.card.id}, function(id) return player.room:getCardArea(id) == Card.Processing end) and not player.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:broadcastSkillInvoke("guixin")
    local record = type(player:getMark("@$mini__jianxiong-turn")) == "table" and player:getMark("@$mini__jianxiong-turn") or {}
    table.insert(record, data.card.trueName)
    room:setPlayerMark(player, "@$mini__jianxiong-turn", record)
    room:obtainCard(player, data.card, true, fk.ReasonJustMove)
  end
}

caocao:addSkill(mini__jianxiong)
caocao:addSkill("hujia")

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
    return player:hasSkill(self.name) and target == player and (data.extra_data or {}).kuanggucheak
  end,
  on_trigger = function(self, event, target, player, data)
    for i = 1, data.damage do
      if not player:hasSkill(self.name) then break end
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
    if player:hasSkill(self.name) and data.card and data.card.trueName == "savage_assault" then
      if event == fk.PreCardEffect then
        return data.to == player.id
      else
        return target ~= player
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
    if event == fk.PreCardEffect then
      return true
    else
      local room = player.room
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
    return target == player and player:hasSkill(self.name) and player.phase == Player.Draw and player:usedSkillTimes(self.name, Player.HistoryGame) < 7
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cids = room:getNCards(player:usedSkillTimes(self.name, Player.HistoryGame) + 1)
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

  ["#mini__huoshou-ask"] = "祸首：是否弃置一张牌，令 %dest 受到的伤害+1",
  ["@mini__zaiqi"] = "再起",
  ["#mini__zaiqi-ask"] = "再起：选择一种颜色，获得该颜色的所有牌",
}

local zhangxingcai = General(extension, "mini__zhangxingcai", "shu", 3, 3, General.Female)
local mini__shenxian = fk.CreateTriggerSkill{
  name = "mini__shenxian",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end
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
      if not player:hasSkill(self.name) then break end
      self:doCost(event, nil, player, data)
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:broadcastSkillInvoke("shenxian")
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
return extension
