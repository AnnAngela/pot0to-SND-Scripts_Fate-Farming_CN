--[[

********************************************************************************
*                                Fate Farming                                  *
*                               Version 2.21.10                                 *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)
State Machine Diagram: https://github.com/pot0to/pot0to-SND-Scripts/blob/main/FateFarmingStateMachine.drawio.png

    -> 2.21.10  Fix call to vbmai preset
    -> 2.21.9   By Allison
                添加了一项优先检查距离FATE的功能，考虑到传送后实际距离可能更短。
                新增了FatePriority设置。默认行为与之前相同，但会增加上面的新检查，
                    顺序为：进度 -> 奖励 -> 剩余时间 -> 距离。
                新增了一个设置，用于判断当没有FATE时是否应在以太之光处等待。
                    如果禁用，则在FATE结束的位置等待。
                将WaitUpTo的名称修改为与MinWait一致。
                新增了一项检查，如果使用RSR作为输出插件，则禁用VBM的选定目标功能。
                对选择下一个FATE后的等待时间做了小的调整，从而使接近时离FATE中心更远。
                在移动中增加了额外检查以防止取消施法。
                在被推出FATE时可能出现的问题也做了修正。
                修正了“should it to Turn”拼写错误，改为“should it do Turn”。
            
    -> 2.21.8   添加了在伴随模式下脚本自然结束时自动切回原始职业的逻辑。
                修正了“PorcentageToHoldBuff”拼写错误。
                修正了FATE完成后返回中心位置这一部分的逻辑。
                移除了跳跃动作。
                修正了伴随模式下换分线的逻辑。
                调整了着陆逻辑，希望能够防止在空中卡得太高。
                新增了只执行奖励FATE的功能。
                调整了旧萨雷安双色宝石商人的坐标。
                增加了对多区域农FATE的支持。
                增加了一些萨纳兰NPC FATE。
                清理了Yak'tel FATE逻辑，并调整了飞回以太之光时的着陆条件。
                增加了飞回以太之光时的高度限制检查。
                重新设计了双色宝石兑换流程。
                为双色宝石商人新增了检查和调试提示。
                修复了拉诺西亚外地和南萨纳兰的飞行禁令问题。
                增加了当你距离收集FATE的NPC太远而无法选择时向FATE中心移动的功能。
    -> 2.21.6   修复了 FATE 结束后返回中心位置的逻辑问题
    -> 2.21.5   移除了跳跃动作
    -> 2.21.4   修复 “切换副本” 时的 "CompanionScriptMode" 脚本问题
                调整降落逻辑，以避免卡在过高的位置
                新增 “仅执行奖励 FATE” 功能
                调整旧萨雷安（Old Sharlayan）双色宝石商人坐标
                支持多个区域的 FATE 刷怪
                增加部分萨纳兰（Thanalan）区域的 NPC FATE
                清理 "Yak'tel FATE" 逻辑，并优化飞行返回以太之光时的降落条件
                新增飞行返回以太之光时的高度限制检查
                重新设计双色宝石兑换逻辑
                为双色宝石商人新增检测与调试功能
                修复拉诺西亚外地（Outer La Noscea）和南萨纳兰（Southern Thanalan）的飞行禁令问题
                新增功能：在收集类 FATE 目标 NPC 过远时，自动朝中心移动
                增加反外挂优化：
                    - 更平滑的下坐骑动作（虽然变化不大）
                    - 新增检查，防止 Vnav 在施法时被打断
                    - 在 Boss 级 FATE 战斗中，禁用 Vnav 导航路径
                    
原始地址：https://github.com/pot0to/pot0to-SND-Scripts/blob/d3121696c6d5f8ddf463a7e18fd368643d6b47c3/Fate%20Farming/Fate%20Farming.lua
已针对国服进行汉化（核心功能完全可用，6.0 / 7.0 地图完全支持，2.0 - 5.0 地图基本可用，可选功能未验证）

********************************************************************************
*                              需要的 dalamud 插件                              *
********************************************************************************

运行所需的插件：

    -> Something Need Doing [Expanded Edition] : （实现所有功能所必需的主插件）   https://puni.sh/api/repository/croizat
    -> VNavmesh :   (用于自动飞 fate)    https://puni.sh/api/repository/veyn
    -> 至少一个自动输出插件:
        -> RotationSolver Reborn: https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json       
        -> BossMod Reborn: https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
        -> Veyn's BossMod: https://puni.sh/api/repository/veyn
        -> Wrath Combo: https://love.puni.sh/ment.json
        -> 其他（此时该插件不由脚本控制，需要你自己控制）
    -> 至少一个自动走位插件: 
        -> BossMod Reborn: https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
        -> Veyn's BossMod: https://puni.sh/api/repository/veyn
    -> TextAdvance: (用于与 fate 的 NPC交互) https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
    -> Teleporter :  (用于传送至以太之光 [teleport][Exchange][Retainers])
    -> Lifestream :  (用于换线 [ChangeInstance][Exchange]) https://raw.githubusercontent.com/NightmareXIV/MyDalamudPlugins/main/pluginmaster.json

********************************************************************************
*                               可选的 dalamud 插件                             *
********************************************************************************

这些插件是可选的，除非您在设置中启用它，否则不需要：

    -> AutoRetainer : (用于收雇员 [Retainers])   https://love.puni.sh/ment.json
    -> Deliveroo : (用于交军票 [TurnIn])   https://plugins.carvel.li/
    -> YesAlready : (用于精制魔晶石)

--------------------------------------------------------------------------------------------------------------------------------------------------------------
]]

--#region Settings

--[[
********************************************************************************
*                                     设置                                     *
********************************************************************************
]]

--打 fate 前的设置
Food                                = ""            -- 如果您不想使用任何食物，请将 "" 留空。如果是 HQ，则在名称后添加 <hq>，如 "烧烤暗色茄子 <hq>"
Potion                              = ""            -- 如果您不想使用任何药水，请将 "" 留空。
ShouldSummonChocobo                 = true          -- 设置为 true 将会自动召唤陆行鸟
    ResummonChocoboTimeLeft         = 3 * 60        -- 如果计时器剩余的时间少于这个数值（单位：秒），则重新召唤陆行鸟，这样它就不会在命运中途消失。
    ChocoboStance                   = "治疗战术"     -- 选择一项填入: 跟随/自由战术/防护战术/进攻战术/治疗战术，推荐自由战术（防止未加点导致切换战术失败）
    ShouldAutoBuyGysahlGreens       = true          -- 如果背包里没有基萨尔野菜，会自动去海都商人那里购买 99 个
MountToUse                          = "随机坐骑"     -- 填入坐骑，脚本会使用该坐骑来飞往fate，需要完整、准确的名称
                                                                 -- 如果值为 "随机坐骑"，则会使用游戏内的随机坐骑功能
FatePriority                        = {"DistanceTeleport", "Progress", "DistanceTeleport", "Bonus", "TimeLeft", "Distance"}
                                                    -- Fate优先级设置，"Progress"-进度，"Bonus"-奖励，"TimeLeft"-剩余时间，"Distance"-距离，"DistanceTeleport"-传送距离
--Fate 战斗设置
CompletionToIgnoreFate              = 80            -- 如果 fate 的进度不小于这个百分比，就跳过它
MinTimeLeftToIgnoreFate             = 3*60          -- 如果 fate 的剩余时间不小于这个数值（单位：秒），就跳过它
CompletionToJoinBossFate            = 0             -- 如果 boss 型 fate 的进度不大于这个百分比，就跳过它（用以避免单挑 boss）
    CompletionToJoinSpecialBossFates = 20           -- 如果 boss 型特殊 fate 的进度不大于这个百分比，就跳过它（例如“蛇王得酷热涅：荒野的死斗”、“亩鼠米卡：盛装巡游皆大欢喜”）
    ClassForBossFates               = ""            -- 如果你想让脚本在打 boss 型 fate 时切换另一个职业，请将此值设置为职业的三字母缩写
                                                    -- 例如：PLD 指代骑士，具体详见下方 CassList 参数
JoinCollectionsFates                = true          -- 设为 false 则跳过收集型 fate，
BonusFatesOnly                      = false         -- 设为 true 将只参加有额外奖励的 fate
MeleeDist                           = 2.5           -- 近战职业攻击距离（用于自动走位插件），建议设为 2.5，若不小于 2.59 将会导致近战职业“无法发动自动攻击，目标在范围之外。”
RangedDist                          = 8             -- 远程职业攻击距离（用于自动走位插件），推荐8/20，建议不大于 25.49
                                                       -- 特别地，如果你的职业有【以自身为圆心的圆形 aoe】（如诗人等），建议不大于【你的这类技能的攻击距离】
RotationPlugin                      = "None"        -- 自动输出插件（None 代表不由脚本控制的自动输出插件，比如 AE 等）: RSR/BMR/VBM/Wrath/None
    RSRAoeType                      = "Full"        -- 可选项: Cleave/Full/Off
                                                        -- 仅 Rotation Solver Reborn (RSR)

    -- 支持 BMR/VBM/Wrath
    RotationSingleTargetPreset      = ""            -- 单体输出模式的预设的名称（用于迷失者、迷失少女）
    RotationAoePreset               = ""            -- AOE 模式的预设的名称
    RotationHoldBuffPreset          = ""            -- 留爆发模式的预设的名称
    PercentageToHoldBuff            = 65            -- 当 fate 的进度不小于此百分比数值时，切换为留爆发模式，有助于减少爆发技能的浪费。如果打得太快，该值不小于 70% 时仍然有可能导致爆发溢出
DodgingPlugin                       = "BMR"         -- 自动走位插件: BMR/VBM/None. 如果你使用 BMR/VBM 作为自动输出插件，该值将被忽略

IgnoreForlorns                      = false         -- 设为 true 将不打迷失者、迷失少女
    IgnoreBigForlornOnly            = false         -- 设为 true 将不打迷失者

--FATE 结束后的设置
MinWait                             = 3             -- 在前往下一个 FATE 之前等待的最小秒数。
MaxWait                             = 10            -- 在前往下一个 FATE 之前等待的最大秒数。
                                                        -- 实际等待时间将在 MinWait 和 MaxWait 之间随机生成。
DownTimeWaitAtNearestAetheryte      = false         -- 当等待 FATE 刷新时，是否应该飞到最近的以太之光并在那里等待？
EnableChangeInstance                = true          -- 设为 true 如果当前分线没有 fate，则切换分线（仅在有分线的地图可用）
    WaitIfBonusBuff                 = true          -- 设为 true 将在拥有“危命奖励提高” buff 时不换线
    NumberOfInstances               = 3             -- 最大分线数
ShouldExchangeBicolorGemstones      = false         -- 设为 true 则在双色宝石即将溢出时兑换双色宝石的收据
    ItemToPurchase                  = "图拉尔双色宝石的收据"        -- 可选项：双色宝石的收据/图拉尔双色宝石的收据/犎牛肩肉
SelfRepair                          = false         -- 设为 true 将在装备即将损坏时自己修复，否则将会回到海都找维修工修复
    RepairAmount                    = 20            -- 当装备耐久度平均值低于此值时开始修复
    ShouldAutoBuyDarkMatter         = true          -- 当8级暗物质不足时自动去海都商人那里购买 99 个
ShouldExtractMateria                = true          -- 是否在装备精炼度满时自动精制魔晶石
Retainers                           = true          -- 是否自动收雇员
ShouldGrandCompanyTurnIn            = false         -- 是否自动交军票 (需要 Deliveroo)
    InventorySlotsLeft              = 5             -- 当背包剩余空间小于此值时开始交军票

Echo                                = "All"         -- 可选项: All/Gems/None （All：脚本会提示所有信息，Gems：脚本只会提示与双色宝石有关的信息，None：脚本不提示信息）

CompanionScriptMode                 = false         -- 仅在其他脚本要求时才设为 true

--#endregion Settings

--[[
********************************************************************************
*                       以下内容请勿修改，以免脚本功能异常                        *
********************************************************************************
]]

--#region Plugin Checks and Setting Init

if not HasPlugin("vnavmesh") then
    yield("/echo [FATE] 请安装 vnavmesh")
end

if not HasPlugin("BossMod") and not HasPlugin("BossModReborn") then
    yield("/echo [FATE] 请安装一个AI躲避插件，例如Veyn's BossMod或BossMod Reborn")
end

if not HasPlugin("TextAdvance") then
    yield("/echo [FATE] 请安装 TextAdvance")
end

if EnableChangeInstance == true  then
    if HasPlugin("Lifestream") == false then
        yield("/echo [FATE] 请安装Lifestream或在设置中禁用ChangeInstance")
    end
end
if Retainers then
    if not HasPlugin("AutoRetainer") then
        yield("/echo [FATE] 请安装 AutoRetainer")
    end
end
if ShouldGrandCompanyTurnIn then
    if not HasPlugin("Deliveroo") then
        ShouldGrandCompanyTurnIn = false
        yield("/echo [FATE] 请安装 Deliveroo")
    end
end
if ShouldExtractMateria then
    if HasPlugin("YesAlready") == false then
        yield("/echo [FATE] 请安装 YesAlready")
    end
end
if DodgingPlugin == "None" then
    -- do nothing
elseif RotationPlugin == "BMR" and DodgingPlugin ~= "BMR" then
    DodgingPlugin = "BMR"
elseif RotationPlugin == "VBM" and DodgingPlugin ~= "VBM"  then
    DodgingPlugin = "VBM"
end

yield("/at y")

--snd property
function setSNDProperty(propertyName, value)
    local currentValue = GetSNDProperty(propertyName)
    if currentValue ~= value then
        SetSNDProperty(propertyName, tostring(value))
        LogInfo("[SetSNDProperty] " .. propertyName .. " set to " .. tostring(value))
    end
end

setSNDProperty("UseItemStructsVersion", true)
setSNDProperty("UseSNDTargeting", true)
setSNDProperty("StopMacroIfTargetNotFound", false)
setSNDProperty("StopMacroIfCantUseItem", false)
setSNDProperty("StopMacroIfItemNotFound", false)
setSNDProperty("StopMacroIfAddonNotFound", false)
setSNDProperty("StopMacroIfAddonNotVisible", false)

--#endregion Plugin Checks and Setting Init

--#region Data

CharacterCondition = {
    dead=2,
    mounted=4,
    inCombat=26,
    casting=27,
    occupiedInEvent=31,
    occupiedInQuestEvent=32,
    occupied=33,
    boundByDuty34=34,
    occupiedMateriaExtractionAndRepair=39,
    betweenAreas=45,
    jumping48=48,
    jumping61=61,
    occupiedSummoningBell=50,
    betweenAreasForDuty=51,
    boundByDuty56=56,
    mounting57=57,
    mounting64=64,
    beingMoved=70,
    flying=77
}

ClassList =
{
    gla = { classId=1,  className="剑术师",   isMelee=true,  isTank=true  },
    pgl = { classId=2,  className="格斗家",   isMelee=true,  isTank=false },
    mrd = { classId=3,  className="斧术师",   isMelee=true,  isTank=true  },
    lnc = { classId=4,  className="枪术师",   isMelee=true,  isTank=false },
    arc = { classId=5,  className="弓箭手",   isMelee=false, isTank=false },
    cnj = { classId=6,  className="幻术师",   isMelee=false, isTank=false },
    thm = { classId=7,  className="咒术师",   isMelee=false, isTank=false },
    pld = { classId=19, className="骑士",     isMelee=true,  isTank=true  },
    mnk = { classId=20, className="武僧",     isMelee=true,  isTank=false },
    war = { classId=21, className="战士",     isMelee=true,  isTank=true  },
    drg = { classId=22, className="龙骑士",   isMelee=true,  isTank=false },
    brd = { classId=23, className="吟游诗人", isMelee=false, isTank=false },
    whm = { classId=24, className="白魔法师", isMelee=false, isTank=false },
    blm = { classId=25, className="黑魔法师", isMelee=false, isTank=false },
    acn = { classId=26, className="秘术师",   isMelee=false, isTank=false },
    smn = { classId=27, className="召唤师",   isMelee=false, isTank=false },
    sch = { classId=28, className="学者",     isMelee=false, isTank=false },
    rog = { classId=29, className="双剑师",   isMelee=false, isTank=false },
    nin = { classId=30, className="忍者",     isMelee=true,  isTank=false },
    mch = { classId=31, className="机工士",   isMelee=false, isTank=false },
    drk = { classId=32, className="暗黑骑士", isMelee=true,  isTank=true  },
    ast = { classId=33, className="占星术士", isMelee=false, isTank=false },
    sam = { classId=34, className="武士",     isMelee=true,  isTank=false },
    rdm = { classId=35, className="赤魔法师", isMelee=false, isTank=false },
    blu = { classId=36, className="青魔法师", isMelee=false, isTank=false },
    gnb = { classId=37, className="绝枪战士", isMelee=true,  isTank=true  },
    dnc = { classId=38, className="舞者",     isMelee=false, isTank=false },
    rpr = { classId=39, className="钐镰客",   isMelee=true,  isTank=false },
    sge = { classId=40, className="贤者",     isMelee=false, isTank=false },
    vpr = { classId=41, className="蝰蛇剑士", isMelee=true,  isTank=false },
    pct = { classId=42, className="绘灵法师", isMelee=false, isTank=false }
}

BicolorExchangeData =
{
    {
        shopKeepName = "广域交易商 加德弗里德",
        zoneName = "旧萨雷安",
        zoneId = 962,
        aetheryteName = "旧萨雷安",
        x=78, y=5, z=-37,
        shopItems =
        {
            { itemName = "双色宝石的收据", itemIndex = 8, price = 100 }
        }
    },
    {
        shopKeepName = "广域交易商 贝瑞尔",
        zoneName = "九号解决方案",
        zoneId = 1186,
        aetheryteName = "九号解决方案",
        x=-198.47, y=0.92, z=-6.95,
        miniAethernet = {
            name = "联合商城",
            x=-157.74, y=0.29, z=17.43
        },
        shopItems =
        {
            { itemName = "图拉尔双色宝石的收据", itemIndex = 6, price = 100 },
            { itemName = "犎牛肩肉", itemIndex = 9, price = 3 }            
        }
    }
}

FatesData = {
    {
        zoneName = "中拉诺西亚",
        zoneId = 134,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="无穷无尽的打地鼠" , npcName="一筹莫展的农夫" },
                { fateName="实战巡礼", npcName="黄衫队训练教官"},
                { fateName="鼠害的小聪明", npcName="求助的农夫" }, --防御
                { fateName="德内维尔关防卫训练", npcName="魔鬼漩士 杜恩法尔"} --防御
            },
            fatesWithContinuations = {
                { fateName="追逐", continuationIsBoss=true }
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "拉诺西亚低地",
        zoneId = 135,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="花丛噩梦" , npcName="愤怒的农夫" },
                { fateName="小麦粉战争" , npcName="求助的风车管理人" },
                { fateName="海盗的方式" , npcName="黄衫队陆战兵" },
                { fateName="麻烦人生——偷渡者阿科特修提姆", npcName="熟练的警备兵" }  --防御
            },
            fatesWithContinuations = {
                { fateName="雪松原之战", continuationIsBoss=true }
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "西拉诺西亚",
        zoneId = 138,
        fatesList = {
            collectionsFates= {
                { fateName="海关的强制搜查", npcName="黄衫队陆尉" }
            },
            otherNpcFates= {
                { fateName="支援补给线", npcName="黑涡团运输兵" },
                { fateName="蔬菜革命——蔓德拉战队", npcName="希尔迪布兰德" }
            },
            fatesWithContinuations = {
                { fateName="北防波堤之战 侦察行动", continuationIsBoss=true },
                { fateName="南防波堤之战 侦察行动", continuationIsBoss=true }
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "拉诺西亚高地",
        zoneId = 139,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="不幸的佣兵——美男子布迦加", npcName="黑涡团副漩士"}
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "西萨纳兰",
        zoneId = 140,
        fatesList = {
            collectionsFates= {
                { fateName="土之核心", npcName="热心工作的工人" }
            },
            otherNpcFates= {
                { fateName="阶级愤怒的铁锤", npcName="束手无策的工人" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {
                "荒野的保镖", --呃呃，自动寻路不喜欢这样的傻逼大桥
                "护送负伤者" --护送类
            }
        },
        flying=false --别问 问就是傻缺地平关大升降梯
    },
    {
        zoneName = "中萨纳兰",
        zoneId = 141,
        fatesList = {
            collectionsFates= {
                { fateName="营养丰富的仙人掌", npcName="饥饿的少女"},
                { fateName="屈伊伯龙家的人" , npcName="无计可施的商人" }
            },
            otherNpcFates= {
                { fateName="深不见底——酒豪谷谷卢恩", npcName="金库灵柩亭的保镖" },
                { fateName="粗野的赌徒——无赖格里希尔德", npcName="失败的冒险者" },
                { fateName="杀人鱼的末日", npcName="少年克里斯"} 
            },
            fatesWithContinuations = {},
            blacklistedFates= {
                -- "守住晚饭" --地形疑似自动寻路过不去
            }
        },
        flying=false --垃圾se
    },
    {
        zoneName = "东萨纳兰",
        zoneId = 145,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="跨天桥上的死斗 市民营救战" , npcName="铜刃团卫兵" }, --前置fate失败才会出现
                { fateName="阻止敌人的侵略", npcName="恒辉队侦察兵" }
            },
            fatesWithContinuations = {
                { fateName="跨天桥上的死斗 前哨战", continuationIsBoss=false },
                { fateName="跨天桥上的死斗 守卫战", continuationIsBoss=true }, --需要前哨战成功
                -- { fateName="跨天桥上的死斗 迎击兹兹卢恩", continuationIsBoss=true }  --需要守卫战成功
            },
            specialFates = {
                "死亡的假面——黄道巨蟹"
            },
            blacklistedFates= {
                "阻止敌人的侵略" --近战只有卡住的命，而且又是鸟巢类     
            }
        }
    },
    {
        zoneName = "南萨纳兰",
        zoneId = 146,
        fatesList = {
            collectionsFates= {
                { fateName="解开真理", npcName="古代魔法研究者" }
            },
            otherNpcFates= {
                { fateName="荒野灭火", npcName="恒辉队兵卒" },
                { fateName="怒涛怪力——金刚爪奈寨德·夏", npcName="恒辉队侦察兵" }
            },
            fatesWithContinuations = {
                { fateName="无法无天——破戒者吉斯弗里德", continuationIsBoss=true },
                { fateName="沙漠之子", continuationIsBoss=false } -- 后续：沙漠皇帝——乌尔哈德希
            },
            blacklistedFates= {
                "侦察兵的工作", --护送
                "工艺神的守护者", --护送
                "猎人与猎物", --vnav无法寻路？？
                "沙漠皇帝——乌尔哈德希" --BOSS出现后打小怪没进度的，小怪无限刷

                -- BAN了不悔战阵的fate 自由飞吧
                --"蜥蜴人军特殊部队——炎牙众",
                --"速射名手——白火花哈普古·秋",
                --"第一关门攻略战",
                --"火神的召唤者——流火印阿法基·天"
            }
        },
        flying = false -- SE 加点地图飞行高度上限吧 求你了
    },
    {
        zoneName = "黑衣森林中央林区",
        zoneId = 148,
        fatesList = {
            collectionsFates= {
                { fateName="以毒攻毒", npcName="鬼哭队队员" },
                { fateName="寻求真理", npcName="不知名的法师" }
            },
            otherNpcFates= {
            },
            fatesWithContinuations = {},
            specialFates = {
                "上古斗神——奥丁" -- 2.0特殊fate！
            },
            blacklistedFates= {
                "愤怒的教官——狂人米罗东", --护送
                "谨记地母神之所忘" --窄桥…… 
            }
        }
    },
    {
        zoneName = "黑衣森林东部林区",
        zoneId = 152,
        fatesList = {
            collectionsFates= {
                { fateName="昔日之光", npcName="新叶 法纳克希奥"}
            },
            otherNpcFates= {
            },
            fatesWithContinuations = {
                { fateName="百灵啼遭遇战", continuationIsBoss=false }
            },
            specialFates = {
                "上古斗神——奥丁", -- 2.0特殊fate！
                "无情的收割者——懒惰口花劳伦斯"
            },
            blacklistedFates= {
                "祝福的佳酿" --护送
            }
        }
    },
    {
        zoneName = "黑衣森林北部林区",
        zoneId = 154,
        fatesList = {
            collectionsFates= {
                { fateName="山人的心愿", npcName="形迹可疑的开山工" }
            },
            otherNpcFates= {
            },
            fatesWithContinuations = {},
            specialFates = {
                "上古斗神——奥丁" -- 2.0特殊fate！
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "拉诺西亚外地",
        zoneId = 180,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="营救补给部队", npcName="无助的车夫" },
                { fateName="试掘地强攻", npcName="黑涡团二等漩兵" }
            },
            fatesWithContinuations = {
                -- { fateName="妖异杀手——第59团巡逻员凯伽", continuationIsBoss=true },
                -- { fateName="钢之炼金术士", continuationIsBoss=true }
                -- 隔着好远呢 当不存在吧
            },
            blacklistedFates= {
                "试掘地强攻" --SE能不能少做点打鸟巢系的fate
            }
        },
        flying = false --这个傻逼地灵族矿山 妈的SE
    },
    {
        zoneName = "库尔札斯中央高地",
        zoneId = 155,
        fatesList= {
            collectionsFates= {
                { fateName="圣人的泪水", npcName="库尔札斯的商人" },
            },
            otherNpcFates= {
                { fateName="斯瓦拉的袭击", npcName="福尔唐家的工兵" },
                { fateName="巨人谜语", npcName="福尔唐家的卫兵" },
                { fateName="力量之塔", npcName="艾因哈特家的卫兵"}
            },
            fatesWithContinuations = {
                -- { fateName="斯瓦拉的袭击", continuationIsBoss=false },
                { fateName="斯瓦拉的恐怖", continuationIsBoss=true }
            },
            specialFates = {
                "传说的魔兽——贝希摩斯",
                "受伤的魔兽——贝希摩斯",
                "归来的复仇者——史特罗佩斯"
            },
            blacklistedFates= {
                "满天星光" --护送
                --"斯瓦拉的袭击" --护送
            }
        }
    },
    {
        zoneName = "库尔札斯西部高地",
        zoneId = 397,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="年轻龙骑士——阿莱姆贝", npcName="圣菲内雅连队的骑兵" },
                { fateName="功绩掠夺者——卑鄙的维尔纳", npcName="直率的博多内" }
            },
            fatesWithContinuations = {
                { fateName="白雪茫茫", continuationIsBoss=true },
                { fateName="黑铁桥之战", continuationIsBoss=true },
                { fateName="讨伐龙之眷属", continuationIsBoss=true },
                { fateName="年轻龙骑士——阿莱姆贝", continuationIsBoss=true }
            },
            specialFates = {
                "吞噬牦牛的巨人——巨脚雪人", -- 太硬了！！！
            },
            blacklistedFates= {
                "注意冰面" --注意被栅栏挡住的你（哭）
            }
        }
    },
    {
        zoneName = "摩杜纳",
        zoneId = 156,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="昔日不在", npcName="经验丰富的冒险者" },
                { fateName="圣地巡礼", npcName="圣寇伊纳克财团的搬运工" },
                { fateName="旅伴", npcName="体型强健的调查员" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {
                "旅伴" --护送
            }
        }
    },
    {
        zoneName = "阿巴拉提亚云海",
        zoneId = 401,
        fatesList= {
            collectionsFates= {
                { fateName="天空之云", npcName="年轻的尊杜人 " } 
            },
            otherNpcFates= {
                { fateName="逃亡者", npcName="逃亡的尊杜奴隶" }, --护送
                { fateName="突飞猛进", npcName="云顶蔷薇骑兵" }
            },
            fatesWithContinuations = {
                { fateName="冠恐鸟窝破坏命令", continuationIsBoss=true },
                { fateName="云神祭司——凯那瓦努", continuationIsBoss=false },
                { fateName="凯那瓦努的弟子们", continuationIsBoss=true }
            },
            specialFates = {
                "暴食人形岩——大地饕餮" -- 很硬
            },
            blacklistedFates= {
                "冠恐鸟窝破坏命令", --打鸟巢才算有效进度，一直打渡渡鸟没用
                "逃亡者" --护送
            }
        }
    },
    {
        zoneName = "魔大陆阿济兹拉",
        zoneId = 402,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="错误报告199号", npcName="检查系统" }
            },
            fatesWithContinuations = {
                { fateName= "全自动手工业", continuationIsBoss=true }
            },
            specialFates = {
                "太古威胁 夜光花歼灭战" --3.0特殊fate
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "龙堡参天高地",
        zoneId = 398,
        fatesList= {
            collectionsFates= {
                { fateName="不灭之箭", npcName="尾羽集落的猎人" }
            },
            otherNpcFates= {
                { fateName="芳香四溢", npcName="散发醇香的莫西·匹克" }
            },
            fatesWithContinuations = {
                { fateName="敌人的敌人还是敌人", continuationIsBoss=true }
                -- { fateName="雷兽女王——长须豹女王", continuationIsBoss=true },
                -- { fateName="逆袭女王——长须豹女王", continuationIsBoss=true }
            },
            specialFates = {
                "坚甲铁龙——塔拉斯克", -- 很硬
                "雷兽女王——长须豹女王",
                "逆袭女王——长须豹女王",
                "幻影女王——长须豹女王"
            },
            blacklistedFates= {
                "鲑鱼战争" --地形原因 近战容易卡住...
            }
        }
    },
    {
        zoneName = "龙堡内陆低地",
        zoneId=399,
        tpZoneId = 478,
        fatesList= {
            collectionsFates= {
                { fateName="恶魔机器", npcName="多面玲珑 斯里克崔克斯" },
                { fateName="珍惜古书", npcName="视书如命 布罗菲克斯" }
            },
            otherNpcFates= {
                { fateName="使魔不好当", npcName="马洛·罗格" }
            },
            fatesWithContinuations = {
                -- { fateName="恶魔机器", continuationIsBoss=false },
                { fateName="复仇者们", continuationIsBoss=true },
                { fateName="哥布林纷争", continuationIsBoss=true }
            },
            specialFates = {
                "淋血暴君——天枢巨熊",
                "全面改造机——3号哥布林装甲J型"
            },
            blacklistedFates= {
                "使魔不好当" --护送
            }
        }
    },
    {
        zoneName = "翻云雾海",
        zoneId=400,
        fatesList= {
            collectionsFates= {
                { fateName="莫古力赚钱之道", npcName="追求时尚的莫古力" }
            },
            otherNpcFates= {
                { fateName="永不衰退的吸引力", npcName="滔滔不绝的莫古力" }, -- 护送
                { fateName="古恐龙再见", npcName="小顽童 莫古希" },
                { fateName="云海小顽童——莫古希", npcName="优等生 莫古珀" },
                { fateName="天极白垩宫防卫战 救助幼龙", npcName="天极幼龙" },
                { fateName="夜与雾", npcName="法亚拉" },
                { fateName="圣与邪的扭曲", npcName="天极幼龙" }
            },
            fatesWithContinuations = {
                { fateName="与龙共舞", continuationIsBoss=false },
                { fateName="火尾飞蜥大军", continuationIsBoss=false },
                { fateName="暗鳞黑龙征讨战 白龙支援" , continuationIsBoss=false }
                -- { fateName="暗鳞黑龙征讨战 追击作战" , continuationIsBoss=false }
            },
            specialFates = {
                "苍天白龙——维德佛尔尼尔" --纯纯挂机我猜也触发不了的 大概
            },
            blacklistedFates= {
                "暗鳞黑龙征讨战 白龙支援",  -- 太硬了！一个人实在打不动
                "天极白垩宫防卫战 救助莫古", --比较硬，但是有治疗战术鸟奶你的话也不是打不死
                "永不衰退的吸引力" --别护送了！
            }
        }
    },
    {
        zoneName = "基拉巴尼亚边区",
        zoneId = 612,
        fatesList= {
            collectionsFates= {
                { fateName="集中训练营 士兵之章", npcName="弗雷拉克·巴尔本辛协漩校" },
                { fateName="新石器时代", npcName="梅氏的少女" },
            },
            otherNpcFates= {
                { fateName="冥河世界", npcName="黑涡团传令员" },
                { fateName="蚁狮没有攻击性", npcName="梅氏的猎人" },
                { fateName="下个岩石继续", npcName="阿拉米格解放军战士" },
                { fateName="边境巡视员", npcName="阿拉米格解放军战士" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "基拉巴尼亚山区",
        zoneId = 620,
        fatesList= {
            collectionsFates= {
                { fateName="狮鹫物语", npcName="流浪的酒保商人" }
            },
            otherNpcFates= {
                { fateName="勇敢的蚱蜢", npcName="受伤的战士" },
                { fateName="生死关头", npcName="阿拉加纳的居民" },
                { fateName="等好久了！", npcName="寒炉村居民" },
                { fateName="血的收获", npcName="倔强的农夫" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {
                "The Magitek Is Back", --escort
                "A New Leaf" --escort
            }
        }
    },
    {
        zoneName = "基拉巴尼亚湖区",
        zoneId = 621,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            specialFates = {
                "传说中的雷马——伊克西翁" --ixion
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "红玉海",
        zoneId = 613,
        fatesList= {
            collectionsFates= {
                { fateName="Treasure Island", npcName="被打劫的碧甲族" },
                { fateName="The Coral High Ground", npcName="稳重的海盗" }
            },
            otherNpcFates= {
                { fateName="兵法修行者——一刀客千万", npcName="海贼众的少女" },
                { fateName="红甲族恣意的风筝", npcName="负伤的海盗" },
                { fateName="无礼的牛鬼——尘轮鬼", npcName="十分困扰的海盗" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "延夏",
        zoneId = 614,
        fatesList= {
            collectionsFates= {
                { fateName="稻生物怪录", npcName="束手无策的农妇" },
                { fateName="银狐的心愿", npcName="银狐" }
            },
            otherNpcFates= {
                { fateName="金狐的心愿", npcName="金狐" },
                { fateName="倒霉的鱼群", npcName="大鱼丰收 鱼群" }
            },
            specialFates = {
                "九尾妖狐——玉藻御前" --foxyyy
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "太阳神草原",
        zoneId = 622,
        fatesList= {
            collectionsFates= {
                { fateName="答塔克的旅程之挤羊奶", npcName="阿儿塔尼" }
            },
            otherNpcFates= {
                { fateName="忏悔", npcName="奥罗尼部年轻人" },
                { fateName="归家路上的放牛少女", npcName="奥儿昆德部牛倌" },
                { fateName="转瞬的噩梦", npcName="模儿部羊倌" },
                { fateName="沉默的制裁", npcName="凯苏提尔部商人" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "雷克兰德",
        zoneId = 813,
        fatesList= {
            collectionsFates= {
                { fateName="樵夫之歌", npcName="雷克兰德的樵夫" }
            },
            otherNpcFates= {
                { fateName="与紫叶团的战斗之卑鄙陷阱", npcName="像是旅行商人的男子" },
                { fateName="污秽之血", npcName="乔布要塞的卫兵" }
            },
            fatesWithContinuations = {
                "高度进化"
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "珂露西亚岛",
        zoneId = 814,
        fatesList= {
            collectionsFates= {
                { fateName="制作战士之自走人偶", npcName="图尔家族的技师" }
            },
            otherNpcFates= {},
            fatesWithContinuations = {},
            specialFates = {
                "激斗畏惧装甲之秘密武器" -- 畏惧装甲（特殊FATE）
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "安穆·艾兰",
        zoneId = 815,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {
                "托尔巴龟最棒", -- pathing is really bad to enemies
            }
        }
    },
    {
        zoneName = "伊尔美格",
        zoneId = 816,
        fatesList= {
            collectionsFates= {
                { fateName="仙子尾巴之魔物包围网", npcName="寻找花蜜的仙子" }
            },
            otherNpcFates= {
                { fateName="仙子尾巴之金黄花蜜", npcName="寻找花蜜的仙子" },
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "拉凯提卡大森林",
        zoneId = 817,
        fatesList= {
            collectionsFates= {
                { fateName="粉红鹳", npcName="夜之民导师" },
                { fateName="缅楠的巡逻之补充弓箭", npcName="散弓音 缅楠" },
                { fateName="传说诞生", npcName="法诺的看守" }
            },
            otherNpcFates= {
                { fateName="死相陆鸟——刻莱诺", npcName="法诺的猎人" },
                { fateName="吉梅与萨梅", npcName="血红枪 吉梅" },
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "黑风海",
        zoneId = 818,
        fatesList= {
            collectionsFates= {
                { fateName="灾厄的古塔尼亚之收集红血珊瑚", npcName="提乌嘶·澳恩" },
                { fateName="珍珠永恒", npcName="鳍人族捕鱼人" }
            },
            otherNpcFates= {
                { fateName="灾厄的古塔尼亚之开始追踪", npcName="提乌嘶·澳恩" },
                { fateName="灾厄的古塔尼亚之兹姆嘶登场", npcName="提乌嘶·澳恩" },
                { fateName="灾厄的古塔尼亚之保护提乌嘶", npcName="提乌嘶·澳恩" },
            },
            fatesWithContinuations = {},
            specialFates = {
                "灾厄的古塔尼亚之深海讨伐战" --archaeotania
            },
            blacklistedFates= {
                "灾厄的古塔尼亚之护卫提乌嘶", -- escort fate
                "贝汁物语", -- escort fate
            }
        }
    },
    {
        zoneName = "迷津",
        zoneId = 956,
        fatesList= {
            collectionsFates= {
                { fateName="迷津风玫瑰", npcName="束手无策的研究员" },
                { fateName="纯天然保湿护肤品", npcName="皮肤很好的研究员" }
            },
            otherNpcFates= {
                { fateName="牧羊人的日常", npcName="种畜研究所的驯兽人" } --24 タワーディフェンス
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "萨维奈岛",
        zoneId = 957,
        fatesList= {
            collectionsFates= {
                { fateName="芳香的炼金术士：危险的芬芳", npcName="调香师 萨加巴缇" }
            },
            otherNpcFates= {
               { fateName="猴子军团", npcName="采草药的女孩" },
               { fateName="少年与海", npcName="渔夫的儿子" } --24 防御
            },
            fatesWithContinuations = {},
            specialFates = {
                "兽道诸神信仰：伪神降临" -- 兽道神明灯天王（特殊FATE）
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "加雷马",
        zoneId = 958,
        fatesList= {
            collectionsFates= {
                { fateName="资源回收分秒必争", npcName="沦为难民的魔导技师" }
            },
            otherNpcFates= {
                { fateName="魔导技师的归乡之旅：启程", npcName="柯尔特隆纳协漩尉" }, --22 boss
                { fateName="魔导技师的归乡之旅：落入陷阱", npcName="埃布雷尔诺" }, --24 防御
                { fateName="魔导技师的归乡之旅：实弹射击", npcName="柯尔特隆纳协漩尉" }, --23 一般
                { fateName="雪原的巨魔", npcName="幸存的难民" } --24 防御
            },
            fatesWithContinuations = {
                { fateName="魔导技师的归乡之旅：指挥机梅塔特隆", continuationIsBoss=true }
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "叹息海",
        zoneId = 959,
        fatesList= {
            collectionsFates= {
                { fateName="如何追求兔生刺激", npcName="担惊威" }
            },
            otherNpcFates= {
                { fateName="叹息的白兔之轰隆隆大爆炸", npcName="战兵威" }, --24 タワーディフェンス
                { fateName="叹息的白兔之乱糟糟大失控", npcName="落名威" }, --23 通常
                { fateName="叹息的白兔之怒冲冲大处理", npcName="落名威" } --22 ボス
            },
            fatesWithContinuations = {},
            blacklistedFates= {
                "跨海而来的老饕", --由于斜坡上视野不佳，可能什么都做不了就呆站着
            }
        }
    },
    {
        zoneName = "天外天垓",
        zoneId = 960,
        fatesList= {
            collectionsFates= {
                { fateName="侵略兵器召回指令：扩建通信设备", npcName="N-6205" }
            },
            otherNpcFates= {
                { fateName="荣光之翼——阿尔·艾因", npcName="阿尔·艾因的朋友" }, --22 boss
                { fateName="侵略兵器召回指令：保护N-6205", npcName="N-6205"}, --24 防御
                { fateName="走向永恒的结局", npcName="米克·涅尔" } --24 防御
            },
            fatesWithContinuations = {},
            specialFates = {
                "侵略兵器召回指令：破坏侵略兵器希" -- 希（特殊FATE）
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "厄尔庇斯",
        zoneId = 961,
        fatesList= {
            collectionsFates= {
                { fateName="望请索克勒斯先生谅解", npcName="负责植物的观察者" }
            },
            otherNpcFates= {
                { fateName="创造计划：过于新颖的理念", npcName="神秘莫测 莫勒图斯" }, --23 一般
                { fateName="创造计划：伊娥观察任务", npcName="神秘莫测 莫勒图斯" }, --23 一般
                { fateName="告死鸟", npcName="一角兽的观察者" }, --24 防御
            },
            fatesWithContinuations = {
                { fateName="创造计划：过于新颖的理念", continuationIsBoss=true },
                { fateName="创造计划：伊娥观察任务", continuationIsBoss=true }
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "奥阔帕恰山",
        zoneId = 1187,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="牧场关门", npcName="健步如飞 基维利" }, --23 一般
                { fateName="跃动的火热——山火", npcName="健步如飞 基维利" }, --22 boss
                { fateName="不死之人", npcName="扫墓的尤卡巨人" }, --23 一般
                { fateName="失落的山顶都城", npcName="守护遗迹的尤卡巨人" }, --24 防御
                { fateName="咖啡豆岌岌可危", npcName="咖啡农园的工作人员" }, --24 防御
                { fateName="千年孤独", npcName="其瓦固佩刀者" }, --23 一般
                { fateName="飞天魔厨——佩鲁的天敌", npcName="佩鲁佩鲁的旅行商人" }, --22 boss
                { fateName="狼之家族", npcName="佩鲁佩鲁族旅行商人" }  --23 一般
            },
            fatesWithContinuations = {
                { fateName="不死之人", continuationIsBoss=true },
                { fateName="千年孤独", continuationIsBoss=true }
            },
            blacklistedFates= {
                "只有爆炸", -- 不知道为什么过不去
                "狼之家族", -- 由于同一地点有多个同名NPC存在
                "飞天魔厨——佩鲁的天敌", -- 由于同一地点有多个同名NPC存在
                "跃动的火热——山火", -- 会抽搐
                -- "黑水" -- 魔界花恐怖如斯
            }
        }
    },
    {
        zoneName="克扎玛乌卡湿地",
        zoneId=1188,
        fatesList={
            collectionsFates={
                { fateName="密林淘金", npcName="莫布林族采集者" },
                { fateName="巧若天工", npcName="哈努族手艺人" },
                
            },
            otherNpcFates= {
                { fateName="怪力大肚王——非凡飔戮龙", npcName="哈努族捕鱼人" }, --22 boss
                { fateName="芦苇荡的时光", npcName="哈努族农夫" }, --23 一般
                { fateName="贡品小偷", npcName="哈努族巫女" }, --24 防御
                { fateName="横征暴敛？", npcName="佩鲁佩鲁族商人" }, --24 防御
                { fateName="美丽菇世界", npcName="贴心巧匠 巴诺布罗坷" }  --23 一般
            },
            fatesWithContinuations = {
                { fateName="美丽菇世界", continuationIsBoss=true }
            },
            blacklistedFates= {
                "横征暴敛？" -- 由于同一地点有多个同名NPC存在vnav
            }
        }
    },
    {
        zoneName="亚克特尔树海",
        zoneId=1189,
        fatesList= {
            collectionsFates= {
                { fateName="逃离恐怖菇", npcName="霍比格族采集者" }
            },
            otherNpcFates= {
                { fateName="顶击大貒猪", npcName="灵豹之民猎人" }, --23 一般
                { fateName="血染利爪——米尤鲁尔", npcName="灵豹之民猎人" }, --22 boss
                { fateName="致命螳螂", npcName="灵豹之民猎人" }, --23 一般
                { fateName="辉鳞族不法之徒袭击事件", npcName="朵普罗族枪手" }, --23 一般
                { fateName="守护秘药之战", npcName="霍比格族运货人" }  --24 防御
            },
            fatesWithContinuations = {
                { fateName="顶击大貒猪", continuationIsBoss=false },
                { fateName="辉鳞族不法之徒袭击事件", continuationIsBoss=true }
            },
            blacklistedFates= {
                "顶击大貒猪", -- 由于同一地点有多个同名NPC存在
                "血染利爪——米尤鲁尔", -- 由于同一地点有多个同名NPC存在
                "致命螳螂" -- 由于同一地点有多个同名NPC存在
            }
        }
    },
    {
        zoneName="夏劳尼荒野",
        zoneId=1190,
        fatesList= {
            collectionsFates= {
                { fateName="剃毛时间", npcName="迎曦之民采集者" },
                { fateName="蛇王得酷热涅：狩猎前的准备", npcName="夕阳尚红 布鲁克·瓦" }
            },
            otherNpcFates= {
                { fateName="死而复生的恶棍——阴魂不散 扎特夸", npcName="迎曦之民劳动者" }, --22 boss
                { fateName="不甘的冲锋者——灰达奇", npcName="崇灵之民男性" }, --22 boss
                { fateName="和牛一起旅行", npcName="崇灵之民女性" }, --23 一般
                { fateName="大湖之恋", npcName="崇灵之民渔夫" }, --24 防御
                { fateName="神秘翼龙荒野奇谈", npcName="佩鲁佩鲁族旅行商人" }  --23 一般
            },
            fatesWithContinuations = {
                { fateName="蛇王得酷热涅：狩猎的杀手锏", continuationIsBoss=false }
            },
            specialFates = {
                "蛇王得酷热涅：荒野的死斗" -- 得酷热涅（特殊FATE）
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName="遗产之地",
        zoneId=1191,
        fatesList= {
            collectionsFates= {
                { fateName="药师的工作", npcName="迎曦之民栽培者" },
                { fateName="亮闪闪的可回收资源", npcName="英姿飒爽的再造者" }
            },
            otherNpcFates= {
                { fateName="机械迷城", npcName="初出茅庐的狩猎者" }, --23 一般
                { fateName="你来我往", npcName="初出茅庐的狩猎者" }, --23 一般
                { fateName="剥皮行者", npcName="陷入危机的狩猎者" }, --23 一般
                { fateName="机械公敌", npcName="走投无路的再造者" }, --23 一般
                { fateName="铭刻于灵魂中的恐惧", npcName="终流地的再造者" }, --23 一般
                { fateName="前路多茫然", npcName="害怕的运送者" }  --23 一般
            },
            fatesWithContinuations = {
                { fateName="机械公敌", continuationIsBoss=false }
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName="活着的记忆",
        zoneId=1192,
        fatesList= {
            collectionsFates= {
                { fateName="良种难求", npcName="无失哨兵GX" },
                { fateName="记忆的碎片", npcName="无失哨兵GX" }
            },
            otherNpcFates= {
                { fateName="为了运河镇的安宁", npcName="无失哨兵GX" }, --24 防御
                { fateName="亩鼠米卡：盛装巡游开始", npcName="滑稽巡游主宰" }  --23 一般
            },
            fatesWithContinuations =
            {
                { fateName="水城噩梦", continuationIsBoss=true },
                { fateName="亩鼠米卡：盛装巡游开始", continuationIsBoss=true }
            },
            specialFates =
            {
                "亩鼠米卡：盛装巡游皆大欢喜"
            },
            blacklistedFates= {
            }
        }
    }
}

--#endregion Data

--#region Fate Functions
function IsCollectionsFate(fateName)
    for i, collectionsFate in ipairs(SelectedZone.fatesList.collectionsFates) do
        if collectionsFate.fateName == fateName then
            return true
        end
    end
    return false
end

function IsBossFate(fateId)
    local fateIcon = GetFateIconId(fateId)
    return fateIcon == 60722
end

function IsOtherNpcFate(fateName)
    for i, otherNpcFate in ipairs(SelectedZone.fatesList.otherNpcFates) do
        if otherNpcFate.fateName == fateName then
            return true
        end
    end
    return false
end

function IsSpecialFate(fateName)
    if SelectedZone.fatesList.specialFates == nil then
        return false
    end
    for i, specialFate in ipairs(SelectedZone.fatesList.specialFates) do
        if specialFate == fateName then
            return true
        end
    end
end

function IsBlacklistedFate(fateName)
    for i, blacklistedFate in ipairs(SelectedZone.fatesList.blacklistedFates) do
        if blacklistedFate == fateName then
            return true
        end
    end
    if not JoinCollectionsFates then
        for i, collectionsFate in ipairs(SelectedZone.fatesList.collectionsFates) do
            if collectionsFate.fateName == fateName then
                return true
            end
        end
    end
    return false
end

function GetFateNpcName(fateName)
    for i, fate in ipairs(SelectedZone.fatesList.otherNpcFates) do
        if fate.fateName == fateName then
            return fate.npcName
        end
    end
    for i, fate in ipairs(SelectedZone.fatesList.collectionsFates) do
        if fate.fateName == fateName then
            return fate.npcName
        end
    end
end

function IsFateActive(fateId)
    local activeFates = GetActiveFates()
    for i = 0, activeFates.Count-1 do
        if fateId == activeFates[i] then
            return true
        end
    end
    return false
end

function EorzeaTimeToUnixTime(eorzeaTime)
    return eorzeaTime/(144/7) -- 24h Eorzea Time equals 70min IRL
end

function SelectNextZone()
    local nextZone = nil
    local nextZoneId = GetZoneID()

    for i, zone in ipairs(FatesData) do
        if nextZoneId == zone.zoneId then
            nextZone = zone
        end
    end
    if nextZone == nil then
        yield("/echo [FATE] 当前区域仅部分支持。没有关于NPC Fate的数据。")
        nextZone = {
            zoneName = "",
            zoneId = nextZoneId,
            fatesList= {
                collectionsFates= {},
                otherNpcFates= {},
                bossFates= {},
                blacklistedFates= {},
                fatesWithContinuations = {}
            }
        }
    end

    nextZone.zoneName = nextZone.zoneName
    nextZone.aetheryteList = {}
    local aetheryteIds = GetAetherytesInZone(nextZone.zoneId)
    for i=0, aetheryteIds.Count-1 do
        local aetherytePos = GetAetheryteRawPos(aetheryteIds[i])
        local aetheryteTable = {
            aetheryteName = GetAetheryteName(aetheryteIds[i]),
            aetheryteId = aetheryteIds[i],
            x = aetherytePos.Item1,
            y = QueryMeshPointOnFloorY(aetherytePos.Item1, 1024, aetherytePos.Item2, true, 50),
            z = aetherytePos.Item2
        }
        table.insert(nextZone.aetheryteList, aetheryteTable)
    end

    if nextZone.flying == nil then
        nextZone.flying = true
    end

    return nextZone
end

--[[
    根据 FatePriority 中定义的优先级顺序选择更好的 FATE。
    默认优先级顺序为 "Progress" -> "DistanceTeleport" -> "Bonus" -> "TimeLeft" -> "Distance"
]]
function SelectNextFateHelper(tempFate, nextFate)
    -- 检查 WaitForBonusIfBonusBuff 是否为 true，并且是否有任意一个 buff，如果是，则将 BonusFatesOnlyTemp 设置为 true
    if BonusFatesOnly then
        if not tempFate.isBonusFate and nextFate ~= nil and nextFate.isBonusFate then
            return nextFate
        elseif tempFate.isBonusFate and (nextFate == nil or not nextFate.isBonusFate) then
            return tempFate
        elseif not tempFate.isBonusFate and (nextFate == nil or not nextFate.isBonusFate) then
            return nil
        end
        -- 如果两个都是奖励FATE，则通过常规的FATE选择流程
    end

    if tempFate.timeLeft < MinTimeLeftToIgnoreFate or tempFate.progress > CompletionToIgnoreFate then
        LogInfo("[FATE] Ignoring fate #"..tempFate.fateId.." due to insufficient time or high completion.")
        return nextFate
    elseif nextFate == nil then
        LogInfo("[FATE] Selecting #"..tempFate.fateId.." because no other options so far.")
        return tempFate
    elseif nextFate.timeLeft < MinTimeLeftToIgnoreFate or nextFate.progress > CompletionToIgnoreFate then
        LogInfo("[FATE] Ignoring fate #"..nextFate.fateId.." due to insufficient time or high completion.")
        return tempFate
    end

    -- 根据优先级进行评估（遍历列表，返回第一个不相等的优先级）
    for _, criteria in ipairs(FatePriority) do
        if criteria == "Progress" then
            LogInfo("[FATE] Comparing progress: "..tempFate.progress.." vs "..nextFate.progress)
            if tempFate.progress > nextFate.progress then return tempFate end
            if tempFate.progress < nextFate.progress then return nextFate end
        elseif criteria == "Bonus" then
            LogInfo("[FATE] Checking bonus status: "..tostring(tempFate.isBonusFate).." vs "..tostring(nextFate.isBonusFate))
            if tempFate.isBonusFate and not nextFate.isBonusFate then return tempFate end
            if nextFate.isBonusFate and not tempFate.isBonusFate then return nextFate end
        elseif criteria == "TimeLeft" then
            LogInfo("[FATE] Comparing time left: "..tempFate.timeLeft.." vs "..nextFate.timeLeft)
            if tempFate.timeLeft > nextFate.timeLeft then return tempFate end
            if tempFate.timeLeft < nextFate.timeLeft then return nextFate end
        elseif criteria == "Distance" then
            local tempDist = GetDistanceToPoint(tempFate.x, tempFate.y, tempFate.z)
            local nextDist = GetDistanceToPoint(nextFate.x, nextFate.y, nextFate.z)
            LogInfo("[FATE] Comparing distance: "..tempDist.." vs "..nextDist)
            if tempDist < nextDist then return tempFate end
            if tempDist > nextDist then return nextFate end
        elseif criteria == "DistanceTeleport" then
            local tempDist = GetDistanceToPointWithAetheryteTravel(tempFate.x, tempFate.y, tempFate.z)
            local nextDist = GetDistanceToPointWithAetheryteTravel(nextFate.x, nextFate.y, nextFate.z)
            LogInfo("[FATE] Comparing distance: "..tempDist.." vs "..nextDist)
            if tempDist < nextDist then return tempFate end
            if tempDist > nextDist then return nextFate end
        end
    end

    -- Fallback: Select fate with the lower ID
    LogInfo("[FATE] Selecting lower ID fate: "..tempFate.fateId.." vs "..nextFate.fateId)
    return (tempFate.fateId < nextFate.fateId) and tempFate or nextFate
end

function BuildFateTable(fateId)
    local fateTable = {
        fateId = fateId,
        fateName = GetFateName(fateId),
        progress = GetFateProgress(fateId),
        duration = GetFateDuration(fateId),
        startTime = GetFateStartTimeEpoch(fateId),
        x = GetFateLocationX(fateId),
        y = GetFateLocationY(fateId),
        z = GetFateLocationZ(fateId),
        isBonusFate = GetFateIsBonus(fateId),
    }
    fateTable.npcName = GetFateNpcName(fateTable.fateName)

    local currentTime = EorzeaTimeToUnixTime(GetCurrentEorzeaTimestamp())
    if fateTable.startTime == 0 then
        fateTable.timeLeft = 900
    else
        fateTable.timeElapsed = currentTime - fateTable.startTime
        fateTable.timeLeft = fateTable.duration - fateTable.timeElapsed
    end

    fateTable.isCollectionsFate = IsCollectionsFate(fateTable.fateName)
    fateTable.isBossFate = IsBossFate(fateTable.fateId)
    fateTable.isOtherNpcFate = IsOtherNpcFate(fateTable.fateName)
    fateTable.isSpecialFate = IsSpecialFate(fateTable.fateName)
    fateTable.isBlacklistedFate = IsBlacklistedFate(fateTable.fateName)

    fateTable.continuationIsBoss = false
    fateTable.hasContinuation = false
    for _, continuationFate in ipairs(SelectedZone.fatesList.fatesWithContinuations) do
        if fateTable.fateName == continuationFate.fateName then
            fateTable.hasContinuation = true
            fateTable.continuationIsBoss = continuationFate.continuationIsBoss
        end
    end

    return fateTable
end

--Gets the Location of the next Fate. Prioritizes anything with progress above 0, then by shortest time left
function SelectNextFate()
    local fates = GetActiveFates()
    if fates == nil then
        return
    end

    local nextFate = nil
    for i = 0, fates.Count-1 do
        local tempFate = BuildFateTable(fates[i])
        LogInfo("[FATE] Considering fate #"..tempFate.fateId.." "..tempFate.fateName)
        LogInfo("[FATE] Time left on fate #:"..tempFate.fateId..": "..math.floor(tempFate.timeLeft//60).."min, "..math.floor(tempFate.timeLeft%60).."s")
        
        if not (tempFate.x == 0 and tempFate.z == 0) then -- sometimes game doesn't send the correct coords
            if not tempFate.isBlacklistedFate then -- check fate is not blacklisted for any reason
                if tempFate.isBossFate then
                    if (tempFate.isSpecialFate and tempFate.progress >= CompletionToJoinSpecialBossFates) or
                        (not tempFate.isSpecialFate and tempFate.progress >= CompletionToJoinBossFate) then
                        nextFate = SelectNextFateHelper(tempFate, nextFate)
                    else
                        LogInfo("[FATE] Skipping fate #"..tempFate.fateId.." "..tempFate.fateName.." due to boss fate with not enough progress.")
                    end
                elseif (tempFate.isOtherNpcFate or tempFate.isCollectionsFate) and tempFate.startTime == 0 then
                    if nextFate == nil then -- pick this if there's nothing else
                        nextFate = tempFate
                    elseif tempFate.isBonusFate then
                        nextFate = SelectNextFateHelper(tempFate, nextFate)
                    elseif nextFate.startTime == 0 then -- both fates are unopened npc fates
                        nextFate = SelectNextFateHelper(tempFate, nextFate)
                    end
                elseif tempFate.duration ~= 0 then -- else is normal fate. avoid unlisted talk to npc fates
                    nextFate = SelectNextFateHelper(tempFate, nextFate)
                end
                LogInfo("[FATE] Finished considering fate #"..tempFate.fateId.." "..tempFate.fateName)
            else
                LogInfo("[FATE] Skipping fate #"..tempFate.fateId.." "..tempFate.fateName.." due to blacklist.")
            end
        end
    end

    LogInfo("[FATE] Finished considering all fates")

    if nextFate == nil then
        LogInfo("[FATE] 没有找到合适的FATE")
        if Echo == "All" then
            yield("/echo [FATE] 没有找到合适的FATE")
        end
    else
        LogInfo("[FATE] Final selected fate #"..nextFate.fateId.." "..nextFate.fateName)
    end
    yield("/wait 0.211")

    return nextFate
end

function RandomAdjustCoordinates(x, y, z, maxDistance)
    local angle = math.random() * 2 * math.pi
    local x_adjust = maxDistance * math.random()
    local z_adjust = maxDistance * math.random()

    local randomX = x + (x_adjust * math.cos(angle))
    local randomY = y + maxDistance
    local randomZ = z + (z_adjust * math.sin(angle))

    return randomX, randomY, randomZ
end

--#endregion Fate Functions

--#region Movement Functions

function DistanceFromClosestAetheryteToPoint(x, y, z, teleportTimePenalty)
    local closestAetheryte = nil
    local closestTravelDistance = math.maxinteger
    for _, aetheryte in ipairs(SelectedZone.aetheryteList) do
        local distanceAetheryteToFate = DistanceBetween(aetheryte.x, y, aetheryte.z, x, y, z)
        local comparisonDistance = distanceAetheryteToFate + teleportTimePenalty
        LogInfo("[FATE] Distance via "..aetheryte.aetheryteName.." adjusted for tp penalty is "..tostring(comparisonDistance))

        if comparisonDistance < closestTravelDistance then
            LogInfo("[FATE] Updating closest aetheryte to "..aetheryte.aetheryteName)
            closestTravelDistance = comparisonDistance
            closestAetheryte = aetheryte
        end
    end

    return closestTravelDistance
end

function GetDistanceToPointWithAetheryteTravel(x, y, z)
    -- Get the direct flight distance (no aetheryte)
    local directFlightDistance = GetDistanceToPoint(x, y, z)
    LogInfo("[FATE] Direct flight distance is: " .. directFlightDistance)
    
    -- Get the distance to the closest aetheryte, including teleportation penalty
    local distanceToAetheryte = DistanceFromClosestAetheryteToPoint(x, y, z, 200)
    LogInfo("[FATE] Distance via closest Aetheryte is: " .. (distanceToAetheryte or "nil"))

    -- Return the minimum distance, either via direct flight or via the closest aetheryte travel
    if distanceToAetheryte == nil then
        return directFlightDistance
    else
        return math.min(directFlightDistance, distanceToAetheryte)
    end
end

function GetClosestAetheryte(x, y, z, teleportTimePenalty)
    local closestAetheryte = nil
    local closestTravelDistance = math.maxinteger
    for _, aetheryte in ipairs(SelectedZone.aetheryteList) do
        local distanceAetheryteToFate = DistanceBetween(aetheryte.x, y, aetheryte.z, x, y, z)
        local comparisonDistance = distanceAetheryteToFate + teleportTimePenalty
        LogInfo("[FATE] Distance via "..aetheryte.aetheryteName.." adjusted for tp penalty is "..tostring(comparisonDistance))

        if comparisonDistance < closestTravelDistance then
            LogInfo("[FATE] Updating closest aetheryte to "..aetheryte.aetheryteName)
            closestTravelDistance = comparisonDistance
            closestAetheryte = aetheryte
        end
    end

    return closestAetheryte
end

function GetClosestAetheryteToPoint(x, y, z, teleportTimePenalty)
    local directFlightDistance = GetDistanceToPoint(x, y, z)
    LogInfo("[FATE] Direct flight distance is: "..directFlightDistance)
    local closestAetheryte = GetClosestAetheryte(x, y, z, teleportTimePenalty)
    if closestAetheryte ~= nil then
        local aetheryteY = QueryMeshPointOnFloorY(closestAetheryte.x, y, closestAetheryte.z, true, 50)
        if aetheryteY == nil then
            aetheryteY = GetPlayerRawYPos()
        end
        local closestAetheryteDistance = DistanceBetween(x, y, z, closestAetheryte.x, aetheryteY, closestAetheryte.z) + teleportTimePenalty

        if closestAetheryteDistance < directFlightDistance then
            return closestAetheryte
        end
    end
    return nil
end

function TeleportToClosestAetheryteToFate(nextFate)
    local aetheryteForClosestFate = GetClosestAetheryteToPoint(nextFate.x, nextFate.y, nextFate.z, 200)
    if aetheryteForClosestFate ~=nil then
        TeleportTo(aetheryteForClosestFate.aetheryteName)
        return true
    end
    return false
end

function AcceptTeleportOfferLocation(destinationAetheryte)
    if IsAddonVisible("_NotificationTelepo") then
        local location = GetNodeText("_NotificationTelepo", 3, 4)
        yield("/callback _Notification true 0 16 "..location)
        yield("/wait 1")
    end

    if IsAddonVisible("SelectYesno") then
        local teleportOfferMessage = GetNodeText("SelectYesno", 15)
        if type(teleportOfferMessage) == "string" then
            local teleportOfferLocation = teleportOfferMessage:match("要接受前往“(.+)”的传送邀请吗%?")
            if teleportOfferLocation ~= nil then
                if string.lower(teleportOfferLocation) == string.lower(destinationAetheryte) then
                    yield("/callback SelectYesno true 0") -- accept teleport
                    return
                else
                    LogInfo("Offer for "..teleportOfferLocation.." and destination "..destinationAetheryte.." are not the same. Declining teleport.")
                end
            end
            yield("/callback SelectYesno true 2") -- decline teleport
            return
        end
    end
end

function AcceptNPCFateOrRejectOtherYesno()
    if IsAddonVisible("SelectYesno") then
        local dialogBox = GetNodeText("SelectYesno", 15)
        if type(dialogBox) == "string" and dialogBox:find("此危命任务的推荐等级为") then
            yield("/callback SelectYesno true 0") --accept fate
        else
            yield("/callback SelectYesno true 1") --decline all other boxes
        end
    end
end

function TeleportTo(aetheryteName)
    AcceptTeleportOfferLocation(aetheryteName)

    while EorzeaTimeToUnixTime(GetCurrentEorzeaTimestamp()) - LastTeleportTimeStamp < 5 do
        LogInfo("[FATE] Too soon since last teleport. Waiting...")
        yield("/wait 5.001")
    end

    yield("/tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin
    while GetCharacterCondition(CharacterCondition.casting) do
        LogInfo("[FATE] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        LogInfo("[FATE] Teleporting...")
        yield("/wait 1")
    end
    yield("/wait 1")
    LastTeleportTimeStamp = EorzeaTimeToUnixTime(GetCurrentEorzeaTimestamp())
end

function ChangeInstance()
    if SuccessiveInstanceChanges >= NumberOfInstances then
        if CompanionScriptMode then
            local shouldWaitForBonusBuff = WaitIfBonusBuff and (HasStatusId(1288) or HasStatusId(1289))
            if WaitingForFateRewards == 0 and not shouldWaitForBonusBuff then
                StopScript = true
            else
                LogInfo("[Fate Farming] 正在等待团辅或Fate结算")
                yield("/wait 3")
            end
        else
            yield("/wait 10")
            SuccessiveInstanceChanges = 0
        end
        return
    end

    yield("/target 以太之光") -- search for nearby aetheryte
    if not HasTarget() or GetTargetName() ~= "以太之光" then -- if no aetheryte within targeting range, teleport to it
        LogInfo("[FATE] Aetheryte not within targetable range")
        local closestAetheryte = nil
        local closestAetheryteDistance = math.maxinteger
        for i, aetheryte in ipairs(SelectedZone.aetheryteList) do
            -- GetDistanceToPoint is implemented with raw distance instead of distance squared
            local distanceToAetheryte = GetDistanceToPoint(aetheryte.x, aetheryte.y, aetheryte.z)
            if distanceToAetheryte < closestAetheryteDistance then
                closestAetheryte = aetheryte
                closestAetheryteDistance = distanceToAetheryte
            end
        end
        TeleportTo(closestAetheryte.aetheryteName)
        return
    end

    if WaitingForFateRewards ~= 0 then
        yield("/wait 10")
        return
    end

    if GetDistanceToTarget() > 10 then
        LogInfo("[FATE] Targeting aetheryte, but greater than 10 distance")
        if GetDistanceToTarget() > 20 and not GetCharacterCondition(CharacterCondition.mounted) then
            State = CharacterState.mounting
            LogInfo("[FATE] 状态变更: Mounting")
        elseif not (PathfindInProgress() or PathIsRunning()) then
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
        end
        return
    end

    LogInfo("[FATE] Within 10 distance")
    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
        return
    end

    if GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.changeInstanceDismount
        LogInfo("[FATE] 状态变更: ChangeInstanceDismount")
        return
    end

    LogInfo("[FATE] Transferring to next instance")
    local nextInstance = (GetZoneInstance() % 2) + 1
    yield("/li "..nextInstance) -- start instance transfer
    yield("/wait 1") -- wait for instance transfer to register
    State = CharacterState.ready
    SuccessiveInstanceChanges = SuccessiveInstanceChanges + 1
    LogInfo("[FATE] 状态变更: Ready")
end

function WaitForContinuation()
    if IsInFate() then
        LogInfo("WaitForContinuation IsInFate")
        local nextFateId = GetNearestFate()
        if nextFateId ~= CurrentFate.fateId then
            CurrentFate = BuildFateTable(nextFateId)
            State = CharacterState.doFate
            LogInfo("[FATE] 状态变更: DoFate")
        end
    elseif os.clock() - LastFateEndTime > 30 then
        LogInfo("WaitForContinuation Abort")
        LogInfo("Over 30s since end of last fate. Giving up on part 2.")
        TurnOffCombatMods()
        State = CharacterState.ready
        LogInfo("State Change: Ready")
    else
        LogInfo("WaitForContinuation Else")
        if BossFatesClass ~= nil then
            local currentClass = GetClassJobId()
            LogInfo("WaitForContinuation "..CurrentFate.fateName)
            if not IsPlayerOccupied() then
                if CurrentFate.continuationIsBoss and currentClass ~= BossFatesClass.classId then
                    LogInfo("WaitForContinuation SwitchToBoss")
                    yield("/gs change "..BossFatesClass.className)
                elseif not CurrentFate.continuationIsBoss and currentClass ~= MainClass.classId then
                    LogInfo("WaitForContinuation SwitchToMain")
                    yield("/gs change "..MainClass.className)
                end
            end
        end

        yield("/wait 1")
    end
end

function FlyBackToAetheryte()
    NextFate = SelectNextFate()
    if NextFate ~= nil then
        yield("/vnav stop")
        State = CharacterState.ready
        LogInfo("[FATE] 状态变更: 就绪")
        return
    end

    local x = GetPlayerRawXPos()
    local y = GetPlayerRawYPos()
    local z = GetPlayerRawZPos()
    local closestAetheryte = GetClosestAetheryte(x, y, z, 0)
    -- 如果在飞行回程过程中遇到高度限制错误，则直接传送回最近的以太之光
    if IsAddonVisible("_TextError") and GetNodeText("_TextError", 1) == "抵达高度上限，无法继续提升高度。" then
        yield("/vnav stop")
        TeleportTo(closestAetheryte.aetheryteName)
        return
    end

    yield("/target 以太之光")

    if HasTarget() and GetTargetName() == "以太之光" and DistanceBetween(GetTargetRawXPos(), y, GetTargetRawZPos(), x, y, z) <= 20 then
        if PathfindInProgress() or PathIsRunning() then
            yield("/vnav stop")
        end

        if GetCharacterCondition(CharacterCondition.flying) then
            yield("/ac 跳下")  -- 降落但不是真正下坐骑，以避免触发陆行鸟计时器
        elseif GetCharacterCondition(CharacterCondition.mounted) then
            State = CharacterState.ready
            LogInfo("[FATE] 状态变更: Ready")
        else
            if MountToUse == "随机坐骑" then
                yield('/gaction 随机坐骑')
            else
                yield('/mount "' .. MountToUse)
            end
        end
        return
    end

    if not GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.mounting
        LogInfo("[FATE] 状态变更: Mounting")
        return
    end

    if not (PathfindInProgress() or PathIsRunning()) then
        LogInfo("[FATE] ClosestAetheryte.y: " .. closestAetheryte.y)
        if closestAetheryte ~= nil then
            SetMapFlag(SelectedZone.zoneId, closestAetheryte.x, closestAetheryte.y, closestAetheryte.z)
            PathfindAndMoveTo(closestAetheryte.x, closestAetheryte.y, closestAetheryte.z, GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
        end
    end
end

function Mount()
    if GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.moveToFate
        LogInfo("[FATE] 状态变更: MoveToFate")
    else
        if MountToUse == "随机坐骑" then
            yield('/gaction 随机坐骑')
        else
            yield('/mount "' .. MountToUse)
        end
    end
    yield("/wait 1")
end

function Dismount()
    if GetCharacterCondition(CharacterCondition.flying) then
        yield('/ac 跳下')

        local now = os.clock()
        if now - LastStuckCheckTime > 1 then
            local x = GetPlayerRawXPos()
            local y = GetPlayerRawYPos()
            local z = GetPlayerRawZPos()

            if GetCharacterCondition(CharacterCondition.flying) and GetDistanceToPoint(LastStuckCheckPosition.x, LastStuckCheckPosition.y, LastStuckCheckPosition.z) < 2 then
                LogInfo("[FATE] 无法在此处下坐骑。移动到另一个位置。")
                local random_x, random_y, random_z = RandomAdjustCoordinates(x, y, z, 10)
                local nearestPointX = QueryMeshNearestPointX(random_x, random_y, random_z, 100, 100)
                local nearestPointY = QueryMeshNearestPointY(random_x, random_y, random_z, 100, 100)
                local nearestPointZ = QueryMeshNearestPointZ(random_x, random_y, random_z, 100, 100)
                if nearestPointX ~= nil and nearestPointY ~= nil and nearestPointZ ~= nil then
                    PathfindAndMoveTo(nearestPointX, nearestPointY, nearestPointZ, GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
                    yield("/wait 1")
                end
            end

            LastStuckCheckTime = now
            LastStuckCheckPosition = {x=x, y=y, z=z}
        end
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        yield('/ac 跳下')
    end
end

function MiddleOfFateDismount()
    if not IsFateActive(CurrentFate.fateId) then
        State = CharacterState.ready
        LogInfo("[FATE] 状态变更: Ready")
        return
    end

    if HasTarget() then
        if DistanceBetween(GetPlayerRawXPos(), 0, GetPlayerRawZPos(), GetTargetRawXPos(), 0, GetTargetRawZPos()) > (MaxDistance + GetTargetHitboxRadius() + 5) then
            if not (PathfindInProgress() or PathIsRunning()) then
                LogInfo("[FATE] MiddleOfFateDismount PathfindAndMoveTo")
                PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), GetCharacterCondition(CharacterCondition.flying))
            end
        else
            if GetCharacterCondition(CharacterCondition.mounted) then
                LogInfo("[FATE] MiddleOfFateDismount Dismount()")
                Dismount()
            else
                yield("/vnav stop")
                State = CharacterState.doFate
                LogInfo("[FATE] 状态变更: DoFate")
            end
        end
    else
        TargetClosestFateEnemy()
    end
end

function NPCDismount()
    if GetCharacterCondition(CharacterCondition.mounted) then
        Dismount()
    else
        State = CharacterState.interactWithNpc
        LogInfo("[FATE] 状态变更: InteractWithFateNpc")
    end
end

function ChangeInstanceDismount()
    if GetCharacterCondition(CharacterCondition.mounted) then
        Dismount()
    else
        State = CharacterState.changingInstances
        LogInfo("[FATE] 状态变更: ChangingInstance")
    end
end

--Paths to the Fate NPC Starter
function MoveToNPC()
    yield("/target "..CurrentFate.npcName)
    if HasTarget() and GetTargetName()==CurrentFate.npcName then
        if GetDistanceToTarget() > 5 then
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), false)
        end
    end
end

--Paths to the Fate. CurrentFate is set here to allow MovetoFate to change its mind,
--so CurrentFate is possibly nil.
function MoveToFate()
    SuccessiveInstanceChanges = 0

    if not IsPlayerAvailable() then
        return
    end

    if CurrentFate~=nil and not IsFateActive(CurrentFate.fateId) then
        LogInfo("[FATE] Next Fate is dead, selecting new Fate.")
        yield("/vnav stop")
        State = CharacterState.ready
        LogInfo("[FATE] 状态变更: Ready")
        return
    end

    NextFate = SelectNextFate()
    if NextFate == nil then -- when moving to next fate, CurrentFate == NextFate
        yield("/vnav stop")
        State = CharacterState.ready
        LogInfo("[FATE] 状态变更: Ready")
        return
    elseif CurrentFate == nil or NextFate.fateId ~= CurrentFate.fateId then
        yield("/vnav stop")
        CurrentFate = NextFate
        SetMapFlag(SelectedZone.zoneId, CurrentFate.x, CurrentFate.y, CurrentFate.z)
        return
    end

    -- change to secondary class if it's a boss fate
    if BossFatesClass ~= nil then
        local currentClass = GetClassJobId()
        if CurrentFate.isBossFate and currentClass ~= BossFatesClass.classId then
            yield("/gs change "..BossFatesClass.className)
            return
        elseif not CurrentFate.isBossFate and currentClass ~= MainClass.classId then
            yield("/gs change "..MainClass.className)
            return
        end
    end

    -- upon approaching fate, pick a target and switch to pathing towards target
    if GetDistanceToPoint(CurrentFate.x, CurrentFate.y, CurrentFate.z) < 60 then
        if HasTarget() then
            LogInfo("[FATE] Found FATE target, immediate rerouting")
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
            if (CurrentFate.isOtherNpcFate or CurrentFate.isCollectionsFate) then
                State = CharacterState.interactWithNpc
                LogInfo("[FATE] 状态变更: Interact with npc")
            -- if GetTargetName() == CurrentFate.npcName then
            --     State = CharacterState.interactWithNpc
            -- elseif GetTargetFateID() == CurrentFate.fateId then
            --     State = CharacterState.middleOfFateDismount
            --     LogInfo("[FATE] 状态变更: MiddleOfFateDismount")
            else
                State = CharacterState.middleOfFateDismount
                LogInfo("[FATE] 状态变化: MiddleOfFateDismount")
            end
            return
        else
            if (CurrentFate.isOtherNpcFate or CurrentFate.isCollectionsFate) and not IsInFate() then
                yield("/target "..CurrentFate.npcName)
            else
                TargetClosestFateEnemy()
            end
            yield("/wait 0.5") -- give it a moment to make sure the target sticks
	            return
        end
    end

    -- check for stuck
    if (PathIsRunning() or PathfindInProgress()) and GetCharacterCondition(CharacterCondition.mounted) then
        local now = os.clock()
        if now - LastStuckCheckTime > 10 then
            local x = GetPlayerRawXPos()
            local y = GetPlayerRawYPos()
            local z = GetPlayerRawZPos()

            if GetDistanceToPoint(LastStuckCheckPosition.x, LastStuckCheckPosition.y, LastStuckCheckPosition.z) < 3 then
                yield("/vnav stop")
                yield("/wait 1")
                LogInfo("[FATE] Antistuck")
                PathfindAndMoveTo(x, y + 10, z, GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying) -- fly up 10 then try again
            end
            
            LastStuckCheckTime = now
            LastStuckCheckPosition = {x=x, y=y, z=z}
        end
        return
    end

    if not MovingAnnouncementLock then
        LogInfo("[FATE] 移动到FATE #"..CurrentFate.fateId.." "..CurrentFate.fateName)
        MovingAnnouncementLock = true
        if Echo == "All" then
            yield("/echo [FATE] 移动到FATE #"..CurrentFate.fateId.." "..CurrentFate.fateName)
        end
    end

    if TeleportToClosestAetheryteToFate(CurrentFate) then
        return
    end

    if not GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.mounting
        LogInfo("[FATE] 状态变更: Mounting")
        return
    end

    local nearestLandX, nearestLandY, nearestLandZ = CurrentFate.x, CurrentFate.y, CurrentFate.z
    if not (CurrentFate.isCollectionsFate or CurrentFate.isOtherNpcFate) then
        nearestLandX, nearestLandY, nearestLandZ = RandomAdjustCoordinates(CurrentFate.x, CurrentFate.y, CurrentFate.z, 10)
    end

    if GetDistanceToPoint(nearestLandX, nearestLandY, nearestLandZ) > 5 then
        PathfindAndMoveTo(nearestLandX, nearestLandY, nearestLandZ, HasFlightUnlocked(SelectedZone.zoneId) and SelectedZone.flying)
    else
        State = CharacterState.middleOfFateDismount
    end
end

function InteractWithFateNpc()
    if IsInFate() or GetFateStartTimeEpoch(CurrentFate.fateId) > 0 then
        yield("/vnav stop")
        State = CharacterState.doFate
        LogInfo("[FATE] 状态变更: DoFate")
        yield("/wait 1") -- give the fate a second to register before dofate and lsync
    elseif not IsFateActive(CurrentFate.fateId) then
        State = CharacterState.ready
        LogInfo("[FATE] 状态变更: Ready")
    elseif PathfindInProgress() or PathIsRunning() then
        if HasTarget() and GetTargetName() == CurrentFate.npcName and GetDistanceToTarget() < (5*math.random()) then
            yield("/vnav stop")
        end
        return
    else
        -- if target is already selected earlier during pathing, avoids having to target and move again
        if (not HasTarget() or GetTargetName()~=CurrentFate.npcName) then
            yield("/target "..CurrentFate.npcName)
            return
        end

        if GetCharacterCondition(CharacterCondition.mounted) then
            State = CharacterState.npcDismount
            LogInfo("[FATE] 状态变更: NPCDismount")
            return
        end

        if GetDistanceToPoint(GetTargetRawXPos(), GetPlayerRawYPos(), GetTargetRawZPos()) > 5 then
            MoveToNPC()
            return
        end

        if IsAddonVisible("SelectYesno") then
            AcceptNPCFateOrRejectOtherYesno()
        elseif not GetCharacterCondition(CharacterCondition.occupied) then
            yield("/interact")
        end
    end
end

function CollectionsFateTurnIn()
    AcceptNPCFateOrRejectOtherYesno()

    if CurrentFate ~= nil and not IsFateActive(CurrentFate.fateId) then
        CurrentFate = nil
        State = CharacterState.ready
        LogInfo("[FATE] 状态变更: Ready")
        return
    end

    if (not HasTarget() or GetTargetName()~=CurrentFate.npcName) then
        TurnOffCombatMods()
        yield("/target "..CurrentFate.npcName)
        yield("/wait 1")

        -- if too far from npc to target, then head towards center of fate
        if (not HasTarget() or GetTargetName()~=CurrentFate.npcName and GetFateProgress(CurrentFate.fateId) < 100) then
            if not PathfindInProgress() and not PathIsRunning() then
                PathfindAndMoveTo(CurrentFate.x, CurrentFate.y, CurrentFate.z)
            end
        else
            yield("/vnav stop")
        end
        return
    end

    if GetDistanceToPoint(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos()) > 5 then
        if not (PathfindInProgress() or PathIsRunning()) then
            MoveToNPC()
        end
    else
        if GetItemCount(GetFateEventItem(CurrentFate.fateId)) >= 7 then
            GotCollectionsFullCredit = true
        end

        yield("/vnav stop")
        yield("/interact")
        yield("/wait 3")

        if GetFateProgress(CurrentFate.fateId) < 100 then
            TurnOnCombatMods()
            State = CharacterState.doFate
            LogInfo("[FATE] 状态变更: DoFate")
        else
            if GotCollectionsFullCredit then
                State = CharacterState.unexpectedCombat
                LogInfo("[FATE] 状态变更: UnexpectedCombat")
            end
        end

        if CurrentFate ~=nil and CurrentFate.npcName ~=nil and GetTargetName() == CurrentFate.npcName then
            LogInfo("[FATE] Attempting to clear target.")
            ClearTarget()
            yield("/wait 1")
        end
    end
end

--#endregion

--#region Combat Functions

function GetClassJobTableFromId(jobId)
    if jobId == nil then
        LogInfo("[FATE] JobId is nil")
        return nil
    end
    for _, classJob in pairs(ClassList) do
        if classJob.classId == jobId then
            return classJob
        end
    end
    LogInfo("[FATE] Cannot recognize combat job.")
    return nil
end

function GetClassJobTableFromAbbrev(classString)
    if classString == "" then
        LogInfo("[FATE] No class set")
        return nil
    end
    for classJobAbbrev, classJob in pairs(ClassList) do
        if classJobAbbrev == string.lower(classString) then
            return classJob
        end
    end
    LogInfo("[FATE] Cannot recognize combat job.")
    return nil
end

function SummonChocobo()
    if GetCharacterCondition(CharacterCondition.mounted) then
        Dismount()
        return
    end

    if ShouldSummonChocobo and GetBuddyTimeRemaining() <= ResummonChocoboTimeLeft then
        if GetItemCount(4868) > 0 then
            yield("/item 基萨尔野菜")
            yield("/wait 3")
            yield('/cac "'..ChocoboStance..'"')
        elseif ShouldAutoBuyGysahlGreens then
            State = CharacterState.autoBuyGysahlGreens
            LogInfo("[FATE] 状态变更: AutoBuyGysahlGreens")
            return
        end
    end
    State = CharacterState.ready
    LogInfo("[FATE] 状态变更: Ready")
end

function AutoBuyGysahlGreens()
    if GetItemCount(4868) > 0 then -- don't need to buy
        if IsAddonVisible("Shop") then
            yield("/callback Shop true -1")
        elseif IsInZone(SelectedZone.zoneId) then
            yield("/item 基萨尔野菜")
        else
            State = CharacterState.ready
            LogInfo("State Change: ready")
        end
        return
    else
        if not IsInZone(129) then
            yield("/vnav stop")
            TeleportTo("利姆萨·罗敏萨下层甲板")
            return
        else
            local gysahlGreensVendor = { x=-62.1, y=18.0, z=9.4, npcName="班戈·赞戈" }
            if GetDistanceToPoint(gysahlGreensVendor.x, gysahlGreensVendor.y, gysahlGreensVendor.z) > 5 then
                if not (PathIsRunning() or PathfindInProgress()) then
                    PathfindAndMoveTo(gysahlGreensVendor.x, gysahlGreensVendor.y, gysahlGreensVendor.z)
                end
            elseif HasTarget() and GetTargetName() == gysahlGreensVendor.npcName then
                yield("/vnav stop")
                if IsAddonVisible("SelectYesno") then
                    yield("/callback SelectYesno true 0")
                elseif IsAddonVisible("SelectIconString") then
                    yield("/callback SelectIconString true 0")
                    return
                elseif IsAddonVisible("Shop") then
                    yield("/callback Shop true 0 2 99")
                    return
                elseif not GetCharacterCondition(CharacterCondition.occupied) then
                    yield("/interact")
                    yield("/wait 1")
                    return
                end
            else
                yield("/vnav stop")
                yield("/target "..gysahlGreensVendor.npcName)
            end
        end
    end
end

--Paths to the enemy (for Meele)
function EnemyPathing()
    while HasTarget() and GetDistanceToTarget() > (GetTargetHitboxRadius() + MaxDistance) do
        local enemy_x = GetTargetRawXPos()
        local enemy_y = GetTargetRawYPos()
        local enemy_z = GetTargetRawZPos()
        if PathIsRunning() == false then
            PathfindAndMoveTo(enemy_x, enemy_y, enemy_z, GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
        end
        yield("/wait 0.1")
    end
end

function TurnOnAoes()
    if not AoesOn then
        if RotationPlugin == "RSR" then
            yield("/rotation off")
            yield("/rotation auto on")
            LogInfo("[FATE] TurnOnAoes /rotation auto on")

            if RSRAoeType == "Off" then
                yield("/rotation settings aoetype 0")
            elseif RSRAoeType == "Cleave" then
                yield("/rotation settings aoetype 1")
            elseif RSRAoeType == "Full" then
                yield("/rotation settings aoetype 2")
            end
        elseif RotationPlugin == "BMR" then
            yield("/bmrai setpresetname "..RotationAoePreset)
        elseif RotationPlugin == "VBM" then
            yield("/vbmai setpresetname "..RotationAoePreset)
        end
        AoesOn = true
    end
end

function TurnOffAoes()
    if AoesOn then
        if RotationPlugin == "RSR" then
            yield("/rotation settings aoetype 1")
            yield("/rotation manual")
            LogInfo("[FATE] TurnOffAoes /rotation manual")
        elseif RotationPlugin == "BMR" then
            yield("/bmrai setpresetname "..RotationSingleTargetPreset)
        elseif RotationPlugin == "VBM" then
            yield("/vbmai setpresetname "..RotationSingleTargetPreset)
        end
        AoesOn = false
    end
end

function TurnOffRaidBuffs()
    if AoesOn then
        if RotationPlugin == "BMR" then
            yield("/bmrai setpresetname "..RotationHoldBuffPreset)
        elseif RotationPlugin == "VBM" then
            yield("/vbmai setpresetname "..RotationHoldBuffPreset)
        end
    end
end

function SetMaxDistance()
    MaxDistance = MeleeDist --default to melee distance
    --ranged and casters have a further max distance so not always running all way up to target
    local currentClass = GetClassJobTableFromId(GetClassJobId())
    if not currentClass.isMelee then
        MaxDistance = RangedDist
    end
end

function TurnOnCombatMods(rotationMode)
    if not CombatModsOn then
        CombatModsOn = true
        -- turn on RSR in case you have the RSR 30 second out of combat timer set
        if RotationPlugin == "RSR" then
            if rotationMode == "manual" then
                yield("/rotation manual")
                LogInfo("[FATE] TurnOnCombatMods /rotation manual")
            else
                yield("/rotation off")
                yield("/rotation auto on")
                LogInfo("[FATE] TurnOnCombatMods /rotation auto on")
            end
        elseif RotationPlugin == "BMR" then
            yield("/bmrai setpresetname "..RotationAoePreset)
        elseif RotationPlugin == "VBM" then
            yield("/vbmai setpresetname "..RotationAoePreset)
        elseif RotationPlugin == "Wrath" then
            yield("/wrath auto on")
        end

        local class = GetClassJobTableFromId(GetClassJobId())
        
        if not AiDodgingOn then
            SetMaxDistance()
            
            if DodgingPlugin == "BMR" then
                yield("/bmrai on")
                yield("/bmrai followtarget on") -- overrides navmesh path and runs into walls sometimes
                yield("/bmrai followcombat on")
                -- yield("/bmrai followoutofcombat on")
                yield("/bmrai maxdistancetarget " .. MaxDistance)
            elseif DodgingPlugin == "VBM" then
                yield("/vbmai on")
                yield("/vbmai followtarget on") -- overrides navmesh path and runs into walls sometimes
                yield("/vbmai followcombat on")
                -- yield("/bmrai followoutofcombat on")
                yield("/vbmai maxdistancetarget " .. MaxDistance)
                if RotationPlugin ~= "VBM" then
                    yield("/vbmai ForbidActions on") --This Disables VBM AI Auto-Target
                end
            end
            AiDodgingOn = true
        end
    end
end

function TurnOffCombatMods()
    if CombatModsOn then
        LogInfo("[FATE] Turning off combat mods")
        CombatModsOn = false

        if RotationPlugin == "RSR" then
            yield("/rotation off")
            LogInfo("[FATE] TurnOffCombatMods /rotation off")
        elseif RotationPlugin == "BMR" or RotationPlugin == "VBM" then
            yield("/bmrai setpresetname null")
        elseif RotationPlugin == "Wrath" then
            yield("/wrath auto off")
        end

        -- turn off BMR so you don't start following other mobs
        if AiDodgingOn then
            if DodgingPlugin == "BMR" then
                yield("/bmrai off")
                yield("/bmrai followtarget off")
                yield("/bmrai followcombat off")
                yield("/bmrai followoutofcombat off")
            elseif DodgingPlugin == "VBM" then
                yield("/vbmai off")
                yield("/vbmai followtarget off")
                yield("/vbmai followcombat off")
                yield("/vbmai followoutofcombat off")
                if RotationPlugin ~= "VBM" then
                    yield("/vbmai ForbidActions off") --This Enables VBM AI Auto-Target
                end
            end
            AiDodgingOn = false
        end
    end
end

function HandleUnexpectedCombat()
    TurnOnCombatMods("manual")

    if IsInFate() and GetFateProgress(GetNearestFate()) < 100 then
        CurrentFate = BuildFateTable(GetNearestFate())
        State = CharacterState.doFate
        LogInfo("[FATE] 状态变更: DoFate")
        return
    elseif not GetCharacterCondition(CharacterCondition.inCombat) then
        yield("/vnav stop")
        ClearTarget()
        TurnOffCombatMods()
        State = CharacterState.ready
        LogInfo("[FATE] 状态变更: Ready")
        local randomWait = (math.floor(math.random()*MaxWait * 1000)/1000) + MinWait -- truncated to 3 decimal places
        yield("/wait "..randomWait)
        return
    end

    if GetCharacterCondition(CharacterCondition.mounted) then
        if not (PathfindInProgress() or PathIsRunning()) then
            PathfindAndMoveTo(GetPlayerRawXPos(), GetPlayerRawYPos() + 10, GetPlayerRawZPos(), true)
        end
        yield("/wait 10")
        return
    end

    -- targets whatever is trying to kill you
    if not HasTarget() then
        yield("/battletarget")
    end

    -- pathfind closer if enemies are too far
    if HasTarget() then
        if GetDistanceToTarget() > (MaxDistance + GetTargetHitboxRadius()) then
            if not (PathfindInProgress() or PathIsRunning()) then
                PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
            end
        else
            if PathfindInProgress() or PathIsRunning() then
                yield("/vnav stop")
            elseif not GetCharacterCondition(CharacterCondition.inCombat) then
                --inch closer 3 seconds
                PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
                yield("/wait 3")
            end
        end
    end
    yield("/wait 1")
end

function DoFate()
    if WaitingForFateRewards ~= CurrentFate.fateId then
        WaitingForFateRewards = CurrentFate.fateId
        LogInfo("[FATE] WaitingForFateRewards DoFate: "..tostring(WaitingForFateRewards))
    end
    local currentClass = GetClassJobId()
    -- switch classes (mostly for continutation fates that pop you directly into the next one)
    if CurrentFate.isBossFate and BossFatesClass ~= nil and currentClass ~= BossFatesClass.classId and not IsPlayerOccupied() then
        TurnOffCombatMods()
        yield("/gs change "..BossFatesClass.className)
        yield("/wait 1")
        return
    elseif not CurrentFate.isBossFate and BossFatesClass ~= nil and currentClass ~= MainClass.classId and not IsPlayerOccupied() then
        TurnOffCombatMods()
        yield("/gs change "..MainClass.className)
        yield("/wait 1")
        return
    elseif IsInFate() and (GetFateMaxLevel(CurrentFate.fateId) < GetLevel()) and not IsLevelSynced() then
        yield("/lsync")
        yield("/wait 0.5") -- give it a second to register
    elseif IsFateActive(CurrentFate.fateId) and not IsInFate() and GetFateProgress(CurrentFate.fateId) < 100 and
        (GetDistanceToPoint(CurrentFate.x, CurrentFate.y, CurrentFate.z) < GetFateRadius(CurrentFate.fateId) + 10) and
        not GetCharacterCondition(CharacterCondition.mounted) and not (PathIsRunning() or PathfindInProgress())
    then -- got pushed out of fate. go back
        yield("/vnav stop")
        yield("/wait 1")
        LogInfo("[FATE] pushed out of fate going back!")
        PathfindAndMoveTo(CurrentFate.x, CurrentFate.y, CurrentFate.z, GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
        return
    elseif not IsFateActive(CurrentFate.fateId) or GetFateProgress(CurrentFate.fateId) == 100 then
        yield("/vnav stop")
        ClearTarget()
        if not LogInfo("[FATE] HasContintuation check") and CurrentFate.hasContinuation then
            LastFateEndTime = os.clock()
            State = CharacterState.waitForContinuation
            LogInfo("[FATE] 状态变更: WaitForContinuation")
            return
        else
            DidFate = true
            LogInfo("[FATE] No continuation for "..CurrentFate.fateName)
            local randomWait = (math.floor(math.random() * (math.max(0, MaxWait - 3)) * 1000)/1000) + MinWait -- truncated to 3 decimal places
            yield("/wait "..randomWait)
            TurnOffCombatMods()
            State = CharacterState.ready
            LogInfo("[FATE] 状态变更: Ready")
        end
        return
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.middleOfFateDismount
        LogInfo("[FATE] 状态变更: MiddleOfFateDismount")
        return
    elseif CurrentFate.isCollectionsFate then
        yield("/wait 1") -- needs a moment after start of fate for GetFateEventItem to populate
        if GetItemCount(GetFateEventItem(CurrentFate.fateId)) >= 7 or (GotCollectionsFullCredit and GetFateProgress(CurrentFate.fateId) == 100) then
            yield("/vnav stop")
            State = CharacterState.collectionsFateTurnIn
            LogInfo("[FATE] 状态变更: CollectionsFatesTurnIn")
        end
    end

    LogInfo("DoFate->Finished transition checks")

    -- do not target fate npc during combat
    if CurrentFate.npcName ~=nil and GetTargetName() == CurrentFate.npcName then
        LogInfo("[FATE] Attempting to clear target.")
        ClearTarget()
        yield("/wait 1")
    end

    TurnOnCombatMods("auto")

    GemAnnouncementLock = false

    -- switches to targeting forlorns for bonus (if present)
    if not IgnoreForlorns then
        yield("/target 迷失少女")
        if not IgnoreBigForlornOnly then
            yield("/target 迷失者")
        end
    end

    if (GetTargetName() == "迷失少女" or GetTargetName() == "迷失者") then
        if IgnoreForlorns or (IgnoreBigForlornOnly and GetTargetName() == "迷失者") then
            ClearTarget()
        elseif GetTargetHP() > 0 then
            if not ForlornMarked then
                yield("/marking attack1")
                if Echo == "All" then
                    yield("/echo 发现迷失者! <se.3>")
                end
                TurnOffAoes()
                ForlornMarked = true
            end
        else
            ClearTarget()
            TurnOnAoes()
        end
    else
        TurnOnAoes()
    end

    -- targets whatever is trying to kill you
    if not HasTarget() then
        yield("/battletarget")
    end

    -- clears target
    if GetTargetFateID() ~= CurrentFate.fateId and not IsTargetInCombat() then
        ClearTarget()
    end

    -- do not interrupt casts to path towards enemies
    if GetCharacterCondition(CharacterCondition.casting) then
        return
    end

    -- pathfind closer if enemies are too far
    if not GetCharacterCondition(CharacterCondition.inCombat) then
        if HasTarget() then
            local x,y,z = GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos()
            if GetDistanceToTarget() <= (MaxDistance + GetTargetHitboxRadius()) then
                if PathfindInProgress() or PathIsRunning() then
                    yield("/vnav stop")
                    yield("/wait 5.002") -- wait 5s before inching any closer
                elseif (GetDistanceToTarget() > (1 + GetTargetHitboxRadius())) and not GetCharacterCondition(CharacterCondition.casting) then -- never move into hitbox
                    PathfindAndMoveTo(x, y, z)
                    yield("/wait 1") -- inch closer by 1s
                end
            elseif not (PathfindInProgress() or PathIsRunning()) then
                yield("/wait 5.003") -- give 5s for enemy AoE casts to go off before attempting to move closer
                if (x ~= 0 and z~=0 and not GetCharacterCondition(CharacterCondition.inCombat)) and not GetCharacterCondition(CharacterCondition.casting) then
                    PathfindAndMoveTo(x, y, z)
                end
            end
            return
        else
            TargetClosestFateEnemy()
            yield("/wait 1") -- wait in case target doesn't stick
            if (not HasTarget()) and not GetCharacterCondition(CharacterCondition.casting) then
                PathfindAndMoveTo(CurrentFate.x, CurrentFate.y, CurrentFate.z)
            end
        end
    else
        if HasTarget() and (GetDistanceToTarget() <= (MaxDistance + GetTargetHitboxRadius())) then
            if PathfindInProgress() or PathIsRunning() then
                yield("/vnav stop")
            end
        elseif not CurrentFate.isBossFate then
            if not (PathfindInProgress() or PathIsRunning()) then
                yield("/wait 5.004")
                local x,y,z = GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos()
                if (x ~= 0 and z~=0)  and not GetCharacterCondition(CharacterCondition.casting) then
                    PathfindAndMoveTo(x,y,z, GetCharacterCondition(CharacterCondition.flying) and SelectedZone.flying)
                end
            end
        end
    end
        
    --hold buff thingy
    if GetFateProgress(CurrentFate.fateId) >= PercentageToHoldBuff then 
        TurnOffRaidBuffs()
    end   
end

--#endregion

--#region State Transition Functions

function FoodCheck()
    --food usage
    if not HasStatusId(48) and Food ~= "" then
        yield("/item " .. Food)
    end
end

function PotionCheck()
    --pot usage
    if not HasStatusId(49) and Potion ~= "" then
        yield("/item " .. Potion)
    end
end

function Ready()
    FoodCheck()
    PotionCheck()
    
    CombatModsOn = false -- expect RSR to turn off after every fate
    GotCollectionsFullCredit = false
    ForlornMarked = false
    MovingAnnouncementLock = false

    local shouldWaitForBonusBuff = WaitIfBonusBuff and (HasStatusId(1288) or HasStatusId(1289))

    NextFate = SelectNextFate()
    if CurrentFate ~= nil and not IsFateActive(CurrentFate.fateId) then
        CurrentFate = nil
    end

    if CurrentFate == nil then
        LogInfo("[FATE] CurrentFate is nil")
    else
        LogInfo("[FATE] CurrentFate is "..CurrentFate.fateName)
    end

    if NextFate == nil then
        LogInfo("[FATE] NextFate is nil")
    else
        LogInfo("[FATE] NextFate is "..NextFate.fateName)
    end

    if not LogInfo("[FATE] Ready -> IsPlayerAvailable()") and not IsPlayerAvailable() then
        return
    elseif not LogInfo("[FATE] Ready -> Repair") and RepairAmount > 0 and NeedsRepair(RepairAmount) and
        (not shouldWaitForBonusBuff or (SelfRepair and GetItemCount(33916) > 0)) then
        State = CharacterState.repair
        LogInfo("[FATE] 状态变更: Repair")
    elseif not LogInfo("[FATE] Ready -> ExtractMateria") and ShouldExtractMateria and CanExtractMateria(100) and GetInventoryFreeSlotCount() > 1 then
        State = CharacterState.extractMateria
        LogInfo("[FATE] 状态变更: ExtractMateria")
    elseif (not LogInfo("[FATE] Ready -> WaitBonusBuff") and NextFate == nil and shouldWaitForBonusBuff) and DownTimeWaitAtNearestAetheryte then
        if not HasTarget() or GetTargetName() ~= "以太之光" or GetDistanceToTarget() > 20 then
            State = CharacterState.flyBackToAetheryte
            LogInfo("[FATE] 状态变更: FlyBackToAetheryte")
        else
            yield("/wait 10")
        end
        return
    elseif not LogInfo("[FATE] Ready -> ExchangingVouchers") and WaitingForFateRewards == 0 and
        ShouldExchangeBicolorGemstones and (BicolorGemCount >= 1400) and not shouldWaitForBonusBuff
    then
        State = CharacterState.exchangingVouchers
        LogInfo("[FATE] 状态变更: ExchangingVouchers")
    elseif not LogInfo("[FATE] Ready -> ProcessRetainers") and WaitingForFateRewards == 0 and
        Retainers and ARRetainersWaitingToBeProcessed() and GetInventoryFreeSlotCount() > 1  and not shouldWaitForBonusBuff
    then
        State = CharacterState.processRetainers
        LogInfo("[FATE] 状态变更: ProcessingRetainers")
    elseif not LogInfo("[FATE] Ready -> GC TurnIn") and ShouldGrandCompanyTurnIn and
        GetInventoryFreeSlotCount() < InventorySlotsLeft and not shouldWaitForBonusBuff
    then
        State = CharacterState.gcTurnIn
        LogInfo("[FATE] 状态变更: GCTurnIn")
    elseif not LogInfo("[FATE] Ready -> TeleportBackToFarmingZone") and not IsInZone(SelectedZone.zoneId) then
        TeleportTo(SelectedZone.aetheryteList[1].aetheryteName)
        return
    elseif not LogInfo("[FATE] Ready -> SummonChocobo") and ShouldSummonChocobo and GetBuddyTimeRemaining() <= ResummonChocoboTimeLeft and
        (not shouldWaitForBonusBuff or GetItemCount(4868) > 0) then
        State = CharacterState.summonChocobo
    elseif not LogInfo("[FATE] Ready -> NextFate nil") and NextFate == nil then
        if EnableChangeInstance and GetZoneInstance() > 0 and not shouldWaitForBonusBuff then
            State = CharacterState.changingInstances
            LogInfo("[FATE] 状态变更: ChangingInstances")
            return
        elseif CompanionScriptMode and not shouldWaitForBonusBuff then
            if WaitingForFateRewards == 0 then
                StopScript = true
                LogInfo("[FATE] StopScript: Ready")
            else
                LogInfo("[FATE] Waiting for fate rewards")
            end
        elseif (not HasTarget() or GetTargetName() ~= "以太之光" or GetDistanceToTarget() > 20) and DownTimeWaitAtNearestAetheryte then
            State = CharacterState.flyBackToAetheryte
            LogInfo("[FATE] 状态变更: FlyBackToAetheryte")
        else
            yield("/wait 10")
        end
        return
    elseif CompanionScriptMode and DidFate and not shouldWaitForBonusBuff then
        if WaitingForFateRewards == 0 then
            StopScript = true
            LogInfo("[FATE] StopScript: DidFate")
        else
            LogInfo("[FATE] Waiting for fate rewards")
        end
    elseif not LogInfo("[FATE] Ready -> MovingToFate") then -- and ((CurrentFate == nil) or (GetFateProgress(CurrentFate.fateId) == 100) and NextFate ~= nil) then
        CurrentFate = NextFate
        SetMapFlag(SelectedZone.zoneId, CurrentFate.x, CurrentFate.y, CurrentFate.z)
        State = CharacterState.moveToFate
        LogInfo("[FATE] 状态变更: MovingtoFate "..CurrentFate.fateName)
    end

    if not GemAnnouncementLock and (Echo == "All" or Echo == "Gems") then
        GemAnnouncementLock = true
        if BicolorGemCount >= 1400 then
            yield("/echo [FATE] 你已经有了 "..tostring(BicolorGemCount).."/1500 gems! <se.3>")
        else
            yield("/echo [FATE] 双色宝石: "..tostring(BicolorGemCount).."/1500")
        end
    end
end


function HandleDeath()
    CurrentFate = nil

    if CombatModsOn then
        TurnOffCombatMods()
    end

    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
    end

    if GetCharacterCondition(CharacterCondition.dead) then --Condition Dead
        if Echo and not DeathAnnouncementLock then
            DeathAnnouncementLock = true
            if Echo == "All" then
                yield("/echo [FATE] 你死了，回到返回点的以太之光吧")
            end
        end

        if IsAddonVisible("SelectYesno") then --rez addon yes
            yield("/callback SelectYesno true 0")
            yield("/wait 0.1")
        end
    else
        State = CharacterState.ready
        LogInfo("[FATE] 状态变更: Ready")
        DeathAnnouncementLock = false
    end
end

function ExecuteBicolorExchange()
    CurrentFate = nil

    if BicolorGemCount >= 1400 then
        if IsAddonVisible("SelectYesno") then
            yield("/callback SelectYesno true 0")
            return
        end

        if IsAddonVisible("ShopExchangeCurrency") then
            yield("/callback ShopExchangeCurrency false 0 "..SelectedBicolorExchangeData.item.itemIndex.." "..(BicolorGemCount//SelectedBicolorExchangeData.item.price))
            return
        end

        if not IsInZone(SelectedBicolorExchangeData.zoneId) then
            TeleportTo(SelectedBicolorExchangeData.aetheryteName)
            return
        end
    
        local shopX = SelectedBicolorExchangeData.x
        local shopY = SelectedBicolorExchangeData.y
        local shopZ = SelectedBicolorExchangeData.z
    
        if SelectedBicolorExchangeData.miniAethernet ~= nil and
            GetDistanceToPoint(shopX, shopY, shopZ) > (DistanceBetween(SelectedBicolorExchangeData.miniAethernet.x, SelectedBicolorExchangeData.miniAethernet.y, SelectedBicolorExchangeData.miniAethernet.z, shopX, shopY, shopZ) + 10) then
            LogInfo("Distance to shopkeep is too far. Using mini aetheryte.")
            yield("/li "..SelectedBicolorExchangeData.miniAethernet.name)
            yield("/wait 1") -- give it a moment to register
            return
        elseif IsAddonVisible("TelepotTown") then
            LogInfo("TelepotTown open")
            yield("/callback TelepotTown false -1")
        elseif GetDistanceToPoint(shopX, shopY, shopZ) > 5 then
            LogInfo("Distance to shopkeep is too far. Walking there.")
            if not (PathfindInProgress() or PathIsRunning()) then
                LogInfo("Path not running")
                PathfindAndMoveTo(shopX, shopY, shopZ)
            end
        else
            LogInfo("[FATE] Arrived at Shopkeep")
            if PathfindInProgress() or PathIsRunning() then
                yield("/vnav stop")
            end
    
            if not HasTarget() or GetTargetName() ~= SelectedBicolorExchangeData.shopKeepName then
                yield("/target "..SelectedBicolorExchangeData.shopKeepName)
            elseif not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
                yield("/interact")
            end
        end
    else
        if IsAddonVisible("ShopExchangeCurrency") then
            LogInfo("[FATE] Attemping to close shop window")
            yield("/callback ShopExchangeCurrency true -1")
            return
        elseif GetCharacterCondition(CharacterCondition.occupiedInEvent) then
            LogInfo("[FATE] Character still occupied talking to shopkeeper")
            yield("/wait 0.5")
            return
        end

        State = CharacterState.ready
        LogInfo("[FATE] 状态变更: Ready")
        return
    end
end

function ProcessRetainers()
    CurrentFate = nil

    LogInfo("[FATE] Handling retainers...")
    if ARRetainersWaitingToBeProcessed() and GetInventoryFreeSlotCount() > 1 then
    
        if PathfindInProgress() or PathIsRunning() then
            return
        end

        if not IsInZone(129) then
            yield("/vnav stop")
            TeleportTo("利姆萨·罗敏萨下层甲板")
            return
        end

        local summoningBell = {
            x = -122.72,
            y = 18.00,
            z = 20.39
        }
        if GetDistanceToPoint(summoningBell.x, summoningBell.y, summoningBell.z) > 4.5 then
            PathfindAndMoveTo(summoningBell.x, summoningBell.y, summoningBell.z)
            return
        end

        if not HasTarget() or GetTargetName() ~= "传唤铃" then
            yield("/target 传唤铃")
            return
        end

        if not GetCharacterCondition(CharacterCondition.occupiedSummoningBell) then
            yield("/interact")
            if IsAddonVisible("RetainerList") then
                yield("/ays e")
                if Echo == "All" then
                    yield("/echo [FATE] Processing retainers")
                end
                yield("/wait 1")
            end
        end
    else
        if IsAddonVisible("RetainerList") then
            yield("/callback RetainerList true -1")
        elseif not GetCharacterCondition(CharacterCondition.occupiedSummoningBell) then
            State = CharacterState.ready
            LogInfo("[FATE] 状态变更: Ready")
        end
    end
end

function GrandCompanyTurnIn()
    if GetInventoryFreeSlotCount() <= InventorySlotsLeft then
        local playerGC = GetPlayerGC()
        local gcZoneIds = {
            129, --Limsa Lominsa
            132, --New Gridania
            130 --"Ul'dah - Steps of Nald"
        }
        if not IsInZone(gcZoneIds[playerGC]) then
            yield("/li gc")
            yield("/wait 1")
        elseif DeliverooIsTurnInRunning() then
            return
        else
            yield("/deliveroo enable")
        end
    else
        State = CharacterState.ready
        LogInfo("State Change: Ready")
    end
end

function Repair()
    if IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
        return
    end

    if IsAddonVisible("Repair") then
        if not NeedsRepair(RepairAmount) then
            yield("/callback Repair true -1") -- if you don't need repair anymore, close the menu
        else
            yield("/callback Repair true 0") -- select repair
        end
        return
    end

    -- if occupied by repair, then just wait
    if GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) then
        LogInfo("[FATE] Repairing...")
        yield("/wait 1")
        return
    end

    local hawkersAlleyAethernetShard = { x=-213.95, y=15.99, z=49.35 }
    if SelfRepair then
        if GetItemCount(33916) > 0 then
            if IsAddonVisible("Shop") then
                yield("/callback Shop true -1")
                return
            end

            if not IsInZone(SelectedZone.zoneId) then
                TeleportTo(SelectedZone.aetheryteList[1].aetheryteName)
                return
            end

            if GetCharacterCondition(CharacterCondition.mounted) then
                Dismount()
                LogInfo("[FATE] 状态变更: Dismounting")
                return
            end

            if NeedsRepair(RepairAmount) then
                if not IsAddonVisible("Repair") then
                    LogInfo("[FATE] Opening repair menu...")
                    yield("/gaction 修理")
                end
            else
                State = CharacterState.ready
                LogInfo("[FATE] 状态变更: Ready")
            end
        elseif ShouldAutoBuyDarkMatter then
            if not IsInZone(129) then
                if Echo == "All" then
                    yield("/echo 没有暗物质了！ 去下层甲板买点吧")
                end
                TeleportTo("利姆萨·罗敏萨下层甲板")
                return
            end

            local darkMatterVendor = { npcName="乌恩辛雷尔", x=-257.71, y=16.19, z=50.11, wait=0.08 }
            if GetDistanceToPoint(darkMatterVendor.x, darkMatterVendor.y, darkMatterVendor.z) > (DistanceBetween(hawkersAlleyAethernetShard.x, hawkersAlleyAethernetShard.y, hawkersAlleyAethernetShard.z,darkMatterVendor.x, darkMatterVendor.y, darkMatterVendor.z) + 10) then
                yield("/li 市场（国际广场）")
                yield("/wait 1") -- give it a moment to register
            elseif IsAddonVisible("TelepotTown") then
                yield("/callback TelepotTown false -1")
            elseif GetDistanceToPoint(darkMatterVendor.x, darkMatterVendor.y, darkMatterVendor.z) > 5 then
                if not (PathfindInProgress() or PathIsRunning()) then
                    PathfindAndMoveTo(darkMatterVendor.x, darkMatterVendor.y, darkMatterVendor.z)
                end
            else
                if not HasTarget() or GetTargetName() ~= darkMatterVendor.npcName then
                    yield("/target "..darkMatterVendor.npcName)
                elseif not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
                    yield("/interact")
                elseif IsAddonVisible("SelectYesno") then
                    yield("/callback SelectYesno true 0")
                elseif IsAddonVisible("Shop") then
                    yield("/callback Shop true 0 40 99")
                end
            end
        else
            if Echo == "All" then
                yield("/echo Out of Dark Matter and ShouldAutoBuyDarkMatter is false. Switching to Limsa mender.")
            end
            SelfRepair = false
        end
    else
        if NeedsRepair(RepairAmount) then
            if not IsInZone(129) then
                TeleportTo("利姆萨·罗敏萨下层甲板")
                return
            end
            
            local mender = { npcName="阿里斯特尔", x=-246.87, y=16.19, z=49.83 }
            if GetDistanceToPoint(mender.x, mender.y, mender.z) > (DistanceBetween(hawkersAlleyAethernetShard.x, hawkersAlleyAethernetShard.y, hawkersAlleyAethernetShard.z, mender.x, mender.y, mender.z) + 10) then
                yield("/li 市场（国际广场）")
                yield("/wait 1") -- give it a moment to register
            elseif IsAddonVisible("TelepotTown") then
                yield("/callback TelepotTown false -1")
            elseif GetDistanceToPoint(mender.x, mender.y, mender.z) > 5 then
                if not (PathfindInProgress() or PathIsRunning()) then
                    PathfindAndMoveTo(mender.x, mender.y, mender.z)
                end
            else
                if not HasTarget() or GetTargetName() ~= mender.npcName then
                    yield("/target "..mender.npcName)
                elseif not GetCharacterCondition(CharacterCondition.occupiedInQuestEvent) then
                    yield("/interact")
                end
            end
        else
            State = CharacterState.ready
            LogInfo("[FATE] 状态变更: Ready")
        end
    end
end

function ExtractMateria()
    if GetCharacterCondition(CharacterCondition.mounted) then
        Dismount()
        LogInfo("[FATE] 状态变更: Dismounting")
        return
    end

    if GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) then
        return
    end

    if CanExtractMateria(100) and GetInventoryFreeSlotCount() > 1 then
        if not IsAddonVisible("Materialize") then
            yield("/gaction 精制魔晶石")
            return
        end

        LogInfo("[FATE] Extracting materia...")
            
        if IsAddonVisible("MaterializeDialog") then
            yield("/callback MaterializeDialog true 0")
        else
            yield("/callback Materialize true 2 0")
        end
    else
        if IsAddonVisible("Materialize") then
            yield("/callback Materialize true -1")
        else
            State = CharacterState.ready
            LogInfo("[FATE] 状态变更: Ready")
        end
    end
end

CharacterState = {
    ready = Ready,
    dead = HandleDeath,
    unexpectedCombat = HandleUnexpectedCombat,
    mounting = Mount,
    npcDismount = NPCDismount,
    middleOfFateDismount = MiddleOfFateDismount,
    moveToFate = MoveToFate,
    interactWithNpc = InteractWithFateNpc,
    collectionsFateTurnIn = CollectionsFateTurnIn,
    doFate = DoFate,
    waitForContinuation = WaitForContinuation,
    changingInstances = ChangeInstance,
    changeInstanceDismount = ChangeInstanceDismount,
    flyBackToAetheryte = FlyBackToAetheryte,
    extractMateria = ExtractMateria,
    repair = Repair,
    exchangingVouchers = ExecuteBicolorExchange,
    processRetainers = ProcessRetainers,
    gcTurnIn = GrandCompanyTurnIn,
    summonChocobo = SummonChocobo,
    autoBuyGysahlGreens = AutoBuyGysahlGreens
}

--#endregion State Transition Functions

--#region Main

LogInfo("[FATE] Starting fate farming script.")

StopScript = false
DidFate = false
GemAnnouncementLock = false
DeathAnnouncementLock = false
MovingAnnouncementLock = false
SuccessiveInstanceChanges = 0
LastInstanceChangeTimestamp = 0
LastTeleportTimeStamp = 0
GotCollectionsFullCredit = false -- needs 7 items for  full
-- variable to track collections fates that you have completed but are still active.
-- will not leave area or change instance if value ~= 0
WaitingForFateRewards = 0
LastFateEndTime = os.clock()
LastStuckCheckTime = os.clock()
LastStuckCheckPosition = {x=GetPlayerRawXPos(), y=GetPlayerRawYPos(), z=GetPlayerRawZPos()}
MainClass = GetClassJobTableFromId(GetClassJobId())
BossFatesClass = nil
if ClassForBossFates ~= "" then
    BossFatesClass = GetClassJobTableFromAbbrev(ClassForBossFates)
end
SetMaxDistance()

SelectedZone = SelectNextZone()
if SelectedZone.zoneName ~= "" and Echo == "All" then
    yield("/echo [FATE] Farming "..SelectedZone.zoneName)
end
LogInfo("[FATE] Farming Start for "..SelectedZone.zoneName)

for _, shop in ipairs(BicolorExchangeData) do
    for _, item in ipairs(shop.shopItems) do
        if item.itemName == ItemToPurchase then
            SelectedBicolorExchangeData = {
                shopKeepName = shop.shopKeepName,
                zoneId = shop.zoneId,
                aetheryteName = shop.aetheryteName,
                miniAethernet = shop.miniAethernet,
                x = shop.x, y = shop.y, z = shop.z,
                item = item
            }
        end
    end
end
if SelectedBicolorExchangeData == nil then
    yield("/echo [FATE] 无法识别双色商店商品 "..ItemToPurchase.."! Please make sure it's in the BicolorExchangeData table!")
    StopScript = true
end

State = CharacterState.ready
CurrentFate = nil
if IsInFate() and GetFateProgress(GetNearestFate()) < 100 then
    CurrentFate = BuildFateTable(GetNearestFate())
end

if ShouldSummonChocobo and GetBuddyTimeRemaining() > 0 then
    yield('/cac "'..ChocoboStance..'"')
end

while not StopScript do
    if not NavIsReady() then
        yield("/echo [FATE] Waiting for vnavmesh to build...")
        LogInfo("[FATE] Waiting for vnavmesh to build...")
        repeat
            yield("/wait 1")
        until NavIsReady()
    end
    if State ~= CharacterState.dead and GetCharacterCondition(CharacterCondition.dead) then
        State = CharacterState.dead
        LogInfo("[FATE] 状态变更:Dead")
    elseif State ~= CharacterState.unexpectedCombat and State ~= CharacterState.doFate and
        State ~= CharacterState.waitForContinuation and State ~= CharacterState.collectionsFateTurnIn and
        (not IsInFate() or (IsInFate() and IsCollectionsFate(GetFateName(GetNearestFate())) and GetFateProgress(GetNearestFate()) == 100)) and
        GetCharacterCondition(CharacterCondition.inCombat)
    then
        State = CharacterState.unexpectedCombat
        LogInfo("[FATE] 状态变更:UnexpectedCombat")
    end
    
    BicolorGemCount = GetItemCount(26807)

    if not (IsPlayerCasting() or
        GetCharacterCondition(CharacterCondition.betweenAreas) or
        GetCharacterCondition(CharacterCondition.jumping48) or
        GetCharacterCondition(CharacterCondition.jumping61) or
        GetCharacterCondition(CharacterCondition.mounting57) or
        GetCharacterCondition(CharacterCondition.mounting64) or
        GetCharacterCondition(CharacterCondition.beingMoved) or
        GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) or
        LifestreamIsBusy())
    then
        if WaitingForFateRewards ~= 0 and not IsFateActive(WaitingForFateRewards) then
            WaitingForFateRewards = 0
            LogInfo("[FATE] WaitingForFateRewards: "..tostring(WaitingForFateRewards))
        end
        State()
    end
    yield("/wait 0.1")
end
yield("/vnav stop")

if GetClassJobId() ~= MainClass.classId then
    yield("/gs change "..MainClass.className)
end
--#endregion Main
