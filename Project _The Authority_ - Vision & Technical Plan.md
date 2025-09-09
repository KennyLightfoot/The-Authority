# Project “The Authority” — The Living Blueprint (Clean v2)

**Framework:** Qbox
**Version:** 8.0 (Ship‑Ready)

---

## 1. The Core Concept (The Pitch)

**The Authority** is a GTA V roleplay server set in a **corporate dystopia**. The city is controlled by the monopolistic **Penrose Group**, which runs essential services. The core conflict is the struggle between this oppressive state and the players, who can either compete through a **player‑driven economy** or rebel via **purpose‑driven crime**.

* **Vibe:** Corporate Control vs. Urban Rebellion — every action carries political and economic weight.

---

## 2. Technical & Operational Specifications

### 2.1 Tech Stack & Architecture

* **Core Framework:** `qbx_core`
* **Core Libraries:** `ox_lib`, `ox_inventory`, `ox_target`
* **Essential Infrastructure:** `pma-voice`, `PolyZone`
* **Server Management:** `qbx_management` (admin), `txAdmin` (deployment)

### 2.2 Observability & Telemetry

* **Metrics/KPIs:** real‑time dashboard with: `onboarding_start/complete`, `paycheck_issued`, `money_change`, `heat_change`, `standing_change`, `robbery_start/end`, `arrest_made`, `crash`, `queue_join/leave`.
* **Audit Logs:** all critical actions (item/money transfers, stash access, arrests). **Retention:** hot 7 days / warm 30 days.

### 2.3 Security & Anti‑Exploit

* **Validation:** never trust client totals; recompute prices/quantities/payouts server‑side. Use **one‑shot tokens** for risky transactions.
* **Rate‑Limiting:** clamp money/inventory RPCs (default **3/sec** per source).
* **Sanity Checks:** log and terminate session if inventory counts go negative/overflow; validate job changes against permissions and cooldowns.

### 2.4 Performance Budget

* **Per resource:** ≤ **0.20 ms** (core), ≤ **0.05 ms** (minor); **alert** at **0.30 ms**.
* **Streaming:** ≤ **450 MB** in hub areas; unload distant MLOs; cull unused props/vehicles.
* **Tick Hosts:** batch VOIP range checks; debounce TextUI; avoid tight `while` loops.

---

## 3. Launch & Live Operations

### 3.1 Launch Readiness Runbook (Go/No‑Go)

**T‑3 Days**

* **Load Test:** 40–60 dummy clients → VOIP stability, resmon, inventory stress.
* **Economy Smoke Test:** 100× Mine→Smelt→Sell cycles to verify sinks and payouts.
* **Security Sweep:** manual checks for money/stash/shop dupes against server‑side validation.

**T‑24 Hours**

* **Code Freeze:** tag Release Candidate; lock non‑critical merges.
* **Backups:** full DB + configuration snapshot (tested restore).
* **Announcements:** maintenance window + first patch window.

**Rollback Plan**

* Keep previous tag + DB snapshot hot.
* Use **feature flags** (convars) to disable problematic features without full rollback.

### 3.2 Live‑Ops Calendar (First 30 Days)

* **Week 1 — Stability:** daily micro‑patches; curated social event (e.g., car meet).
* **Week 2 — Engagement:** two events (Penrose rally; underground race); first major balance pass; mini‑lore drop.
* **Week 3 — Systems:** enable first‑tier robberies; open first official social‑hub MLO.
* **Week 4 — Monetization:** launch **Resistance Pass: Season Zero** and two themed cosmetic packs.

---

## 4. Player Journey & Retention

### 4.1 Onboarding Flow (10‑Minute Target)

1. **Spawn & Path Choice:** at first login, player selects **Pioneer / Rebel / Undecided**.
2. **Guided First Loop:** auto‑waypoints guide one full **Mine → Smelt → Sell** cycle with TextUI prompts.
3. **Payday & Unlocks:** after first sale, issue paycheck; unlock **phone** and **tutorial index**.

### 4.2 Player Safety & Moderation

* **New‑Player Protection:** first **2 hours**: reduced damage; **no robberies** by other players.
* **Alt‑Abuse Guard:** Authority Standing & Heat bound to master account; rate‑limit character creation.
* **Soft Whitelist:** launch with a light application + onboarding quiz.

---

## 5. Core Gameplay & Narrative

### 5.1 Authority Standing System

* **Scale & Visibility:** **–100 (Dissident)** to **+100 (Loyalist)** shown on IDs and PSS databases; **daily decay** toward 0.
* **Sample Triggers:** paying taxes (+2), completing a Penrose contract (+5), felony conviction (−15).

### 5.2 Dynamic World Response (Heat 2.0)

* **District Heat:** crime raises heat → **checkpoints/curfews**; loyalist activity can grant **corporate bonuses**.
* **Signals:** billboards, dispatch chatter, and buff/nerf toggles driven by district thresholds.

### 5.3 “Season Zero” Launch Content

* **Theme:** *The Corporate Crackdown*.
* **Temporary Modifiers (2 weeks):** +15% Pioneer job payouts; +10% Rebel heat per felony; propaganda billboards active.
* **Rewards:** free track with two titles + one license plate style; paid **Resistance Pass** with six cosmetics.
* **Capstones:** scripted **Penrose parade** and a **dissident rally** on the first two weekends.

---

## 6. Community & Monetization

### 6.1 Community Growth

* **Server Trailer (45–60s):** showcase Pioneer vs. Rebel fantasy and UI polish.
* **Discord Funnels:** a clear **#start-here** → rules → reaction roles for path choice.
* **Creator Program:** whitelisted streamers with cosmetic codes and spotlight nights.

### 6.2 Monetization (Policy‑Safe)

* Use **Tebex** for any donations/cosmetics (Cfx.re policy).
* Launch **Resistance Pass** (Seasonal cosmetics), plus themed cosmetic packs tied to live events.
* Avoid pay‑to‑win; cosmetics and QoL only.

### 6.3 Post‑Launch Expansion (Phase 4)

* **Player‑Run Politics:** City Council/Mayorship with policy levers (taxes, subsidies) affecting in‑game variables.
* **Player‑Driven Media:** support in‑game news/radio; usable for propaganda or resistance.

---

## 7. Compliance, Policies & Ops Hygiene

* **Policies:** Code of Conduct, staff charter, appeal workflow.
* **Licensing:** maintain `/THIRDPARTY.md`; avoid GPL conflicts.
* **Data:** audit logs retained 30 days; telemetry 90 days; redact PII in public posts/screens.
* **Backups/DR:** nightly DB (35d), weekly snapshots (12w), quarterly restore rehearsal.
* **CI Gates:** LuaCheck, StyLua, fxmanifest validation, SQL dry‑run; PRs must not raise idle resmon by >0.05 ms.

---

## 8. Success Metrics (North‑Star KPIs)

* **Stability:** >99% uptime; **idle resmon** ≤0.20 ms per core resource.
* **Economy Health:** sinks\:sources ≥ **1.2:1**; median \$/hr within target band across starter jobs.
* **Retention:** D1 ≥ 45%, D7 ≥ 20%, D30 ≥ 10% (soft‑whitelist cohorts).
* **Engagement:** ≥2 curated events/week; ≥70% participation among online players.
* **Fair Play:** <1% incidents per 100 active users/week (post‑moderation).

---

## 9. Appendices

### A. Feature Flags (Convars)

```
set authority_anticheat_enabled true
set authority_onboarding_enabled true
set authority_protection_hours "2.0"
set authority_heat_enabled true
set authority_audit_webhook "https://discord.com/api/webhooks/..."
```

### B. Districts & Heat Thresholds (Starter)

* Thresholds: **Checkpoint** at 100 heat; **Curfew** at 200 heat.
* Global decay: **0.5 heat/min** toward 0.

### C. Golden‑Path QA (Pre‑Launch)

* Onboarding (choose path → Mine→Smelt→Sell → phone/tutorial unlock).
* Economy loops (Garbage, Mining, Mechanic, Taxi) → bank payouts only; no dupes.
* PD arrest → Court verdict → jail release (Standing/Heat hooks fire).
* Dealership purchase → keys/ownership saved → society credited.

---

> **Status:** This blueprint is production‑ready and aligned with your live‑ops cadence. It defines clear guardrails (security, performance, compliance), strong identity systems (Standing, Heat), and a practical path from stability → engagement → monetization without pay‑to‑win.
