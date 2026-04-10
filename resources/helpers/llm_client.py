import os
import json
import re
from pathlib import Path
from dotenv import load_dotenv
import httpx

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

if not OPENAI_API_KEY:
    raise RuntimeError(
        "OPENAI_API_KEY not set. "
        "Ensure it exists in your .env file or environment variables."
    )

DEFAULT_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
FALLBACK_MODELS = [
    m.strip()
    for m in os.getenv("OPENAI_FALLBACK_MODELS", "gpt-4.1-mini,gpt-4o-mini,gpt-4o").split(",")
    if m.strip()
]

# ── Paths ──────────────────────────────────────────────────────────────────────
ROOT_DIR  = Path(__file__).resolve().parents[2]
PAGES_DIR = ROOT_DIR / "pages"
TESTS_DIR = ROOT_DIR / "tests"

# ── System prompt ──────────────────────────────────────────────────────────────
SYSTEM_PROMPT = """You are an expert Robot Framework automation engineer
specialising in the robotframework-browser (Playwright) library.

IMPORTANT: Respond ONLY with a valid JSON object — no markdown, no preamble.

Given Playwright TypeScript codegen output, produce a Robot Framework
Page Object Model (POM) keyword file and a test file.

Return this exact JSON structure:
{
  "page_name": "string — lowercase_snake_case (e.g. upload, search, login)",
  "description": "string — one-line description of the workflow",
  "variables": [
    { "name": "UPPER_SNAKE_CASE", "value": "default_value_string" }
  ],
  "pom_keywords": [
    {
      "name": "string — PascalCase keyword name",
      "arguments": ["${arg1}"],
      "steps": [
        "string — one Robot Framework Browser library step per entry"
      ]
    }
  ],
  "test_cases": [
    {
      "name": "string — human-readable test case name",
      "tags": ["tag1", "tag2"],
      "steps": [
        "string — one Robot Framework step per entry (calls POM keywords)"
      ]
    }
  ]
}

Playwright → Robot Framework Browser library selector mapping:
  getByRole('button',  {name:'X'})  → role=button[name="X"]
  getByRole('textbox', {name:'X'})  → role=textbox[name="X"]
  getByRole('cell',    {name:'X'})  → role=cell[name="X"]
  getByRole('link',    {name:'X'})  → role=link[name="X"]
  getByText('X', {exact:true})      → text=X
  getByText('X')                    → text=X
  locator('.cls')                   → css=.cls
  locator('css')                    → css=css
  .nth(n)                           → >> nth=n
  .first()                          → >> nth=0
  .fill('val')                      → Fill Text    <selector>    <value>
  .click()                          → Click    <selector>
  .setInputFiles('path')            → Upload File By Selector    css=input[type="file"]    ${FILE_PATH}
  .press('Enter')                   → Press Keys    <selector>    Enter
  expect/waitForSelector            → Wait For Elements State    <selector>    visible    timeout=${TIMEOUT}

Rules:
- Group logically related Playwright steps into one PascalCase POM keyword
- Extract every hardcoded string (file names, descriptions, tags, IDs) as a variable
- Test cases MUST call POM keywords — not raw Browser steps
- Every test file must have:
    Suite Setup     Run Keywords    Open Browser Session    AND    Login To Mirrix
    Suite Teardown  Close All Browsers
    Test Teardown   Take Screenshot On Failure
- Every POM file must import:
    Library     Browser
    Resource    ../resources/keywords/common_keywords.robot
    Resource    ../resources/variables/common_variables.robot
- Reuse ${TIMEOUT}, ${USERNAME}, ${PASSWORD} from common_variables.robot — never hardcode them
- For file uploads use: Upload File By Selector    css=input[type="file"]    ${FILE_PATH}
- For dropdowns use: Click    <selector> then Click    text=${VARIABLE}
- For tag inputs use: Fill Text    role=textbox >> nth=1    ${TAG} then Press Keys    role=textbox >> nth=1    Enter
"""


# ── Model helpers (mirrors the document generator pattern) ─────────────────────
def _candidate_models(requested_model: str | None = None) -> list[str]:
    candidates: list[str] = []
    for m in [requested_model, DEFAULT_MODEL, *FALLBACK_MODELS]:
        if m and m not in candidates:
            candidates.append(m)
    return candidates


def _is_model_access_error(status_code: int, data: dict | str) -> bool:
    if status_code not in (400, 404):
        return False
    if not isinstance(data, dict):
        return False
    error = data.get("error", {}) if isinstance(data.get("error", {}), dict) else {}
    code    = str(error.get("code",    "")).lower()
    message = str(error.get("message", "")).lower()
    return (
        code == "model_not_found"
        or "does not exist or you do not have access to it" in message
    )


# ── Robot Framework file builder ───────────────────────────────────────────────
def _indent(lines: list[str], spaces: int = 4) -> str:
    pad = " " * spaces
    return "\n".join(f"{pad}{line}" for line in lines)


def build_robot_files(data: dict) -> dict[str, str]:
    """
    Convert the structured LLM JSON into two .robot file strings:
      - pages/{page_name}_page.robot   (POM keyword file)
      - tests/{page_name}_tests.robot  (test file)

    Returns a dict: { "pom_path": str, "test_path": str }
    Also writes the files to disk.
    """
    page_name   = re.sub(r"[^a-z0-9_]", "_", data.get("page_name", "generated").lower())
    description = data.get("description", "")
    variables   = data.get("variables",   [])
    keywords    = data.get("pom_keywords", [])
    test_cases  = data.get("test_cases",  [])

    # ── POM file ───────────────────────────────────────────────────────────────
    pom_lines = [
        "*** Settings ***",
        "Library     Browser",
        "Resource    ../resources/keywords/common_keywords.robot",
        "Resource    ../resources/variables/common_variables.robot",
        "",
        "*** Keywords ***",
    ]

    for kw in keywords:
        kw_name = kw.get("name", "Unnamed Keyword")
        args    = kw.get("arguments", [])
        steps   = kw.get("steps", [])

        pom_lines.append(kw_name)
        for arg in args:
            pom_lines.append(f"    [Arguments]    {arg}")
        for step in steps:
            pom_lines.append(f"    {step}")
        pom_lines.append("")

    pom_content = "\n".join(pom_lines)

    # ── Test file ──────────────────────────────────────────────────────────────
    test_lines = [
        "*** Settings ***",
        "Library         Browser",
        "Library         OperatingSystem",
        "Resource        ../resources/keywords/common_keywords.robot",
        "Resource        ../resources/variables/common_variables.robot",
        "Resource        ../pages/login_page.robot",
        f"Resource        ../pages/{page_name}_page.robot",
        "Suite Setup     Run Keywords    Open Browser Session    AND    Login To Mirrix",
        "Suite Teardown  Close All Browsers",
        "Test Teardown   Take Screenshot On Failure",
        "",
    ]

    if variables:
        test_lines.append("*** Variables ***")
        for var in variables:
            name  = var.get("name", "VAR")
            value = var.get("value", "")
            test_lines.append(f"${{{name}}}{'':>4}{value}")
        test_lines.append("")

    test_lines.append("*** Test Cases ***")
    for tc in test_cases:
        tc_name = tc.get("name", "Unnamed Test")
        tags    = tc.get("tags", [])
        steps   = tc.get("steps", [])

        test_lines.append(tc_name)
        if tags:
            test_lines.append(f"    [Tags]    {'    '.join(tags)}")
        for step in steps:
            test_lines.append(f"    {step}")
        test_lines.append("")

    test_content = "\n".join(test_lines)

    # ── Write files ────────────────────────────────────────────────────────────
    PAGES_DIR.mkdir(parents=True, exist_ok=True)
    TESTS_DIR.mkdir(parents=True, exist_ok=True)

    pom_path  = PAGES_DIR / f"{page_name}_page.robot"
    test_path = TESTS_DIR / f"{page_name}_tests.robot"

    pom_path.write_text(pom_content,  encoding="utf-8")
    test_path.write_text(test_content, encoding="utf-8")

    return {
        "pom_path":  str(pom_path),
        "test_path": str(test_path),
        "pom_content":  pom_content,
        "test_content": test_content,
    }


# ── LLM call ───────────────────────────────────────────────────────────────────
async def call_llm(playwright_code: str, model: str | None = None) -> dict:
    """
    Send Playwright codegen output to OpenAI and return structured guide dict.

    Args:
        playwright_code: Raw Playwright TypeScript from npx playwright codegen
        model:           Optional model override

    Returns:
        dict with keys: page_name, description, variables, pom_keywords, test_cases
    """
    model_candidates = _candidate_models(model)
    last_error = None

    async with httpx.AsyncClient(timeout=120) as client:
        for selected_model in model_candidates:
            response = await client.post(
                "https://api.openai.com/v1/chat/completions",
                headers={
                    "Authorization": f"Bearer {OPENAI_API_KEY}",
                    "Content-Type": "application/json",
                },
                json={
                    "model": selected_model,
                    "messages": [
                        {"role": "system", "content": SYSTEM_PROMPT},
                        {"role": "user",   "content": playwright_code},
                    ],
                    "temperature": 0.2,
                    "max_tokens": 4000,
                    "response_format": {"type": "json_object"},
                },
            )

            data = response.json()

            if response.status_code == 200:
                if "choices" not in data or not data["choices"]:
                    raise RuntimeError("OpenAI API returned no choices")

                raw_text = data["choices"][0]["message"]["content"]

                try:
                    return json.loads(raw_text)
                except json.JSONDecodeError as e:
                    raise RuntimeError(f"LLM returned invalid JSON: {e}\n\n{raw_text}")

            if _is_model_access_error(response.status_code, data):
                last_error = f"{selected_model}: {data}"
                continue

            raise RuntimeError(
                f"OpenAI API error {response.status_code} "
                f"for model '{selected_model}': {data}"
            )

    raise RuntimeError(
        "No accessible OpenAI model found. "
        f"Tried: {', '.join(model_candidates)}. "
        f"Last error: {last_error}"
    )


# ── Streaming LLM call ─────────────────────────────────────────────────────────
async def call_llm_streaming(playwright_code: str, model: str | None = None):
    """
    Stream OpenAI response chunks.

    Usage:
        chunks = []
        async for chunk in call_llm_streaming(playwright_code):
            chunks.append(chunk)
            print(chunk, end="", flush=True)
        data = json.loads("".join(chunks))
        result = build_robot_files(data)
    """
    model_candidates = _candidate_models(model)
    last_error = None

    async with httpx.AsyncClient(timeout=120) as client:
        for selected_model in model_candidates:
            async with client.stream(
                "POST",
                "https://api.openai.com/v1/chat/completions",
                headers={
                    "Authorization": f"Bearer {OPENAI_API_KEY}",
                    "Content-Type": "application/json",
                },
                json={
                    "model": selected_model,
                    "messages": [
                        {"role": "system", "content": SYSTEM_PROMPT},
                        {"role": "user",   "content": playwright_code},
                    ],
                    "temperature": 0.2,
                    "max_tokens": 4000,
                    "stream": True,
                },
            ) as response:
                if response.status_code != 200:
                    error_text = await response.aread()
                    try:
                        error_data = json.loads(error_text.decode("utf-8"))
                    except Exception:
                        error_data = {"raw": error_text.decode("utf-8", errors="ignore")}

                    if _is_model_access_error(response.status_code, error_data):
                        last_error = f"{selected_model}: {error_data}"
                        continue

                    raise RuntimeError(
                        f"OpenAI API error {response.status_code} "
                        f"for model '{selected_model}': {error_data}"
                    )

                async for line in response.aiter_lines():
                    if not line or not line.startswith("data: "):
                        continue
                    chunk = line.replace("data: ", "")
                    if chunk == "[DONE]":
                        return
                    try:
                        chunk_data = json.loads(chunk)
                        delta = chunk_data["choices"][0].get("delta", {})
                        if "content" in delta:
                            yield delta["content"]
                    except Exception:
                        continue

    raise RuntimeError(
        "No accessible OpenAI model found for streaming. "
        f"Tried: {', '.join(model_candidates)}. "
        f"Last error: {last_error}"
    )
