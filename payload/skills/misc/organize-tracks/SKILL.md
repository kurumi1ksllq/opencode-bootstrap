---
name: organize-tracks
description: Rename and organize multitrack audio files (WAV/AIFF) from DAW exports into consistent Category_Sub_Description_#.ext format. Use when working with audio multitrack sessions, exported DAW stems, or unorganized recording takes that need systematic renaming by instrument/vocal type.
---

# Organize Audio Tracks

## 命名规范

```
Category_Sub_Description_Version.ext
```

| 段 | 说明 | 示例 |
|---|---|---|
| Category | 乐器大类 | Drum / Bass / Gtr / Key / Synth / Vox / Fx / Ref / Riff |
| Sub | 子类/具体乐器 | Kick / Snare / Lead / Hook / Post |
| Description | 描述 + 人名 | Main / Trap / Dua / Paul_Hi |
| Version | 有对照序列的版本号 | 1 / 2（无对照序列的版本号不保留）|

**分类表：**

| Category | 涵盖内容 | Sub 示例 |
|---|---|---|
| Drum | 鼓组、打击乐、节奏 loop | Kick, Snare, Hat, Clap, Tom, Perc, Shaker, Cymbal, Crash, Ride, Beat, Conga, Snap, Woodblock, Triangle, Tamb |
| Bass | 各类贝斯 | Jazz, Arp2600, SEM, Sub, Standup |
| Gtr | 吉他 | Nile, Runk, Acoustic |
| Key | 键盘/钢琴类乐器 | Piano, Rhodes, Clav, Crumar, Strings |
| Synth | 合成器 | Stabs, Lead, Pad, Arp |
| Riff | 乐器乐句/loop | 编号 1~9 |
| Vox | 所有人声 | Lead, Hook, Post, Pre, Bridge, Adlib, Talkbox, Gang, BG, Robo, Vocoder, Chop |
| Fx | 效果音色 | Swells, RevVerb |
| Ref | 参考混音 | Coffee_New, DuaEdits |

## Workflow

### 第 1 步：扫描文件

```powershell
Get-ChildItem -Path "目标目录" -Filter *.wav | Select-Object Name
```

### 第 2 步：分类命名

核心规则：

1. **抽取有用信息**：类别、乐器、描述、人名、版本号
2. **去掉无意义尾部 `1`**：如果文件只有单独一个版本（没有 2/3/4），末尾的 take 序号 `1` 去掉
3. **保留对照序列**：如果存在 `XXX_1` 和 `XXX_2`，编号保留
4. **括号版本号转为 `_N`**：`XXX 1 (2).wav` → `XXX_2.wav`
5. **清理格式**：去除多余空格、统一分隔符为下划线、首字母大写

**特殊处理：**

- 文件名中 `-dry- optional` / `MAYBE MUTE` 等制作备注 → 视情况移除或保留关键信息
- 人名（stuart / paul / dua / coffee / sarah / lorna / todd）→ 保留在 Description 末尾
- 多余空格（`BRIDGE WHISPER DBL    .wav`）→ 精确匹配原文件名后用 `-LiteralPath`

### 第 3 步：编写改名脚本

使用模板脚本 `scripts/Rename-AudioTracks.ps1`：

```powershell
# 1. 填入目标路径
$path = "D:\Project\Audio"

# 2. 定义原文件名→新文件名映射
$map = @{
    "KICK knock .wav" = "Drum_Kick_Knock.wav"
    # ...
}

# 3. 执行改名（自动处理特殊字符）
foreach ($oldName in $map.Keys) {
    $oldPath = Join-Path $path $oldName
    if (Test-Path -LiteralPath $oldPath) {
        Rename-Item -LiteralPath $oldPath -NewName $map[$oldName]
    }
}
```

### 第 4 步：验证

```powershell
# 按 Category 分组统计
Get-ChildItem $path -Filter *.wav | Group-Object { $_.Name.Split('_')[0] }
# 检查是否有未改名的文件
Get-ChildItem $path -Filter *.wav | Where-Object { $_.Name -match '^[A-Z]' }
```

## 注意事项

- ⚠️ **重命名会断开 DAW 工程引用链接**。操作前告知用户，操作后需用 DAW 的 Find Missing Files 重新链接
- 避免使用中文/特殊字符（`&` `'` 等）在文件名中
- 如果文件数量超过 100，强烈建议编写脚本而非手动改名
- 原文件名中的多余空格（`XXX  .wav`）需要通过 `Get-ChildItem` 精确获取后再匹配
