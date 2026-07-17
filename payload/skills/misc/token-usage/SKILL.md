---
name: token-usage
description: 查询当前会话或指定会话的 token 消耗和费用明细，按成员（主对话、Sisyphus-Junior、oracle、Atlas 等）分类展示，含子代理嵌套费用。使用时机：用户问"花了多少 token"、"查一下 token"、"看看花费"、"token 查询"、"成本"、"费用"、"什么成员花的钱最多"、"token 统计"。
---

# Token Usage 查询 Skill

## 触发词
用户提到以下任一即加载此 skill：
- 花了多少 token / 查 token / 看看花费 / 成本 / 费用 / token 统计
- 查一下消费 / 各成员 token 消耗 / 哪个成员最贵 / 这次会话花了多少

## 工作流程

### 1. 获取会话 ID
- **当前会话**：调用 `tokenscope(includeSubagents=true)`，不传 sessionID 即分析当前会话
- **历史会话**：如果用户指定了具体会话，先调 `session_list` 或 `session_search` 查找对应的 sessionID，再传参

### 2. 运行分析
```js
tokenscope(includeSubagents=true)
// 或带 sessionID:
tokenscope(sessionID="ses_xxx", includeSubagents=true)
```

输出保存在 Temp 目录（`C:\Users\admin\AppData\Local\Temp\opencode\tokenscope-*.md`），需读取该文件。

### 3. 解析关键数据
读取生成的 markdown 文件，提取以下部分：

**SESSION SUMMARY** — 总 token、总费用、消息数
**AGENT BREAKDOWN** — Atlas/Prometheus 等工具执行者的工具调用统计
**SUBAGENT COSTS** — 子代理按类型聚合：
```
subagent_type       calls     total_tokens     total_cost
Sisyphus-Junior     34        76,577,181       $1.99
oracle              2         1,613,948        $0.64
```

### 4. 按角色分类展示

输出格式如下：

```
## Token 消耗报告：{会话 ID}

### 总览
- 总消费：{总 token}（${总费用}）
- 消息数：{N} 条
- 会话时长：{时长}

### 各成员明细

| 成员 | token | 费用 | 占比 | 建议模型 |
|---|---|---|---|---|
| **主对话**（Sisyphus/Prometheus/Hephaestus） | X | $Y | N% | 留 Flash |
| **Sisyphus-Junior**（子实现，不可见） | X | $Y | N% | 可切 MiniMax ✅ |
| **oracle**（子咨询） | X | $Y | N% | 留 Flash |
| **Atlas**（工具执行层） | X | $Y | N% | 可切 MiniMax ✅ |
| **合计** | **X** | **$Y** | **100%** | |

### 最大单次消耗
- 最高：Sisyphus-Junior ×1 = 10,410,749 tokens（JUCE 项目初始化）

### 省钱建议
- 推荐切 MiniMax：Sisyphus-Junior（省 $N, N%）、Atlas（省 $N, N%）
- 保留 Flash：主对话、oracle（需要强推理）
```
