local extension = Package("mini_re")
extension.extensionName = "mini"

extension:loadSkillSkelsByPath("./packages/mini/pkg/mini_re/skills")

Fk:loadTranslationTable{
  ["mini_re"] = "小程序-修改",
  ["mini_ex"] = "小程序界",
  ["mini_sp"] = "小程序SP",
}

General:new(extension, "mini__caocao", "wei", 4):addSkills { "mini__jianxiong", "hujia" }
Fk:loadTranslationTable{
  ["mini__caocao"] = "曹操",
}

General:new(extension, "mini__lvmeng", "wu", 4):addSkill("mini__keji")
Fk:loadTranslationTable{
  ["mini__lvmeng"] = "吕蒙",
}

General:new(extension, "mini__sunshangxiang", "wu", 3, 3, General.Female):addSkills {
  "mini__jieyin",
  "xiaoji",
}
Fk:loadTranslationTable{
  ["mini__sunshangxiang"] = "孙尚香",
}

General:new(extension, "mini__xiahouyuan", "wei", 4):addSkill("mini__shensu")
Fk:loadTranslationTable{
  ["mini__xiahouyuan"] = "夏侯渊",
}

General:new(extension, "mini__caoren", "wei", 4):addSkill("mini__jushou")
Fk:loadTranslationTable{
  ["mini__caoren"] = "曹仁",
}

General:new(extension, "mini__weiyan", "shu", 4):addSkill("mini__kuanggu")
Fk:loadTranslationTable{
  ["mini__weiyan"] = "魏延",
}

General:new(extension, "mini__pangtong", "shu", 3):addSkills { "mini__lianhuan", "mini__niepan" }
Fk:loadTranslationTable{
  ["mini__pangtong"] = "庞统",
}

General:new(extension, "mini__pangde", "qun", 4):addSkills { "mashu", "mini__jianchu" }
Fk:loadTranslationTable{
  ["mini__pangde"] = "庞德",
}

General:new(extension, "mini__menghuo", "shu", 4):addSkills { "mini__huoshou", "mini__zaiqi" }
Fk:loadTranslationTable{
  ["mini__menghuo"] = "孟获",
}

General:new(extension, "mini__jiaxu", "qun", 3):addSkills { "mini__wansha", "mini__luanwu", "weimu" }
Fk:loadTranslationTable{
  ["mini__jiaxu"] = "贾诩",
}

General:new(extension, "mini__caiwenji", "qun", 3, 3, General.Female):addSkills { "mini__beige", "mini__duanchang" }
Fk:loadTranslationTable{
  ["mini__caiwenji"] = "蔡文姬",
  ["illustrator:mini__caiwenji"] = "砚对溪华",
}

General:new(extension, "mini__godzhugeliang", "god", 3):addSkills { "mini__qixing", "mini__tianfa", "mini_jifeng" }
Fk:loadTranslationTable{
  ["mini__godzhugeliang"] = "神诸葛亮",
}

General:new(extension, "mini_ex__zhaoyun", "shu", 4):addSkills { "mini_ex__longdan", "mini_ex__yajiao" }
Fk:loadTranslationTable{
  ["mini_ex__zhaoyun"] = "界赵云",
}

General:new(extension, "mini__xushu", "shu", 3):addSkills { "mini__wuyan", "jujian" }
Fk:loadTranslationTable{
  ["mini__xushu"] = "徐庶",
}

General:new(extension, "mini__caochong", "wei", 3):addSkills { "chengxiang", "mini__renxin" }
Fk:loadTranslationTable{
  ["mini__caochong"] = "曹冲",
}

General:new(extension, "mini__caoxiu", "wei", 4):addSkills { "qianju", "mini__qingxi" }
Fk:loadTranslationTable{
  ["mini__caoxiu"] = "曹休",
}

General:new(extension, "mini__zhangxingcai", "shu", 3, 3, General.Female):addSkills {
  "mini__shenxian",
  "mini__qiangwu",
}
Fk:loadTranslationTable{
  ["mini__zhangxingcai"] = "张星彩",
  ["#mini__zhangxingcai"] = "敬哀皇后",
}

local miniSpJiangwei = General:new(extension, "mini_sp__jiangwei", "wei", 4)
miniSpJiangwei:addSkills { "mini_sp__kunfen", "mini_sp__fengliang" }
miniSpJiangwei:addRelatedSkill("m_ex__tiaoxin")
Fk:loadTranslationTable{
  ["mini_sp__jiangwei"] = "姜维",
}

General:new(extension, "mini__wuguotai", "wu", 3, 3, General.Female):addSkills {
  "mini__ganlu",
  "buyi",
}
Fk:loadTranslationTable{
  ["mini__wuguotai"] = "吴国太",
}

General:new(extension, "mini__yangxiu", "wei", 3):addSkills {
  "mini__danlao",
  "ty__jilei",
}
Fk:loadTranslationTable{
  ["mini__yangxiu"] = "杨修",
  ["#mini__yangxiu"] = "恃才放旷",
  ["illustrator:mini__yangxiu"] = "NOVART", -- 胸中绵帛
}

General:new(extension, "sunhanhua", "wu", 3, 3, General.Female):addSkills {
  "mini__chongxu",
  "miaojian",
  "lianhuas",
}
Fk:loadTranslationTable{
  ["sunhanhua"] = "孙寒华",
  ["#sunhanhua"] = "挣绽的青莲",
  ["illustrator:sunhanhua"] = "匠人绘",

  ["~sunhanhua"] = "天有寒暑，人有死生……",
}

General:new(extension, "mini__bianfuren", "wei", 3, 3, General.Female):addSkills { "mini__wanwei", "mini__yuejian" }
Fk:loadTranslationTable{
  ["mini__bianfuren"] = "卞夫人",
  ["#mini__bianfuren"] = "紫绡雪颜",
  ["illustrator:mini__bianfuren"] = "凡果",
}

General:new(extension, "mini_sp__caiwenji", "wei", 3, 3, General.Female):addSkills { "chenqing", "mini__mozhi" }
Fk:loadTranslationTable{
  ["mini_sp__caiwenji"] = "蔡文姬",
  ["#mini_sp__caiwenji"] = "金璧之才",
  ["illustrator:mini_sp__caiwenji"] = "圆子",

  ["$chenqing_mini_sp__caiwenji1"] = "虎士成林，何惜疾足一骑。",
  ["$chenqing_mini_sp__caiwenji2"] = "翩翩吹我衣，肃肃入我耳。",
  ["~mini_sp__caiwenji"] = "今生悲苦，总算完结了。",
}

local guanyinping =  General:new(extension, "mini__guanyinping", "shu", 3, 3, General.Female)
guanyinping:addSkills { "mini__xuehen", "mini__huxiao", "mini__wuji" }
guanyinping:addRelatedSkill("ex__wusheng")
Fk:loadTranslationTable{
  ["mini__guanyinping"] = "关银屏",
  ["#mini__guanyinping"] = "烈焰炽魂",

  ["~mini__guanyinping"] = "女儿无能，竟使父亲蒙羞……",
}

return extension
