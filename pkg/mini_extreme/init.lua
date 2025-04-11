local extension = Package("mini_extreme")
extension.extensionName = "mini"

extension:loadSkillSkelsByPath("./packages/mini/pkg/mini_extreme/skills")

Fk:loadTranslationTable{
  ["mini_extreme"] = "小程序-登峰造极",
  ["mini"] = "小程序",
  ["miniex"] = "极",
}

General:new(extension, "miniex__lvbu", "qun", 4):addSkills { "wushuang", "mini_xiaohu" }
Fk:loadTranslationTable{
  ["miniex__lvbu"] = "极吕布",

  ["$wushuang_miniex__lvbu1"] = "此身此武，天下无双！",
  ["$wushuang_miniex__lvbu2"] = "乘赤兔，舞画戟，斩将破敌不过举手而为！",

  ["~miniex__lvbu"] = "我天下无敌，却不能与貂蝉共度余生了……",
}

General:new(extension, "miniex__daqiao", "wu", 3, 3, General.Female):addSkills {
  "mini_xiangzhi",
  "mini_jielie",
}
Fk:loadTranslationTable{
  ["miniex__daqiao"] = "极大乔",

  ["~miniex__daqiao"] = "忆君如流水，日夜无歇时……",
}

General:new(extension, "miniex__xiaoqiao", "wu", 3, 3, General.Female):addSkills {
  "mini_tongxin",
  "mini_shaoyan",
}
Fk:loadTranslationTable{
  ["miniex__xiaoqiao"] = "极小乔",

  ["~miniex__xiaoqiao"] = "公瑾，好想你再拥我入怀……",
}

local miniExGuojia = General:new(extension, "miniex__guojia", "wei", 3)
miniExGuojia:addSkills { "mini_dingce", "mini_suanlve" }
miniExGuojia:addRelatedSkill("mini_miaoji")
Fk:loadTranslationTable{
  ["miniex__guojia"] = "极郭嘉",

  ["~miniex__guojia"] = "经此一别，已无再见之日……",
}

General:new(extension, "miniex__machao", "shu", 4):addSkills { "mini_qipao", "mini_zhuixi" }
Fk:loadTranslationTable{
  ["miniex__machao"] = "极马超",

  ["~miniex__machao"] = "曹贼！战场再见，吾必杀汝！",
}

local miniExZhugeliang = General:new(extension, "miniex__zhugeliang", "shu", 3)
miniExZhugeliang:addSkills { "mini_sangu", "mini_yanshi" }
miniExZhugeliang:addRelatedSkill("mini_miaoji")
Fk:loadTranslationTable{
  ["miniex__zhugeliang"] = "极诸葛亮",

  ["$mini_miaoji_miniex__zhugeliang1"] = "大梦先觉，感三顾之诚，布天下三分。",
  ["$mini_miaoji_miniex__zhugeliang2"] = "卧龙初晓，铭鱼水之情，托死生之志。",

  ["~miniex__zhugeliang"] = "君臣鱼水犹昨日，煌煌天命终不归……",
}

local miniExHuangyueying = General:new(extension, "miniex__huangyueying", "shu", 3, 3, General.Female)
miniExHuangyueying:addSkills { "mini_miaobi", "mini_huixin" }
miniExHuangyueying:addRelatedSkills { "jizhi", "mini_jifeng" }
Fk:loadTranslationTable{
  ["miniex__huangyueying"] = "极黄月英",

  ["~miniex__huangyueying"] = "纨质陨残暮，思旧梦魂远。",
}

General:new(extension, "miniex__caocao", "wei", 4):addSkills { "mini_delu", "mini_zhujiu" }
Fk:loadTranslationTable{
  ["miniex__caocao"] = "极曹操",

  ["~miniex__caocao"] = "吾之一生或负天下，然终不负己心。",
}

local miniExSimayi = General:new(extension, "miniex__simayi", "wei", 3)
miniExSimayi:addSkills { "mini_yinren", "mini_duoquan" }
miniExSimayi:addRelatedSkills { "ex__jianxiong", "xingshang", "mingjian" }
Fk:loadTranslationTable{
  ["miniex__simayi"] = "极司马懿",

  ["~miniex__simayi"] = "辟基立业，就交于子元了……",
}

General:new(extension, "miniex__yuanshao", "qun", 4):addSkills { "mini_zunbei", "mini_mengshou" }
Fk:loadTranslationTable{
  ["miniex__yuanshao"] = "极袁绍",

  ["~miniex__yuanshao"] = "思谋无断，始至今日……",
}

General:new(extension, "miniex__lusu", "wu", 3):addSkills { "mini_lvyuan", "mini_hezong" }
Fk:loadTranslationTable{
  ["miniex__lusu"] = "极鲁肃",

  ["~miniex__lusu"] = "孙刘永结一心，天下必归吾主，咳咳咳……",
}

General:new(extension, "miniex__xuchu", "wei", 4):addSkills { "mini_huhou", "mini_wuwei" }
Fk:loadTranslationTable{
  ["miniex__xuchu"] = "极许褚",

  ["~miniex__xuchu"] = "丞相，丞相！呃啊……",
}

General:new(extension, "miniex__xunyu", "wei", 3):addSkills {
  "mini_wangzuo",
  "mini_juxian",
  "mini_xianshi",
}
Fk:loadTranslationTable{
  ["miniex__xunyu"] = "极荀彧",

  ["~miniex__xunyu"] = "初旨可共图，殊途难同归。",
}

General:new(extension, "miniex__zhenji", "wei", 3, 3, General.Female):addSkills {
  "mini_shenfu",
  "mini_siyuan",
}
Fk:loadTranslationTable{
  ["miniex__zhenji"] = "极甄姬",

  ["~miniex__zhenji"] = "以发覆面，何等凄凉……",
}

General:new(extension, "miniex__sunce", "wu", 4):addSkills {
  "mini_taoni",
  "mini_pingjiang",
  "mini_dingye",
}
Fk:loadTranslationTable{
  ["miniex__sunce"] = "极孙策",

  ["~miniex__sunce"] = "有众卿鼎力相辅，仲谋必成大事。",
}

General:new(extension, "miniex__sunquan", "wu", 4):addSkills { "mini__zongxi", "mini__luheng" }
Fk:loadTranslationTable{
  ["miniex__sunquan"] = "极孙权",

  ["~miniex__sunquan"] = "余子碌碌，竟无承位之人。",
}

local miniExZhouyu = General:new(extension, "miniex__zhouyu", "wu", 3)
miniExZhouyu:addSkills { "miniex__yingrui", "miniex__fenli" }
miniExZhouyu:addRelatedSkill("mini_miaoji")
Fk:loadTranslationTable{
  ["miniex__zhouyu"] = "极周瑜",

  ["~miniex__zhouyu"] = "伯符，瑜来也……",
}

General:new(extension, "miniex__caiwenji", "qun", 3, 3, General.Female):addSkills {
  "mini_beijia",
  "mini_sifu",
}
Fk:loadTranslationTable{
  ["miniex__caiwenji"] = "极蔡文姬",

  ["~miniex__caiwenji"] = "怨兮欲问天，天苍苍兮上无缘……",
}

General:new(extension, "miniex__guanyu", "shu", 4):addSkills { "mini__yihan", "mini__wuwei" }

Fk:loadTranslationTable{
  ["miniex__guanyu"] = "极关羽",

  ["~miniex__guanyu"] = "大丈夫为忠为义，何惜死乎！",
}

local miniExJiangwei = General:new(extension, "miniex__jiangwei", "shu", 4)
miniExJiangwei:addSkills { "mini__gujin", "mini__qumou" }
miniExJiangwei:addRelatedSkill("mini_miaoji")
Fk:loadTranslationTable{
  ["miniex__jiangwei"] = "极姜维",
}

General:new(extension, "miniex__caozhi", "wei", 3):addSkills { "mini__caiyi", "mini__aoxiang" }
Fk:loadTranslationTable{
  ["miniex__caozhi"] = "极曹植",
}

General:new(extension, "miniex__liubei", "shu", 4):addSkills { "mini__guizhi", "mini__hengyi" }
Fk:loadTranslationTable{
  ["miniex__liubei"] = "极刘备",
}

General:new(extension, "miniex__zhurong", "shu", 4, 4, General.Female):addSkills {
  "mini__xiangwei",
  "mini__yanfeng",
}
Fk:loadTranslationTable{
  ["miniex__zhurong"] = "极祝融",
}

General:new(extension, "miniex__dongzhuo", "qun", 5):addSkills { "mini__weicheng", "mini__bianguan" }
Fk:loadTranslationTable{
  ["miniex__dongzhuo"] = "极董卓",
}

General:new(extension, "miniex__hetaihou", "qun", 3, 3, General.Female):addSkills {
  "mini__fuyin",
  "mini__qiangji",
}
Fk:loadTranslationTable{
  ["miniex__hetaihou"] = "极何太后",
}

General:new(extension, "miniex__wangyi", "wei", 3, 3, General.Female):addSkills {
  "mini__zuoqing",
  "mini__jianchou",
}
Fk:loadTranslationTable{
  ["miniex__wangyi"] = "极王异",
}

General:new(extension, "miniex__zhangchunhua", "wei", 3, 3, General.Female):addSkills {
  "mini__juejue",
  "mini__qingshiz",
  "mini__qingjuez",
}
Fk:loadTranslationTable{
  ["miniex__zhangchunhua"] = "极张春华",
}

General:new(extension, "miniex__zhangfei", "shu", 4):addSkills { "mini__hupo", "mini__hanxing" }
Fk:loadTranslationTable{
  ["miniex__zhangfei"] = "极张飞",
}

return extension
