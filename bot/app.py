"""
Databricks Genie Bot

Author: Luiz Carrossoni Neto
Revision: 1.0

This script implements an experimental chatbot that interacts with Databricks' Genie API,
which is currently in Private Preview. The bot facilitates conversations with Genie,
Databricks' AI assistant, through a chat interface.

Note: This is experimental code and is not intended for production use.
"""

import os
import json
import logging
from typing import Dict, List, Optional
#from dotenv import load_dotenv
from aiohttp import web
from botbuilder.core import ActivityHandler, TurnContext
from botbuilder.schema import ChannelAccount
from databricks.sdk import WorkspaceClient
from databricks.sdk.service.dashboards import GenieAPI
import asyncio
from botbuilder.integration.aiohttp import CloudAdapter, ConfigurationBotFrameworkAuthentication
from botbuilder.core.integration import aiohttp_error_middleware

# Log
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Env vars
#load_dotenv()
from config import DefaultConfig

DATABRICKS_SPACE_ID = os.getenv("DATABRICKS_SPACE_ID")
CONFIG = DefaultConfig()
# Only chats from the configured Tenant will be allowed
ALLOWED_TENANT = DefaultConfig.APP_TENANTID

workspace_client = WorkspaceClient()

genie_api = GenieAPI(workspace_client.api_client)

async def ask_genie(question: str, space_id: str, conversation_id: Optional[str] = None) -> tuple[str, str]:
    try:
        loop = asyncio.get_running_loop()
        if conversation_id is None:
            initial_message = await loop.run_in_executor(None, genie_api.start_conversation_and_wait, space_id, question)
            conversation_id = initial_message.conversation_id
        else:
            initial_message = await loop.run_in_executor(None, genie_api.create_message_and_wait, space_id, conversation_id, question)

        query_result = None
        if initial_message.query_result is not None:
            query_result = await loop.run_in_executor(None, genie_api.get_message_query_result,
                space_id, initial_message.conversation_id, initial_message.id)

        message_content = await loop.run_in_executor(None, genie_api.get_message,
            space_id, initial_message.conversation_id, initial_message.id)

        if query_result and query_result.statement_response:
            results = await loop.run_in_executor(None, workspace_client.statement_execution.get_statement,
                query_result.statement_response.statement_id)
            
            query_description = ""
            for attachment in message_content.attachments:
                if attachment.query and attachment.query.description:
                    query_description = attachment.query.description
                    break

            return json.dumps({
                "columns": results.manifest.schema.as_dict(),
                "data": results.result.as_dict(),
                "query_description": query_description
            }), conversation_id

        if message_content.attachments:
            for attachment in message_content.attachments:
                if attachment.text and attachment.text.content:
                    return json.dumps({"message": attachment.text.content}), conversation_id

        return json.dumps({"message": message_content.content}), conversation_id
    except Exception as e:
        logger.error(f"Error in ask_genie: {str(e)}")
        return json.dumps({"error": "An error occurred while processing your request."}), conversation_id

def process_query_results(answer_json: Dict) -> str:
    response = ""
    if "query_description" in answer_json and answer_json["query_description"]:
        response += f"## Query Description\n\n{answer_json['query_description']}\n\n"

    if "columns" in answer_json and "data" in answer_json:
        response += "## Query Results\n\n"
        columns = answer_json["columns"]
        data = answer_json["data"]
        if isinstance(columns, dict) and "columns" in columns:
            header = "| " + " | ".join(col["name"] for col in columns["columns"]) + " |"
            separator = "|" + "|".join(["---" for _ in columns["columns"]]) + "|"
            response += header + "\n" + separator + "\n"
            for row in data["data_array"]:
                formatted_row = []
                for value, col in zip(row, columns["columns"]):
                    if value is None:
                        formatted_value = "NULL"
                    elif col["type_name"] in ["DECIMAL", "DOUBLE", "FLOAT"]:
                        formatted_value = f"{float(value):,.2f}"
                    elif col["type_name"] in ["INT", "BIGINT", "LONG"]:
                        formatted_value = f"{int(value):,}"
                    else:
                        formatted_value = str(value)
                    formatted_row.append(formatted_value)
                response += "| " + " | ".join(formatted_row) + " |\n"
        else:
            response += f"Unexpected column format: {columns}\n\n"
    elif "message" in answer_json:
        response += f"{answer_json['message']}\n\n"
    else:
        response += "No data available.\n\n"
    
    return response

ADAPTER = CloudAdapter(ConfigurationBotFrameworkAuthentication(CONFIG))

class MyBot(ActivityHandler):
    def __init__(self):
        self.conversation_ids: Dict[str, str] = {}

    async def on_message_activity(self, turn_context: TurnContext):
        question = turn_context.activity.text
        user_id = turn_context.activity.from_property.id
        conversation_id = self.conversation_ids.get(user_id)
        tennantId = turn_context.activity.channel_data.get("tenant", {}).get("id", "")
        if tennantId == ALLOWED_TENANT:
            try:
                answer, new_conversation_id = await ask_genie(question, DATABRICKS_SPACE_ID, conversation_id)
                self.conversation_ids[user_id] = new_conversation_id

                answer_json = json.loads(answer)
                response = process_query_results(answer_json)

                await turn_context.send_activity(response)
            except json.JSONDecodeError:
                await turn_context.send_activity("Failed to decode response from the server.")
            except Exception as e:
                logger.error(f"Error processing message: {str(e)}")
                await turn_context.send_activity("An error occurred while processing your request.")
        else:
            await turn_context.send_activity("Your Tenant is not authorized to use this Bot.")

    async def on_members_added_activity(self, members_added: List[ChannelAccount], turn_context: TurnContext):
        tennantId = "" if turn_context.activity.channel_data is None else turn_context.activity.channel_data.get("tenant", {}).get("id", "")
        if tennantId == ALLOWED_TENANT:
            welcome_message = "Bienvenido a Genie Bot!"
        else:
            welcome_message = "Your Tenant is not authorized to use this Bot."
        for member in members_added:
            if member.id != turn_context.activity.recipient.id:
                await turn_context.send_activity(welcome_message)

BOT = MyBot()

async def messages(req: web.Request) -> web.Response:
    if "application/json" not in req.headers["Content-Type"]:
        return web.Response(status=415)
    try:
        response = await ADAPTER.process(req, BOT)
        if response:
            return web.json_response(data=response.body, status=response.status)
        return web.Response(status=201)
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        # Print the exception type and message
        logger.error(f"Exception Type: {type(e).__name__}")
        logger.error(f"Exception Message: {e}")
        return web.Response(status=500)

APP = web.Application(middlewares=[aiohttp_error_middleware])
APP.router.add_post("/api/messages", messages)

if __name__ == "__main__":
    try:
        host = os.getenv("HOST", "localhost")
        port = int(os.environ.get("PORT", 3978))
        web.run_app(APP, host=host, port=port)
    except Exception as error:
        logger.exception("Error running app")
