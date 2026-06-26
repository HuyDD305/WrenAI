"""Start the Wren profile-creation UI bound to 0.0.0.0 for Docker.

Wraps profile_web.create_app() and replaces the hardcoded 127.0.0.1
host so the form is reachable from outside the container.

Environment variables:
  WREN_PROFILE_NAME  — profile name to create (default: "default")
  WREN_UI_PORT       — port to listen on (default: 8080)
"""

from __future__ import annotations

import asyncio
import os

import uvicorn

from wren.profile_web import create_app

profile_name = os.environ.get("WREN_PROFILE_NAME", "default")
port = int(os.environ.get("WREN_UI_PORT", "8080"))

app, _result, server_ref = create_app(profile_name, activate=True)

config = uvicorn.Config(app, host="0.0.0.0", port=port, log_level="info")
server = uvicorn.Server(config)
server_ref.append(server)

print(f"Wren profile UI → http://0.0.0.0:{port}  (profile: {profile_name!r})", flush=True)
asyncio.run(server.serve())
