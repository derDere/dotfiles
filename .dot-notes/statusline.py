#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Claude Code status line — Powerlevel10k style, gradient-fill segments."""

import sys
import io
import json
import os

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

PL_R = chr(0xE0B0)   # ▶  right-pointing arrow  — used as RIGHT end-cap
PL_L = chr(0xE0B2)   # ◀  left-pointing arrow   — used as LEFT  end-cap
DIAMOND = chr(0x25C6)  # ◆  separator between segments

RESET = "\033[0m"
def fg(r, g, b): return f"\033[38;2;{r};{g};{b}m"
def bg(r, g, b): return f"\033[48;2;{r};{g};{b}m"

WHITE = (255, 255, 255)

# Dark base colors for each segment (used as the "empty" side of the gradient)
C_DIR    = (40,  55,  80)
C_MODEL  = (35,  50,  70)
C_CTX    = (15,  85,  45)   # green
C_5H     = (20,  65, 125)   # blue
C_7D     = (85,  30, 105)   # purple
C_COST   = (105, 50,  15)   # amber
C_WARN50 = (145, 90,   5)   # orange (>=50%)
C_WARN80 = (125, 20,  20)   # red    (>=80%)

def darken(c, f=0.28): return tuple(max(0, int(x * f)) for x in c)
def lighten(c, f=3.2): return tuple(min(255, int(x * f)) for x in c)

def threshold_color(pct, base):
    if pct is None or pct < 50: return base
    if pct < 80:                 return C_WARN50
    return C_WARN80

def fmt_tok(n):
    """1.7k / 46k / 0.2M / 1M  — 1 decimal unless round."""
    if n is None: return "?"
    n = int(n)
    if n >= 100_000:
        v = n / 1_000_000
        return f"{int(v)}M" if v % 1 == 0 else f"{v:.1f}M"
    if n >= 1_000:
        v = n / 1_000
        return f"{int(v)}k" if v % 1 == 0 else f"{v:.1f}k"
    return str(n)

PRICING = {
    "claude-opus-4":     {"in": 15.00, "cw": 18.75, "cr": 1.50,  "out": 75.00},
    "claude-sonnet-4":   {"in":  3.00, "cw":  3.75, "cr": 0.30,  "out": 15.00},
    "claude-3-5-sonnet": {"in":  3.00, "cw":  3.75, "cr": 0.30,  "out": 15.00},
    "claude-3-5-haiku":  {"in":  0.80, "cw":  1.00, "cr": 0.08,  "out":  4.00},
    "claude-3-haiku":    {"in":  0.25, "cw":  0.30, "cr": 0.03,  "out":  1.25},
    "claude-3-opus":     {"in": 15.00, "cw": 18.75, "cr": 1.50,  "out": 75.00},
}

def get_pricing(mid):
    mid = mid.lower()
    for k in sorted(PRICING, key=len, reverse=True):
        if k in mid: return PRICING[k]
    return PRICING["claude-sonnet-4"]

def model_label(mid, mname):
    m = mid.lower()
    if "opus-4"     in m:                    return "Opus 4"
    if "sonnet-4"   in m and "3-5" not in m: return "Sonnet 4.6"
    if "3-5-sonnet" in m:                    return "S3.5"
    if "haiku"      in m:                    return "Haiku"
    if "3-opus"     in m or "opus-3" in m:   return "Opus 3"
    return mname.replace("Claude ", "")

ICON_DIR   = chr(0xF07C)   # nf-fa-folder_open
ICON_MODEL = chr(0xF489)   # nf-dev-terminal
ICON_CTX   = chr(0xF4BC)   # nf-fa-database
ICON_5H    = chr(0xF017)   # nf-fa-clock_o
ICON_7D    = chr(0xF073)   # nf-fa-calendar
ICON_COST  = chr(0xF155)   # nf-fa-eur

def get_cwd():
    try:
        cwd = os.getcwd()
        home = os.path.expanduser("~")
        if cwd.lower().startswith(home.lower()):
            cwd = "~" + cwd[len(home):]
        cwd = cwd.replace("\\", "/")
        if len(cwd) > 40:
            parts = cwd.split("/")
            if len(parts) > 3:
                cwd = parts[0] + "/.../" + "/".join(parts[-2:])
    except Exception:
        cwd = "~"
    return cwd

def plain_segment(icon, text, base):
    """Uniform-color segment — no gradient.
    Shape:  ◀ content ▶   (tip-left on left, tip-right on right → both ends pointy outward)
    """
    label   = f" {icon} {text} "
    content = bg(*base) + fg(*WHITE) + label
    return (RESET + fg(*base) + PL_L +        # ◀  left end-cap, tip faces left
            content +
            RESET + fg(*base) + PL_R + RESET) # ▶  right end-cap, tip faces right

def grad_segment(icon, text, pct, base):
    """Gradient fill segment.

    The label (spaces + text) IS the bar — no block characters.
      left portion  (i < split) = light  ← filled side
      right portion (i >= split) = dark  ← empty side
    As pct grows: all-dark → all-light ("von dunkel zu hell").

    Shape:  ◀ [gradient content] ▶   — both ends pointy outward.
    Cap colour matches the bg colour at that edge for a seamless join.
    """
    col   = threshold_color(pct, base)
    light = lighten(col)
    dark  = darken(col)

    label = f" {icon} {text} "
    width = len(label)

    if pct is None: pct = 0.0
    pct   = max(0.0, min(100.0, float(pct)))
    split = int(width * pct / 100)

    content = ""
    for i, ch in enumerate(label):
        cur_bg = light if i < split else dark
        content += bg(*cur_bg) + fg(*WHITE) + ch

    left_cap  = light if split > 0     else dark
    right_cap = dark  if split < width else light

    return (RESET + fg(*left_cap) + PL_L +          # ◀  left end-cap
            content +
            RESET + fg(*right_cap) + PL_R + RESET)  # ▶  right end-cap


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.stdout.write("claude\n")
        return

    mid    = data.get("model", {}).get("id", "")
    mname  = data.get("model", {}).get("display_name", mid)
    cw     = data.get("context_window", {})
    cur    = cw.get("current_usage") or {}
    rate   = data.get("rate_limits", {}) or {}
    is_api = not rate

    ctx_size  = cw.get("context_window_size", 200_000) or 200_000
    used_pct  = cw.get("used_percentage")
    total_in  = cw.get("total_input_tokens",  0) or 0
    total_out = cw.get("total_output_tokens", 0) or 0
    cache_w   = cur.get("cache_creation_input_tokens", 0) or 0
    cache_r   = cur.get("cache_read_input_tokens",     0) or 0

    # Derive used-token count from percentage for display consistency
    used_tok = int(ctx_size * used_pct / 100) if used_pct is not None else total_in

    five_pct  = (rate.get("five_hour")  or {}).get("used_percentage")
    seven_pct = (rate.get("seven_day")  or {}).get("used_percentage")

    prices   = get_pricing(mid)
    cost_usd = (
        (total_in  / 1_000_000) * prices["in"]  +
        (total_out / 1_000_000) * prices["out"] +
        (cache_w   / 1_000_000) * prices["cw"]  +
        (cache_r   / 1_000_000) * prices["cr"]
    )
    cost_eur = cost_usd * 0.92

    segs = []

    # ── 1. Context window  (tokens + percent, gradient) ────────────────────
    ctx_label = f"{fmt_tok(used_tok)}/{fmt_tok(ctx_size)}"
    if used_pct is not None:
        ctx_label += f" {used_pct:.0f}%"
    segs.append(grad_segment(ICON_CTX, ctx_label, used_pct, C_CTX))

    # ── 2. 5-hour / daily limit (subscriber only) ──────────────────────────
    if five_pct is not None:
        segs.append(grad_segment(ICON_5H, f"{five_pct:.0f}%", five_pct, C_5H))

    # ── 3. 7-day / weekly limit (subscriber only) ──────────────────────────
    if seven_pct is not None:
        segs.append(grad_segment(ICON_7D, f"{seven_pct:.0f}%", seven_pct, C_7D))

    # ── 4. Cost (API users, or subscriber with non-trivial cost) ───────────
    if is_api or cost_eur >= 0.01:
        cstr = (f"<0.01 {chr(0x20AC)}" if cost_eur < 0.01
                else f"{cost_eur:.2f} {chr(0x20AC)}")
        segs.append(plain_segment(ICON_COST, cstr, C_COST))

    # ── 5. Model ────────────────────────────────────────────────────────────
    segs.append(plain_segment(ICON_MODEL, model_label(mid, mname), C_MODEL))

    # ── 6. Working directory ────────────────────────────────────────────────
    segs.append(plain_segment(ICON_DIR, get_cwd(), C_DIR))

    sep = RESET + fg(80, 80, 110) + f" {DIAMOND} " + RESET
    sys.stdout.write(sep.join(segs) + "\n")


if __name__ == "__main__":
    main()
