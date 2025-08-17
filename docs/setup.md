# Setup & Environment Verification

This project ships with a reproducible development environment using a **Dev Container** (Docker-based). After cloning, you can open the repo in a container and automatically verify the toolchain and guardrails. Using the dev container is recommended, but not required.

---

## 1) Prerequisites

Choose one of the two approaches below.

### Option A — Dev Container (recommended)
- **Docker**: Docker Desktop (Windows/macOS) or Docker Engine (Linux)
- **VS Code** with the **Dev Containers** extension  
  *(Alternative: `@devcontainers/cli` if you don’t use VS Code)*

### Option B — Host (no container)
Install these locally:
- **.NET SDK**: 8.0.x  
- **Java**: OpenJDK **21**  
- **Maven**: 3.9.x  
- **Docker CLI** (optional for later steps)

> If you work on the host, you’re responsible for matching versions. The dev container pins them for you.

---

## 2) Open in the Dev Container

1. **Clone** the repo.
2. In VS Code:  
   - Command Palette → **Dev Containers: Rebuild and Reopen in Container**.  
   - VS Code will build the image defined in `.devcontainer/` and open a shell **inside** the container.
3. On first start, a post-create check prints versions and a quick container smoke test.

**What a successful start looks like**
- You see `.NET 8`, `Java 21`, and `Maven 3.9.x` versions printed.
- If Docker is available in the container (optional), a “no-network” test prints `no-network`.

---

## 3) Verifying Your Environment Manually

Inside the dev container **terminal**:

```bash
dotnet --info | head -n 20
java -version
mvn -v
```

Expected:
- `.NET SDK` shows **8.0.x**
- `java` shows **21**
- `mvn` shows **3.9.x**

If you mounted the host Docker socket later (see “Docker access in container” below), you can also check:

```bash
docker run --rm --network=none alpine:3.20 sh -c 'id -u; (wget -qO- http://example.com || echo no-network)'
```

Expected:
- A numeric UID prints (non-root user)
- `no-network` prints (egress blocked)

---

## 4) Working Without VS Code

If you don’t use VS Code, you can still use the same container:

```bash
# one-time
npm i -g @devcontainers/cli

# from repo root
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . bash -lc 'dotnet --info && java -version && mvn -v'
```

You can then attach any editor/IDE to the container’s filesystem and shell.

---

## 5) Host-Only Setup (no container)

Install the toolchain yourself:

- **.NET SDK** 8.0.x → https://dotnet.microsoft.com/download
- **OpenJDK 21** → your OS package manager or Adoptium/Temurin builds
- **Maven 3.9.x** → package manager or Apache Maven tarball
- **Docker** (optional for later steps)

Verify:

```bash
dotnet --info | head -n 20
java -version
mvn -v
docker --version   # optional
```

---

## 6) Docker Access in the Dev Container (optional, later)

By default, the dev container does **not** need to run Docker.  
When you’re ready to orchestrate student job containers **from inside** the dev container:

1. **Mount the host Docker socket** in `.devcontainer/devcontainer.json`:
   ```json
   "mounts": [
     "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind"
   ]
   ```
2. Ensure the container has the **Docker CLI** (`docker-cli`) installed.  
3. Rebuild: Command Palette → **Dev Containers: Rebuild and Reopen in Container**.  
4. Validate:
   ```bash
   docker version
   docker run --rm --network=none alpine:3.20 sh -c 'echo ok'
   ```

> On Linux hosts: your user must be in the `docker` group (`sudo usermod -aG docker $USER`, sign out/in).

---

## 7) CI Environment Contract

This repo includes a GitHub Actions workflow that verifies the expected toolchain on every PR (no secrets required).  
Check the **Actions** tab to see green checks for:
- .NET 8 setup
- Java 21 setup
- Maven available
- (Optional) a no-network container smoke test

---

## 8) Troubleshooting

- **“An error occurred in setting up the container”**
  - Use: Command Palette → **Dev Containers: Show Container Log**
  - Common causes:
    - Docker daemon not running or permission denied
    - Windows: Docker Desktop not using **WSL 2**; repo opened from a Windows path instead of WSL path
    - Corporate proxy blocking apt/curl downloads
    - Low disk space for Docker layers

- **Package install failures during build**
  - Use `openjdk-21-jdk` instead of Temurin if Temurin repos aren’t configured.
  - For Maven tarballs, use Apache **archive** URLs if `downloads.apache.org` 404s.

- **VS Code shows template picker**
  - You opened the wrong command. Use **“Rebuild and Reopen in Container”** (not “Add Dev Container Configuration Files…”).
  - Ensure `.devcontainer/devcontainer.json` exists at the repo root.

- **Leave the container view**
  - Command Palette → **Dev Containers: Reopen Folder Locally**

---

## 9) What “Ready to Contribute” Means

- You can run:
  ```bash
  dotnet --info | head -n 20
  java -version
  mvn -v
  ```
- (Optional) You can start a container with `--network=none` and see `no-network`.
- CI passes on your branch/PR.

That’s it — your environment matches the project’s contract.
