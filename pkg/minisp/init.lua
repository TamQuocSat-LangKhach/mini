local extension = Package:new("minisp")
extension.extensionName = "mini"

extension:loadSkillSkelsByPath("./packages/mini/pkg/minisp/skills")

Fk:loadTranslationTable{
  ["minisp"] = "小程序专属",
}

General:new(extension, "liuling", "qun", 3):addSkills { "jiusong", "maotao", "bishi" }
Fk:loadTranslationTable{
  ["liuling"] = "刘伶",

  ["~liuling"] = "哈……呼……（醉后鼾声渐小的声音）",
}

General:new(extension, "wangrong", "wei", 3):addSkills { "jianlin", "sixiao" }
Fk:loadTranslationTable{
  ["wangrong"] = "王戎",
  ["#wangrong"] = "善发谈端",

  ["~wangrong"] = "自阮，嵇云亡，为世所羁，实有所叹。",
}

General:new(extension, "xiangxiu", "wei", 3):addSkills { "miaoxi", "sijiu" }
Fk:loadTranslationTable{
  ["xiangxiu"] = "向秀",

  ["~xiangxiu"] = "无为民自化，丧我与物齐。",
}

General:new(extension, "mini__jikang", "wei", 3):addSkills { "jikai", "qingkuang", "yinyij" }
Fk:loadTranslationTable{
  ["mini__jikang"] = "嵇康",

  ["~mini__jikang"] = "",
}

return extension
