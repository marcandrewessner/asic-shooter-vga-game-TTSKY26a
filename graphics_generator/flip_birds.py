"""Flip bird sprites horizontally and regenerate their SystemVerilog ROM files."""
import os
import subprocess
import sys
from pathlib import Path

from PIL import Image

SCRIPT_DIR = Path(__file__).parent
GRAPHICS_DIR = SCRIPT_DIR / "graphics"
ROM_DIR = SCRIPT_DIR.parent / "src" / "graphics_rom"
PNG2SV = SCRIPT_DIR / ".venv" / "bin" / "png2sv"


def flip_horizontal(path: Path) -> None:
    img = Image.open(path).convert("RGBA")
    flipped = img.transpose(Image.FLIP_LEFT_RIGHT)
    flipped.save(path)
    print(f"Flipped  {path.name}")


def regenerate_sv(png_path: Path) -> None:
    stem = png_path.stem
    out_sv = ROM_DIR / f"{stem}.sv"
    result = subprocess.run(
        [str(PNG2SV), str(png_path), str(out_sv)],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(f"ERROR generating {out_sv.name}:\n{result.stderr}", file=sys.stderr)
        sys.exit(result.returncode)
    print(f"Generated {out_sv.name}")
    if result.stderr:
        print(result.stderr.strip(), file=sys.stderr)


def main() -> None:
    birds_png = GRAPHICS_DIR / "birds.png"
    frame_pngs = sorted(GRAPHICS_DIR.glob("bird_[0-9].png"))

    flip_horizontal(birds_png)
    for png in frame_pngs:
        flip_horizontal(png)

    for png in frame_pngs:
        regenerate_sv(png)


if __name__ == "__main__":
    main()
