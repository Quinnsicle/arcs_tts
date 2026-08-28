#!/usr/bin/env python3
"""
Compose an overlay image onto a base image near the middle on the left.

Usage:
  python place_overlay.py \
    --base cardAssets/extra/B09A1DE0302BFED6AFF653116F56B110B73F024B_arcs_custom_table_diffuse.png \
    --overlay cardAssets/extra/background_beyond.png \
    --out cardAssets/extra/combined.png

Options:
  --scale      Fraction of base width to scale the overlay to (default: 0.30)
  --x-percent  Horizontal position as percent of base width from left (default: 0.15)
"""
import argparse
import sys
from PIL import Image, ImageEnhance
from pathlib import Path
import random
import sys

# Centralized defaults for planet placement
DEFAULTS = {
  "count": 25,
  "min_px": 90,
  "max_px": 120,
  "left": 650,
  "top": 650,
  "right_offset": 800,
  "bottom_offset": 2100,
  "non_overlap": True,
  "padding": 250,
  "edge_margin": 120,
  "same_min_dist": 1500,
  "max_attempts": 400,
}


def compose(base_path, overlay_path, out_path, scale=None, x_percent=0.15, pos_x=None, pos_y=None, overlay_width=None, max_right=None, max_top=None):
  base = Image.open(base_path).convert("RGBA")
  overlay = Image.open(overlay_path).convert("RGBA")

  ow, oh = overlay.size
  # Determine target overlay width: explicit pixels > scale fraction > default 0.3
  if overlay_width:
    target_w = max(1, int(overlay_width))
  else:
    use_scale = scale if scale is not None else 0.30
    target_w = max(1, int(base.width * use_scale))

  # Preserve aspect ratio
  target_h = max(1, int(oh * (target_w / ow)))
  overlay_resized = overlay.resize((target_w, target_h), Image.LANCZOS)

  # Compute position: explicit pixel coords if provided, otherwise percent from left and vertically centered
  if pos_x is not None:
    x = int(pos_x)
  else:
    x = int(base.width * x_percent)

  if pos_y is not None:
    y = int(pos_y)
  else:
    y = (base.height - overlay_resized.height) // 2

  # If left position is fixed (pos_x) and a max_right is given, prefer resizing
  # the overlay to fit between pos_x and max_right instead of shifting left.
  if pos_x is not None and max_right is not None:
    available = int(max_right) - int(pos_x)
    if available < overlay_resized.width:
      # Resize overlay to fit available width while preserving aspect ratio
      new_w = max(1, available)
      new_h = max(1, int(overlay.size[1] * (new_w / overlay.size[0])))
      overlay_resized = overlay.resize((new_w, new_h), Image.LANCZOS)
      # Recompute y if vertically centered
      if pos_y is None:
        y = (base.height - overlay_resized.height) // 2

  # Enforce boundaries if provided
  if max_right is not None:
    # Ensure the overlay's right edge does not exceed max_right
    if x + overlay_resized.width > int(max_right):
      x = max(0, int(max_right) - overlay_resized.width)

  if max_top is not None:
    # Ensure the overlay's top does not go below max_top (distance from top)
    if y > int(max_top):
      y = int(max_top)

  # Clamp to image
  x = max(0, min(x, base.width - overlay_resized.width))
  y = max(0, min(y, base.height - overlay_resized.height))

  result = base.copy()
  result.paste(overlay_resized, (x, y), overlay_resized)

  out_dir = Path(out_path).parent
  out_dir.mkdir(parents=True, exist_ok=True)
  result.save(out_path)
  print(f"Saved composed image to {out_path}")


def place_planets(base_path, planets_dir, out_path, count=None, min_px=None, max_px=None, left=None, top=None, right_offset=None, bottom_offset=None, seed=None, non_overlap=None, padding=None, edge_margin=None, same_min_dist=None, max_attempts=None):
  """
  Place `count` random planet images from `planets_dir` onto `base_path` within the zone defined by
  left (px from left), top (px from top), right_offset (px from right edge), bottom_offset (px from bottom edge).
  Planet sizes are chosen randomly between min_scale and max_scale (fractions of base width).
  """
  # apply centralized defaults when arguments are omitted
  if count is None:
    count = DEFAULTS["count"]
  if min_px is None:
    min_px = DEFAULTS["min_px"]
  if max_px is None:
    max_px = DEFAULTS["max_px"]
  if left is None:
    left = DEFAULTS["left"]
  if top is None:
    top = DEFAULTS["top"]
  if right_offset is None:
    right_offset = DEFAULTS["right_offset"]
  if bottom_offset is None:
    bottom_offset = DEFAULTS["bottom_offset"]
  if non_overlap is None:
    non_overlap = DEFAULTS["non_overlap"]
  if padding is None:
    padding = DEFAULTS["padding"]
  if edge_margin is None:
    edge_margin = DEFAULTS["edge_margin"]
  if same_min_dist is None:
    same_min_dist = DEFAULTS["same_min_dist"]
  if max_attempts is None:
    max_attempts = DEFAULTS["max_attempts"]

  if seed is not None:
    random.seed(seed)

  base = Image.open(base_path).convert("RGBA")
  base_w, base_h = base.size

  planets_path = Path(planets_dir)
  if not planets_path.exists() or not planets_path.is_dir():
    raise FileNotFoundError(f"Planets directory not found: {planets_dir}")

  # collect image files
  exts = ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.gif"]
  files = []
  for e in exts:
    files.extend(list(planets_path.glob(e)))
  files = [f for f in files if f.is_file()]
  if not files:
    raise FileNotFoundError(f"No planet images found in {planets_dir}")

  x_min = int(left)
  x_max = int(base_w - right_offset)
  y_min = int(top)
  y_max = int(base_h - bottom_offset)

  # Ensure region is valid
  if x_min >= x_max or y_min >= y_max:
    raise ValueError(f"Invalid placement zone: x [{x_min},{x_max}] y [{y_min},{y_max}]")

  result = base.copy()

  placed = []  # list of (left, top, right, bottom, src_path)

  # Helper to try placing a single planet at constrained px/py ranges
  def try_place_within(img_path, min_w, max_w, px_range, py_range):
    attempts = 0
    while attempts < max_attempts:
      attempts += 1
      img = Image.open(src).convert("RGBA").rotate(180, expand=True)
      target_w = random.randint(int(min_w), int(max_w))
      ow, oh = img.size
      target_h = max(1, int(oh * (target_w / ow)))
      planet = img.resize((target_w, target_h), Image.LANCZOS)
      max_px = px_range[1] - planet.width
      min_px_allowed = px_range[0]
      max_py = py_range[1] - planet.height
      min_py_allowed = py_range[0]
      if max_px < min_px_allowed or max_py < min_py_allowed:
        # doesn't fit for this size, try a smaller size next attempt
        continue

      px = random.randint(min_px_allowed, max_px)
      py = random.randint(min_py_allowed, max_py)

      # check overlap and same-source distance
      if non_overlap:
        rect = (px, py, px + planet.width, py + planet.height)
        overlap = False
        for r in placed:
          pr = (r[0] - padding, r[1] - padding, r[2] + padding, r[3] + padding)
          if not (rect[2] <= pr[0] or rect[0] >= pr[2] or rect[3] <= pr[1] or rect[1] >= pr[3]):
            overlap = True
            break
          # additionally, if same source, ensure minimum center distance
          try:
            other_src = r[4]
          except Exception:
            other_src = None
          if other_src is not None and str(other_src) == str(img_path):
            # compute center distance
            cx1 = rect[0] + (rect[2] - rect[0]) / 2
            cy1 = rect[1] + (rect[3] - rect[1]) / 2
            cx2 = r[0] + (r[2] - r[0]) / 2
            cy2 = r[1] + (r[3] - r[1]) / 2
            dist2 = (cx1 - cx2) ** 2 + (cy1 - cy2) ** 2
            if dist2 < (same_min_dist ** 2):
              overlap = True
              break
        if overlap:
          continue

      # dim planet brightness by 50%
      try:
        enhancer = ImageEnhance.Brightness(planet)
        planet = enhancer.enhance(0.5)
      except Exception:
        pass
      # place
      result.paste(planet, (px, py), planet)
      placed.append((px, py, px + planet.width, py + planet.height, str(img_path)))
      return True
    return False

  # First, ensure there is at least one planet near each side of the zone
  sides = ["left", "right", "top", "bottom"]
  for side in sides:
    success = False
    attempts = 0
    while attempts < max_attempts and not success:
      attempts += 1
      src = random.choice(files)
      # pick a candidate width to try
      target_w = random.randint(int(min_px), int(max_px))
      img = Image.open(src).convert("RGBA").rotate(180, expand=True)
      ow, oh = img.size
      target_h = max(1, int(oh * (target_w / ow)))
      # determine px/py ranges depending on side
      if side == "left":
        px_range = (x_min, min(x_min + edge_margin, x_max))
        py_range = (y_min, y_max)
      elif side == "right":
        px_range = (max(x_min, x_max - edge_margin), x_max)
        py_range = (y_min, y_max)
      elif side == "top":
        px_range = (x_min, x_max)
        py_range = (y_min, min(y_min + edge_margin, y_max))
      else:  # bottom
        px_range = (x_min, x_max)
        py_range = (max(y_min, y_max - edge_margin), y_max)

      # try to place this specific image within the computed ranges
      if try_place_within(src, min_px, max_px, px_range, py_range):
        success = True
        break
    # if we failed to place near this side after attempts, just continue

  # Now place remaining planets randomly
  for i in range(count - len(placed)):
    src = random.choice(files)
    img = Image.open(src).convert("RGBA").rotate(180, expand=True)

    # attempt to place non-overlapping if requested
    placed_ok = False
    attempts = 0
    while attempts < max_attempts and not placed_ok:
      attempts += 1

      # choose absolute width in pixels (not dependent on base image)
      target_w = random.randint(int(min_px), int(max_px))
      ow, oh = img.size
      target_h = max(1, int(oh * (target_w / ow)))
      planet = img.resize((target_w, target_h), Image.LANCZOS)

      # compute random position ensuring planet fully inside the zone
      max_x_allowed = x_max - planet.width
      max_y_allowed = y_max - planet.height
      if max_x_allowed < x_min:
        # reduce width to fit horizontally
        new_w = max(1, x_max - x_min)
        new_h = max(1, int(oh * (new_w / ow)))
        planet = img.resize((new_w, new_h), Image.LANCZOS)
        max_x_allowed = x_max - planet.width
        max_y_allowed = y_max - planet.height

      if max_x_allowed < x_min or max_y_allowed < y_min:
        # can't place this planet in zone at any size
        break

      px = random.randint(x_min, max_x_allowed)
      py = random.randint(y_min, max_y_allowed)

      if non_overlap:
        rect = (px, py, px + planet.width, py + planet.height)
        overlap = False
        for r in placed:
          # expand existing rect by padding when checking
          pr = (r[0] - padding, r[1] - padding, r[2] + padding, r[3] + padding)
          # if rectangles overlap
          if not (rect[2] <= pr[0] or rect[0] >= pr[2] or rect[3] <= pr[1] or rect[1] >= pr[3]):
            overlap = True
            break
          # check same-source min distance
          try:
            other_src = r[4]
          except Exception:
            other_src = None
          if other_src is not None and str(other_src) == str(src):
            cx1 = rect[0] + (rect[2] - rect[0]) / 2
            cy1 = rect[1] + (rect[3] - rect[1]) / 2
            cx2 = r[0] + (r[2] - r[0]) / 2
            cy2 = r[1] + (r[3] - r[1]) / 2
            dist2 = (cx1 - cx2) ** 2 + (cy1 - cy2) ** 2
            if dist2 < (same_min_dist ** 2):
              overlap = True
              break
        if overlap:
          continue

      # dim planet brightness by 50%
      try:
        enhancer = ImageEnhance.Brightness(planet)
        planet = enhancer.enhance(0.5)
      except Exception:
        pass
      # place planet
      result.paste(planet, (px, py), planet)
      placed.append((px, py, px + planet.width, py + planet.height, str(src)))
      placed_ok = True

    # if couldn't place after attempts, skip
    if not placed_ok:
      continue

  out_dir = Path(out_path).parent
  out_dir.mkdir(parents=True, exist_ok=True)
  result.save(out_path)
  print(f"Saved planets-composed image to {out_path}")


def main():
  default_base = Path(__file__).parent / "B09A1DE0302BFED6AFF653116F56B110B73F024B_arcs_custom_table_diffuse.png"
  default_overlay = Path(__file__).parent / "background_beyond.png"
  default_out = Path(__file__).parent / "combined.png"

  p = argparse.ArgumentParser(description="Place overlay near middle-left of base image")
  p.add_argument("--base", required=False)
  p.add_argument("--overlay", required=False)
  p.add_argument("--out", required=False)
  p.add_argument("--scale", type=float, default=0.30)
  p.add_argument("--x-percent", type=float, default=0.15)
  p.add_argument("--pos-x", type=int, default=None)
  p.add_argument("--pos-y", type=int, default=None)
  p.add_argument("--overlay-width", type=int, default=None)
  p.add_argument("--max-right", type=int, default=None)
  p.add_argument("--max-top", type=int, default=None)
  p.add_argument("--batch", type=int, default=0)
  p.add_argument("--out-pattern", type=str, default=None)
  p.add_argument("--seed", type=int, default=None)

  args = p.parse_args()

  # default "no CLI args" behavior
  if len(sys.argv) == 1:
    planets_dir = Path(__file__).parent / "background planets"
    place_planets(str(default_base), str(planets_dir), str(default_out))
    return

  base = args.base or str(default_base)
  overlay = args.overlay or str(default_overlay)
  out = args.out or str(default_out)

  # Batch mode: generate multiple numbered images
  if args.batch and args.batch > 0:
      pattern = args.out_pattern if args.out_pattern else None

      for i in range(1, args.batch + 1):
          if pattern:
              try:
                  out_path = pattern.format(i=i)
              except Exception:
                  out_path = pattern.replace("{i}", str(i))
          else:
              out_path = str(Path(out).with_name(f"{Path(out).stem}_{i}{Path(out).suffix}"))

          # use seed for reproducibility if provided
          seed_val = args.seed + i if args.seed is not None else None

          place_planets(
              base,
              Path(__file__).parent / "background planets",
              out_path,
              seed=seed_val
          )

      print(f"Generated {args.batch} images using pattern {pattern or out}")
      return

  # single run
  compose(base, overlay, out, scale=args.scale, x_percent=args.x_percent, pos_x=args.pos_x, pos_y=args.pos_y, overlay_width=args.overlay_width, max_right=args.max_right, max_top=args.max_top)


if __name__ == "__main__":
    main()
