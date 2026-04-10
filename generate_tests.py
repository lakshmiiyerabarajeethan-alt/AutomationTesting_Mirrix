"""
generate_tests.py — CLI to generate Robot Framework tests from Playwright codegen output.

Usage:
    # From a saved .ts file
    python generate_tests.py --input codegen_output.ts

    # From clipboard (paste directly)
    python generate_tests.py --stdin

    # Stream output to console as it generates
    python generate_tests.py --input codegen_output.ts --stream

    # Override model
    python generate_tests.py --input codegen_output.ts --model gpt-4o
"""

import asyncio
import argparse
import json
import sys
from pathlib import Path

# Add project root to path so resources.helpers is importable
sys.path.insert(0, str(Path(__file__).parent))

from resources.helpers.llm_client import call_llm, call_llm_streaming, build_robot_files


def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate Robot Framework tests from Playwright codegen output using OpenAI."
    )
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--input",  "-i", metavar="FILE",
                        help="Path to a .ts file containing Playwright codegen output")
    source.add_argument("--stdin",        action="store_true",
                        help="Read Playwright codegen output from stdin (paste mode)")

    parser.add_argument("--stream", "-s", action="store_true",
                        help="Stream the LLM response to console while generating")
    parser.add_argument("--model",  "-m", metavar="MODEL",
                        help="Override OpenAI model (e.g. gpt-4o)")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print the generated .robot content without writing files")
    return parser.parse_args()


async def run(args):
    # ── Read Playwright code ───────────────────────────────────────────────────
    if args.stdin:
        print("Paste your Playwright codegen output below.")
        print("Press Ctrl+Z (Windows) or Ctrl+D (Mac/Linux) then Enter when done.\n")
        playwright_code = sys.stdin.read()
    else:
        input_path = Path(args.input)
        if not input_path.exists():
            print(f"Error: File not found: {input_path}")
            sys.exit(1)
        playwright_code = input_path.read_text(encoding="utf-8")

    print(f"\nSending to OpenAI ({args.model or 'default model'})...\n")

    # ── Call LLM ───────────────────────────────────────────────────────────────
    if args.stream:
        chunks = []
        print("── Streaming response ────────────────────────────────────────")
        async for chunk in call_llm_streaming(playwright_code, model=args.model):
            print(chunk, end="", flush=True)
            chunks.append(chunk)
        print("\n── Stream complete ───────────────────────────────────────────\n")
        data = json.loads("".join(chunks))
    else:
        data = await call_llm(playwright_code, model=args.model)

    # ── Build .robot files ─────────────────────────────────────────────────────
    if args.dry_run:
        result = build_robot_files.__wrapped__(data) if hasattr(build_robot_files, "__wrapped__") else None
        # Dry-run: build content without writing
        print("── DRY RUN — files NOT written ───────────────────────────────\n")
        print(f"Page name : {data.get('page_name')}")
        print(f"Variables : {[v['name'] for v in data.get('variables', [])]}")
        print(f"Keywords  : {[k['name'] for k in data.get('pom_keywords', [])]}")
        print(f"Test cases: {[t['name'] for t in data.get('test_cases', [])]}")
        return

    result = build_robot_files(data)

    # ── Report ─────────────────────────────────────────────────────────────────
    print("✅ Robot Framework files generated:\n")
    print(f"  POM  → {result['pom_path']}")
    print(f"  Test → {result['test_path']}")
    print()
    print("── Generated POM keywords ────────────────────────────────────────")
    for kw in data.get("pom_keywords", []):
        args_str = ", ".join(kw.get("arguments", []))
        print(f"  • {kw['name']}({args_str})")
    print()
    print("── Generated test cases ──────────────────────────────────────────")
    for tc in data.get("test_cases", []):
        tags = ", ".join(tc.get("tags", []))
        print(f"  • [{tags}]  {tc['name']}")
    print()
    print("Next step: drop your asset files into test_data/assets/ then run:")
    print("  .\\run_suite.ps1")


if __name__ == "__main__":
    args = parse_args()
    asyncio.run(run(args))
