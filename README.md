# Romestead Dedicated Server (Multi-Stage Docker Setup)

A highly optimized, production-grade, and secure Docker setup to run a **Romestead Dedicated Server**.

This project implements a **multi-stage Dockerfile** using an ultra-secure, rootless **Ubuntu Chiseled** runtime. It isolates the download process (via SteamCMD) from the actual runtime environment (.NET 8), creating an extremely minimal footprint with zero shell vulnerabilities.

## Features
* **Multi-Stage Build:** Clean separation of SteamCMD download tools from the final .NET runtime layer.
* **Distroless & Rootless Security:** Runs on a chiseled Microsoft image using a non-root `app` user with no interactive shell.
* **Globalization Fix:** Built-in environment flag to prevent crashes caused by the GameAnalyticsSDK culture requirements (`en-US`).
* **Hands-Free Auto-Start:** Automated server boot bypassing interactive console menus using `config.json`.

---

## Prerequisites
* **Docker Desktop** (Windows / macOS) or **Docker Engine** (Linux)
* **WSL 2** (if running on a Windows host machine)

---

## Project Structure
Maintain the following file layout in your local project root directory:

```text
.
├── Dockerfile
├── docker-compose.yml
├── config.json
├── default_config.json  # Internal fallback baked into the image
└── saved_worlds/        # Persistent world data directory
```

---

## Configuration Files

### 1. `config.json`
To allow the server to boot completely unattended in the background, a valid configuration file must be present. **Note:** The `"Password"` parameter must not be `null`. Setting it to `null` forces the server to halt and wait for a manual interactive input. Use `""` for a server with no password.

### 2. `Dockerfile`
The build definition uses `cm2network/steamcmd:latest` as a build pipeline, then copies the game files to a hardened, non-root environment:

### 3. `docker-compose.yml`
Binds the necessary UDP game ports and maps persistent directories. Keeping `stdin_open` and `tty` active is mandatory; otherwise, Romestead detects a closed pipeline and instantly force-saves and shuts down.

---

## Usage & Management

### Build and Start (Interactive Foreground)
To watch the full initialization sequence directly in your current console session:
```bash
docker compose up --build
```

### Build and Start (Background Mode)
To run the server quietly in the background as a system service:
```bash
docker compose up -d
```

### View Live Server Output
If running in background mode, you can follow the server logs (player connections, world saves, etc.) using:
```bash
docker compose logs -f
```
*(Press `CTRL + C` to safely unhook your terminal view; the server remains running in the background).*

### Hard Troubleshooting (Direct Terminal Run)
Because Chiseled-images do not have an internal Linux shell, traditional `docker attach` methods for input interaction might behave rigidly depending on your Docker Compose multiplexer. If you ever need a fully unbuffered, raw TTY connection to interact with the server CLI manually, bypass compose and spin it up directly:
```bash
docker run -it --name test_server -p 8050:8050/udp -v ./saved_worlds:/app/server/saved_worlds -v ./config.json:/app/server/config.json container-romestead-server
```

### Safe Shutdown
To securely save the current game world state and shut down the container service smoothly:
```bash
docker compose down
```
