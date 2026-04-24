"""
test_data_reader.py — Utility for reading test data from YAML and Excel files.
Exposed as a Robot Framework library via the robotframework-browser Library import.
"""

import yaml
import openpyxl
from pathlib import Path


def read_yaml(file_path: str) -> dict:
    """Read a YAML file and return its contents as a dictionary."""
    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f"Test data file not found: {file_path}")
    with open(path, encoding="utf-8") as f:
        return yaml.safe_load(f)


def read_excel_sheet(file_path: str, sheet_name: str = None) -> list[dict]:
    """
    Read an Excel sheet and return rows as a list of dicts keyed by header row.
    If sheet_name is None, the first sheet is used.
    """
    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f"Test data file not found: {file_path}")

    wb = openpyxl.load_workbook(path, data_only=True)
    ws = wb[sheet_name] if sheet_name else wb.active

    rows = list(ws.iter_rows(values_only=True))
    if not rows:
        return []

    headers = [
        str(h).strip() if h is not None else f"col_{i}"
        for i, h in enumerate(rows[0])
    ]
    return [dict(zip(headers, row)) for row in rows[1:] if any(v is not None for v in row)]


def resolve_asset_path(assets_root: str, subfolder: str, file_name: str) -> str:
    """
    Build the full path to a test asset using the subfolder structure:
      test_assets/{subfolder}/{file_name}

    Args:
        assets_root:  Value of ${ASSETS_DIR} — path to the test_assets/ root
        subfolder:    Value of the "Asset Subfolder" column (images/documents/etc.)
        file_name:    Value of the "File Name" column

    Returns:
        Full resolved path string

    Example:
        resolve_asset_path("/path/to/test_assets", "images", "product.jpg")
        → "/path/to/test_assets/images/product.jpg"
    """
    resolved = Path(assets_root) / (subfolder or "").strip() / file_name.strip()
    return str(resolved)
