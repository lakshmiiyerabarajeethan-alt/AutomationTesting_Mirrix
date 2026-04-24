============================================================
  Mirrix — Playwright Codegen Output Folder
============================================================

HOW TO USE:
  1. Run:  npx playwright codegen https://dev.mirrix.app/login
  2. Perform the workflow you want to automate in the browser
  3. Copy the generated TypeScript code from the Playwright Inspector
  4. Paste it into a new .ts file in THIS folder
     e.g.  codegen\upload_workflow.ts
           codegen\search_workflow.ts
           codegen\collections_workflow.ts
  5. Run:
       python generate_tests.py --input codegen\upload_workflow.ts

  The generator will create:
     pages\{page}_page.robot
     tests\{page}_tests.robot

NAMING CONVENTION:
  {feature}_workflow.ts   e.g. upload_workflow.ts
                               search_workflow.ts
                               login_workflow.ts
                               collections_workflow.ts

NOTE: .ts files in this folder are committed to git so the
      team can see what each test was generated from.
============================================================
