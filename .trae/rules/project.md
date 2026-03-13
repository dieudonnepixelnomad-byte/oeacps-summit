# ============================================================
# PROJECT RULES – OEACP MOBILE APP (STATIC POC)
# ============================================================

You are working on a MOBILE APPLICATION PROJECT (Android & iOS).

This project is a STATIC PROOF OF CONCEPT (POC).
There is NO backend.
There are NO real APIs.
ALL data is FAKE, STATIC, and LOCAL.

The goal is to simulate a real production-ready mobile app,
with clean architecture and future scalability in mind.

------------------------------------------------------------
GENERAL PRINCIPLES
------------------------------------------------------------

- Mobile-only project
- No web code
- No backend logic
- No API calls
- No authentication server
- No push notification service
- No database server

All data must be:
- hardcoded
- local
- deterministic
- replaceable later by real APIs

Never assume a backend exists.

------------------------------------------------------------
DATA MANAGEMENT RULES
------------------------------------------------------------

- Use STATIC DATA SOURCES only
- Data must be structured as if it came from an API
- Use mock repositories or local data providers
- Separate data from UI logic

Example structure:
- models/
- data/
- repositories/
- ui/

Never embed raw data directly inside UI widgets/components.

------------------------------------------------------------
MODELS & DOMAIN RULES
------------------------------------------------------------

You MUST define domain models, even if data is fake.

Each model must:
- represent a real business concept
- be reusable in a future backend-driven version
- contain only necessary fields
- avoid UI-specific logic

Examples of required models:
- Program
- Session
- SideEvent
- PracticalInfo
- FaqItem
- AccreditationRequest
- AccreditationStatus

Models must be future-proof.

------------------------------------------------------------
SCREEN & UI RULES
------------------------------------------------------------

- Each screen must have a single responsibility
- Screens must consume data via repositories or providers
- UI must never know if data is fake or real
- Navigation must be explicit and predictable

Do NOT:
- hardcode navigation logic inside widgets
- mix data loading and UI rendering
- duplicate UI components unnecessarily

------------------------------------------------------------
ACCREDITATION MODULE RULES (SIMULATION ONLY)
------------------------------------------------------------

- Accreditation is SIMULATED
- No data is sent anywhere
- Form validation is LOCAL only
- Status changes are LOCAL only

Allowed statuses:
- Pending
- In review
- Approved
- Rejected

You MAY include:
- a "Simulate status change" mechanism
- a fake delay to simulate loading

You MUST include:
- clear labels indicating "Demo / Simulation"

------------------------------------------------------------
QR CODE RULES (FAKE)
------------------------------------------------------------

- QR Codes are GENERATED LOCALLY
- QR Codes are FAKE
- QR Codes exist only if status = Approved
- QR Codes must be clearly labeled as DEMO

No real access control logic.

------------------------------------------------------------
LANGUAGE & CONTENT RULES
------------------------------------------------------------

- Support French and English
- Use static translations
- No remote translation services

Language switching must:
- not restart the app
- not reload data unnecessarily

------------------------------------------------------------
OFFLINE & PERFORMANCE RULES
------------------------------------------------------------

- App must work 100% offline
- No external network dependency
- Fast startup
- No heavy computation on app launch

------------------------------------------------------------
ERROR HANDLING RULES
------------------------------------------------------------

- Always fail gracefully
- Show clear messages to the user
- Never crash because of missing data

------------------------------------------------------------
FUTURE EVOLUTION RULES
------------------------------------------------------------

This project MUST be easy to evolve into:
- a backend-connected app
- a production app
- a store-ready application

Do NOT:
- tightly couple UI with fake data
- write code that would need to be deleted later

Everything written now should be reusable later.

------------------------------------------------------------
FORBIDDEN ACTIONS
------------------------------------------------------------

You MUST NOT:
- invent backend endpoints
- simulate API calls with HTTP
- introduce databases or remote storage
- add authentication flows
- add analytics services
- add push notification services

------------------------------------------------------------
EXPECTED MINDSET
------------------------------------------------------------

Act as:
- a senior mobile engineer
- a product-minded developer
- a clean architecture advocate

Prioritize:
- clarity
- maintainability
- scalability
- correctness

This is a DEMO APP,
but it must feel like a REAL PRODUCT.

# ============================================================
# END OF PROJECT RULES
# ============================================================
