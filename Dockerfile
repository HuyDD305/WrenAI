FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    WREN_HOME=/wren-home \
    PATH="/app/.venv/bin:$PATH"

# System deps for native connectors (psycopg, mysqlclient, pyodbc, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        libpq-dev \
        default-libmysqlclient-dev \
        unixodbc-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Deps layer — rebuilt only when lock file changes
COPY core/wren/pyproject.toml core/wren/uv.lock ./
RUN uv sync --frozen --extra main --no-install-project

# Source layer
COPY core/wren/ .
RUN uv sync --frozen --extra main

# Profile UI helper (binds to 0.0.0.0 for Docker)
COPY scripts/profile_ui_server.py /usr/local/bin/profile_ui_server.py

VOLUME ["/wren-home"]

ENTRYPOINT ["wren"]
CMD ["--help"]
