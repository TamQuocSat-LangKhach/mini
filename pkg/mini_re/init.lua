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
  ["#mini__caocao"] = "魏武帝",
}

General:new(extension, "mini__xuchu", "wei", 4):addSkills { "mini__luoyi" }
Fk:loadTranslationTable{
  ["mini__xuchu"] = "许褚",
  ["#mini__xuchu"] = "虎痴",
  ["illustrator:mini__xuchu"] = "巴萨小马",
}

General:new(extension, "mini__guanyu", "shu", 4):addSkills { "wusheng", "mini__qinglong" }
Fk:loadTranslationTable{
  ["mini__guanyu"] = "关羽",
  ["#mini__guanyu"] = "美髯公",
}

General:new(extension, "mini__zhangfei", "shu", 4):addSkills { "paoxiao", "mini__shemao" }
Fk:loadTranslationTable{
  ["mini__zhangfei"] = "张飞",
  ["#mini__zhangfei"] = "万夫不当",
}

General:new(extension, "mini__zhaoyun", "shu", 4):addSkills { "longdan", "mini__qinggang" }
Fk:loadTranslationTable{
  ["mini__zhaoyun"] = "赵云",
  ["#mini__zhaoyun"] = "少年将军",
}

General:new(extension, "mini__machao", "shu", 4):addSkills { "mini__tieqi", "mashu" }
Fk:loadTranslationTable{
  ["mini__machao"] = "马超",
  ["#mini__machao"] = "一骑当千",
}

General:new(extension, "mini__lvmeng", "wu", 4):addSkill("mini__keji")
Fk:loadTranslationTable{
  ["mini__lvmeng"] = "吕蒙",
  ["#mini__lvmeng"] = "白衣渡江",
}

General:new(extension, "mini__sunshangxiang", "wu", 3, 3, General.Female):addSkills {
  "mini__jieyin",
  "xiaoji",
}
Fk:loadTranslationTable{
  ["mini__sunshangxiang"] = "孙尚香",
  ["#mini__sunshangxiang"] = "弓腰姬",
}

General:new(extension, "mini__xiahouyuan", "wei", 4):addSkill("mini__shensu")
Fk:loadTranslationTable{
  ["mini__xiahouyuan"] = "夏侯渊",
  ["#mini__xiahouyuan"] = "疾行的猎豹",
}

General:new(extension, "mini__caoren", "wei", 4):addSkill("mini__jushou")
Fk:loadTranslationTable{
  ["mini__caoren"] = "曹仁",
  ["#mini__caoren"] = "大将军",
}

General:new(extension, "mini__huangzhong", "shu", 4):addSkill("mini__liegong")
Fk:loadTranslationTable{
  ["mini__huangzhong"] = "黄忠",
  ["#mini__huangzhong"] = "老当益壮",
}

General:new(extension, "mini__weiyan", "shu", 4):addSkill("mini__kuanggu")
Fk:loadTranslationTable{
  ["mini__weiyan"] = "魏延",
  ["#mini__weiyan"] = "嗜血的独狼",
}

General:new(extension, "mini__pangtong", "shu", 3):addSkills { "mini__lianhuan", "mini__niepan" }
Fk:loadTranslationTable{
  ["mini__pangtong"] = "庞统",
  ["#mini__pangtong"] = "凤雏",
}

General:new(extension, "mini__menghuo", "shu", 4):addSkills { "mini__huoshou", "mini__zaiqi" }
Fk:loadTranslationTable{
  ["mini__menghuo"] = "孟获",
  ["#mini__menghuo"] = "南蛮王",
}

General:new(extension, "mini__jiaxu", "qun", 3):addSkills { "mini__wansha", "mini__luanwu", "weimu" }
Fk:loadTranslationTable{
  ["mini__jiaxu"] = "贾诩",
  ["#mini__jiaxu"] = "冷酷的毒士",
}

General:new(extension, "mini__caiwenji", "qun", 3, 3, General.Female):addSkills { "mini__beige", "mini__duanchang" }
Fk:loadTranslationTable{
  ["mini__caiwenji"] = "蔡文姬",
  ["#mini__caiwenji"] = "异乡的孤女",
  ["illustrator:mini__caiwenji"] = "砚对溪华",
}

General:new(extension, "mini__godzhugeliang", "god", 3):addSkills { "mini__qixing", "mini__tianfa", "mini_jifeng" }
Fk:loadTranslationTable{
  ["mini__godzhugeliang"] = "神诸葛亮",
}

General:new(extension, "mini_ex__zhaoyun", "shu", 4):addSkills { "mini_ex__longdan", "mini_ex__yajiao" }
Fk:loadTranslationTable{
  ["mini_ex__zhaoyun"] = "界赵云",
  ["#mini_ex__zhaoyun"] = "虎威将军",
}

General:new(extension, "mini_ex__pangde", "qun", 4):addSkills { "mashu", "mini_ex__mengjin" }
Fk:loadTranslationTable{
  ["mini_ex__pangde"] = "界庞德",
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
