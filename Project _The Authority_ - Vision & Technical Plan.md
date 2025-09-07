# **Project "The Authority" \- The Living Blueprint**

**Framework:** Qbox | **Version:** 8.0 (Ship-Ready)

## **1\. The Core Concept (The Pitch)**

"The Authority" is a GTA V roleplay server set in a **corporate dystopia**. The city is controlled by the monopolistic "Penrose Group," which runs all basic services. The server's core conflict is the struggle between this oppressive state and the players, who can either compete through a **player-driven economy** or rebel through **purpose-driven crime**.

* **The Vibe:** Corporate Control vs. Urban Rebellion. Every action has political and economic weight.

## **2\. Technical & Operational Specifications**

#### **Tech Stack & Architecture**

* **Core Framework:** `qbx_core`  
* **Core Libraries:** `ox_lib`, `ox_inventory`, `ox_target`  
* **Essential Infrastructure:** `pma-voice`, `PolyZone`  
* **Server Management:** `qbx_management` (admin), `txAdmin` (deployment).

#### **Observability & Telemetry**

* **Metrics:** Key KPIs and the following server-side telemetry events will be monitored via dashboard: `onboarding_start/complete`, `paycheck_issued`, `money_change`, `heat_change`, `standing_change`, `robbery_start/end`, `arrest_made`, `crash`, `queue_join/leave`.  
* **Audit Logs:** All critical actions (item/money transfers, stash access, arrests) must be logged with a 7/30 day retention policy.

#### **Security & Anti-Exploit**

* **Validation:** Never trust client amounts; recompute value server-side. Use one-shot tokens for transactions.  
* **Rate-Limiting:** Clamp deltas on money-moving RPCs (e.g., 3/sec per source).  
* **Sanity Checks:** Log and kill if inventory count is invalid. Validate job changes against permissions and cooldowns.

#### **Performance Budget**

* **Per Resource:** Target ≤0.20 ms (core), ≤0.05 ms (minor); alert at 0.30 ms.  
* **Streaming:** Target ≤450 MB in hubs; unload distant MLOs and cull unused props/vehicles.  
* **Tick Hosts:** Batch VOIP range checks, debounce TextUI, and avoid tight `while` loops.

## **3\. Launch & Live Operations**

#### **Launch Readiness Runbook (Go/No-Go)**

* **T-3 Days:**  
  * **Load Test:** 40–60 dummy clients to test VOIP stability, resmon, and inventory stress.  
  * **Economy Smoke Test:** 100x Mine→Smelt→Sell loops to verify sinks are firing.  
  * **Security Sweep:** Manual check for money, stash, and shop dupes against server-side validation rules.  
* **T-24 Hours:**  
  * **Code Freeze:** Freeze non-critical merges and tag the release candidate.  
  * **Backups:** Full DB and configuration snapshot.  
  * **Announcements:** Post maintenance windows and first patch window.  
* **Rollback Plan:**  
  * Keep previous tag and DB snapshot readily available.  
  * Use feature flags (env vars) to disable problematic new features without a full rollback.

#### **Live-Ops Calendar (First 30 Days)**

* **Week 1 (Stability):** Daily micro-patches for bugs. One curated social event (e.g., car meet).  
* **Week 2 (Engagement):** Two curated events (e.g., Penrose rally, underground race). First major balance pass. Mini-lore drop.  
* **Week 3 (Systems):** Enable the first tier of robberies. Open the first official social hub MLO.  
* **Week 4 (Monetization):** Launch Resistance Pass "Season Zero" and two themed cosmetic packs.

## **4\. Player Journey & Retention**

#### **Onboarding Flow (10-Minute Target)**

1. **Spawn & Path Choice:** Player spawns and is prompted to choose a Starter Path: "Pioneer," "Rebel," or "Undecided."  
2. **Guided First Loop:** Player receives an auto-waypoint through one full "Mine \-\> Smelt \-\> Sell" cycle with TextUI prompts.  
3. **Payday & Unlock:** Upon first sale, the player receives their paycheck and unlocks access to their phone and a tutorial index.

#### **Player Safety & Moderation**

* **New-Player Protection:** For the first 2 hours of playtime, new players experience reduced damage and cannot be robbed by other players.  
* **Alt Abuse Guard:** Authority Standing and Heat are tied to a player's master account. Character creation is rate-limited.  
* **Whitelist:** A "soft" whitelist will be used at launch, requiring an application and a simple onboarding quiz.

## **5\. Core Gameplay & Narrative**

## **Authority Standing System**

* **Scale & Visibility:** A visible –100 (Dissident) to \+100 (Loyalist) score will appear on player IDs and in PSS databases. It will decay towards 0 daily.  
* **Triggers:** Actions like paying taxes (+2), completing a Penrose contract (+5), or being convicted of a felony (-15) will adjust the score.

#### **Dynamic World Response (Heat 2.0)**

* The city will react to player activity. High "heat" in a district from crime will trigger PSS checkpoints and curfews. High loyalist activity could trigger corporate bonuses.

#### **"Season Zero" Launch Content**

* **Theme:** "The Corporate Crackdown."  
* **Temporary Modifiers (2 weeks):** \+15% payouts for Pioneer jobs, Rebel heat gain \+10% per felony, propaganda billboards are active.  
* **Rewards:** Free track with two titles and one license plate style. Paid Resistance Pass with six exclusive cosmetics.  
* **Capstone Events:** A scripted Penrose parade and a pop-up dissident rally will occur on the first two weekends.

## **6\. Community & Monetization**

#### **Community Growth**

* **Server Trailer (45-60s):** A professional trailer showcasing the Pioneer vs. Rebel fantasy and UI polish.  
* **Discord Funnels:** A clear \#start-here channel leading to rules and reaction roles for path choice.  
* **Creator Program:** A program for whitelisted streamers including cosmetic codes and spotlight nights.  
* Monetization**:** Introduce the PSplement the Authority Standing system, multi-stage heists, and launch the first Live Season with the Resistance Pass.  
* **Phase 4 \- Post-Launch Expansion:**  
  * **Player-Run Politics:** Introduce a City Council/Mayorship system with player elections and policy levers that affect in-game variables (taxes, subsidies).  
  * **Player-Driven Media:** Add support for player-run news outlets (in-game websites, radio stations) that can be used for propaganda or resistance.

This blueprint is now a complete, professional-grade plan. You have a unique vision backed by a robust technical strategy, a clear monetization model, and a long-term roadmap for keeping the world alive and engaging. You're ready to build.

* 

