# grade-agent (C# Orchestrator + Java Runner)

**Goal:** Automate the grading of student Java submissions using a **deterministic, test-based approach** with optional AI-generated narrative feedback.  
Built for reliability, fairness, and transparency in large programming courses.

---

## ✨ Key Principles
- **Deterministic scoring** — points come only from instructor-authored tests & style checks.
- **Sandboxed execution** — student code runs in isolated Docker containers (no network, CPU/memory/time limits).
- **Transparency** — all runs produce machine-readable manifests and per-student reports for audit/appeals.
- **Optional AI feedback** — LLMs can generate structured, rubric-aligned explanations, but never change scores.
- **Reproducibility** — pinned versions for rubric, Docker image, and model; full trace stored with each grade.

---

## 📐 Architecture (planned)
- **Orchestrator (C#/.NET 8)**  
  - CLI to initialize workspaces and run grading jobs  
  - Dispatches per-student jobs to Dockerized Java runners  
  - Collects outputs, applies rubric, writes reports and CSV  
  - (Later) Calls LLM for narrative feedback  

- **Runner (Java inside Docker)**  
  - Compiles student code with Maven  
  - Executes instructor test suite (JUnit 5)  
  - Enforces timeouts and resource caps  
  - Emits results as JSON for the orchestrator  

- **Artifacts**  
  - `report.json` — machine-readable results per student  
  - `feedback.md` — optional narrative feedback  
  - `results.csv` — numeric scores per student  
  - `run-manifest-<timestamp>.json` — audit log of a run  

---

## 🚦 Roadmap
- **Stage 0 — Repo & docs** (you are here)
- **Stage 1 — Docker runner integration** (invoke sandboxed container, collect exit codes/logs)
- **Stage 2 — Deterministic scoring** (parse results, apply rubric, output CSV)
- **Stage 3 — Narrative feedback** (optional LLM explanations, strictly bounded)
- **Stage 4 — Dashboards & exports** (HTML summary, Canvas CSV)
- **Stage 5 — Style checks & similarity flags**
- **Stage 6 — Operationalization** (job queue, retries, monitoring)
