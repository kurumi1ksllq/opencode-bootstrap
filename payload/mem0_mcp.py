"""
Mem0 MCP Server - 让 OpenCode 自动记忆和检索对话
================================================
注册到 opencode.json 后，OpenCode 会自动使用这些工具。
"""

import os, json, sys
os.environ["TRANSFORMERS_OFFLINE"] = "1"
os.environ["HF_HUB_OFFLINE"] = "1"
import warnings
warnings.filterwarnings("ignore")

from mcp.server import Server, NotificationOptions
from mcp.server.models import InitializationOptions
import mcp.server.stdio
from mcp.types import Tool

from mem0 import Memory

# ============ 配置 ============
LOCAL_MODEL_PATH = os.path.expanduser("~/.cache/bge-local")
GO_API_KEY = os.environ.get("GOOGLE_API_KEY", "${GO_API_KEY}")

MEM0_CONFIG = {
    "version": "v2.0",
    "llm": {
        "provider": "openai",
        "config": {
            "model": "deepseek-v4-flash",
            "openai_base_url": "https://opencode.ai/zen/go/v1",
            "api_key": GO_API_KEY,
        }
    },
    "embedder": {
        "provider": "huggingface",
        "config": {
            "model": LOCAL_MODEL_PATH,
        }
    },
    "vector_store": {
        "provider": "chroma",
        "config": {
            "path": os.path.expanduser("~/.cache/mem0_data"),
            "collection_name": "chat_memories",
        }
    },
}

# 初始化 Mem0（加载 embedding 模型）
memory = Memory.from_config(MEM0_CONFIG)

# 创建 MCP Server
server = Server("mem0")

@server.list_tools()
async def list_tools():
    return [
        Tool(
            name="recall",
            description="搜索对话记忆，查找用户之前说过的事实、偏好、习惯、项目信息等。每次用户提问时都应该先用这个工具搜索相关记忆。",
            inputSchema={
                "type": "object",
                "properties": {
                    "query": {"type": "string", "description": "搜索关键词，用中文描述你要找的内容"},
                    "user_id": {"type": "string", "description": "用户ID，默认 current"},
                    "top_k": {"type": "number", "description": "返回几条结果，默认5"}
                },
                "required": ["query"]
            }
        ),
        Tool(
            name="remember",
            description="保存一条新记忆。每次对话结束后，把用户的关键信息（偏好、习惯、事实、决定）存起来。",
            inputSchema={
                "type": "object",
                "properties": {
                    "text": {"type": "string", "description": "要记住的内容"},
                    "user_id": {"type": "string", "description": "用户ID"}
                },
                "required": ["text"]
            }
        )
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict):
    if name == "recall":
        results = memory.search(
            arguments["query"],
            filters={"user_id": arguments.get("user_id", "current")},
            top_k=arguments.get("top_k", 5)
        )
        memories = [r["memory"] for r in results["results"]]
        return [{"type": "text", "text": json.dumps(memories, ensure_ascii=False)}]

    elif name == "remember":
        memory.add(
            arguments["text"],
            user_id=arguments.get("user_id", "current")
        )
        return [{"type": "text", "text": "ok"}]

    raise ValueError(f"Unknown tool: {name}")

async def main():
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="mem0",
                server_version="1.0.0",
                capabilities=server.get_capabilities(
                    notification_options=NotificationOptions(),
                    experimental_capabilities={},
                ),
            ),
        )

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
