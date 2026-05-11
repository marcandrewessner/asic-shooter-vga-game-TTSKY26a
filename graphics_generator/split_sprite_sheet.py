"""Split a horizontal sprite sheet into N equal frames."""
import click
from PIL import Image


@click.command()
@click.argument("sheet", type=click.Path(exists=True, readable=True))
@click.argument("output_dir", type=click.Path())
@click.option("--frames", "-n", default=5, show_default=True, help="Number of frames to extract.")
@click.option("--prefix", "-p", default="bird", show_default=True, help="Output filename prefix.")
def main(sheet: str, output_dir: str, frames: int, prefix: str) -> None:
    """Split a horizontal sprite sheet into N equal frames.

    SHEET       Input sprite sheet PNG.\n
    OUTPUT_DIR  Directory to write frame PNGs into.
    """
    import os
    os.makedirs(output_dir, exist_ok=True)

    img = Image.open(sheet).convert("RGBA")
    total_w, h = img.size

    if total_w % frames != 0:
        raise click.ClickException(
            f"Image width {total_w} is not evenly divisible by {frames} frames."
        )

    frame_w = total_w // frames
    for i in range(frames):
        x0 = i * frame_w
        frame = img.crop((x0, 0, x0 + frame_w, h))
        out_path = os.path.join(output_dir, f"{prefix}_{i}.png")
        frame.save(out_path)
        click.echo(f"Saved {out_path}  ({frame_w}x{h})")


if __name__ == "__main__":
    main()
