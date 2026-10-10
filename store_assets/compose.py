"""Builds App Store / Play Store marketing images from raw simulator captures.

Usage: python3 store_assets/compose.py
Inputs:  store_assets/raw/{iphone,ipad}/*.png  (native-resolution captures)
Outputs: store_assets/appstore/*, store_assets/playstore/*
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent
FONTS = ROOT.parent / "assets" / "fonts"
DISPLAY = FONTS / "plus_jakarta_sans" / "PlusJakartaSans-Bold.ttf"
BODY = FONTS / "inter" / "Inter_28pt-Medium.ttf"

BRAND_A = (0x4F, 0x46, 0xE5)  # JemenaiTheme.gradBrand start
BRAND_B = (0x7C, 0x3A, 0xED)  # JemenaiTheme.gradBrand end
WHITE = (255, 255, 255)

# Order = listing order. Copy is kept to claims the app actually backs up.
SHOTS = [
    ("02_chat_quantum", "Private AI,\nright on your phone",
     "Powerful models that run entirely on-device."),
    ("03_chat_code", "Code, write and learn\n— even offline",
     "Clean formatting, code blocks and one-tap copy."),
    ("04_store", "Choose from 14\nopen models",
     "Gemma, Qwen, Phi, DeepSeek and more."),
    ("06_privacy", "No accounts.\nNo tracking.",
     "Your prompts never leave your device."),
    ("05_home", "Quick tools for\neveryday tasks",
     "Emails, ideas, songs and more in one tap."),
    ("08_chat_dark", "Beautiful in\nlight and dark",
     "Follows your system theme, or pick your own."),
    ("01_onboarding", "Works anywhere,\nno signal needed",
     "Download once, then use it fully offline."),
]


def gradient(size):
    w, h = size
    base = Image.new("RGB", (2, 2))
    base.putdata([BRAND_A, BRAND_B, BRAND_A, BRAND_B])
    # Smooth diagonal blend, then soft highlight blobs for depth.
    img = base.resize((w, h), Image.BILINEAR)
    glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(glow)
    r = int(w * 0.55)
    d.ellipse((-r // 2, -r // 3, r, r * 2 // 3), fill=(255, 255, 255, 38))
    d.ellipse((w - r, h - r // 1.3, w + r // 2, h + r // 2), fill=(255, 255, 255, 22))
    glow = glow.filter(ImageFilter.GaussianBlur(w // 10))
    img = img.convert("RGBA")
    img.alpha_composite(glow)
    return img


def rounded(img, radius):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, *img.size), radius, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def fit_text(draw, text, font_path, max_w, start_size, min_size):
    size = start_size
    while size > min_size:
        font = ImageFont.truetype(str(font_path), size)
        box = draw.multiline_textbbox((0, 0), text, font=font, spacing=size * 0.18)
        if box[2] - box[0] <= max_w:
            return font
        size -= 2
    return ImageFont.truetype(str(font_path), min_size)


def compose(raw, out_size, headline, sub, *, crop_chrome=False, screen_w_ratio=0.80):
    W, H = out_size
    canvas = gradient(out_size)
    d = ImageDraw.Draw(canvas)

    margin = int(W * 0.08)
    title_font = fit_text(d, headline, DISPLAY, W - 2 * margin, int(W * 0.085), int(W * 0.05))
    sub_font = fit_text(d, sub, BODY, W - 2 * margin, int(W * 0.04), int(W * 0.026))

    y = int(H * 0.055)
    d.multiline_text((W / 2, y), headline, font=title_font, fill=WHITE, anchor="ma",
                     align="center", spacing=title_font.size * 0.18)
    tb = d.multiline_textbbox((W / 2, y), headline, font=title_font, anchor="ma",
                              align="center", spacing=title_font.size * 0.18)
    y = int(tb[3] + H * 0.018)
    d.text((W / 2, y), sub, font=sub_font, fill=(255, 255, 255, 215), anchor="ma")
    text_bottom = int(y + sub_font.size + H * 0.035)

    shot = Image.open(raw).convert("RGB")
    if crop_chrome:
        # Drop the iOS status bar / home indicator so Play images aren't iPhone-specific.
        sw, sh = shot.size
        shot = shot.crop((0, int(sh * 0.062), sw, int(sh * 0.962)))

    # Scale the screen to the space left under the text.
    avail_h = H - text_bottom - int(H * 0.04)
    scale = min((W * screen_w_ratio) / shot.width, avail_h / shot.height)
    shot = shot.resize((int(shot.width * scale), int(shot.height * scale)), Image.LANCZOS)
    radius = int(shot.width * 0.075)

    # Thin dark bezel + soft drop shadow.
    bezel = int(shot.width * 0.018)
    frame = Image.new("RGBA", (shot.width + 2 * bezel, shot.height + 2 * bezel), (0, 0, 0, 0))
    ImageDraw.Draw(frame).rounded_rectangle((0, 0, *frame.size), radius + bezel, fill=(17, 17, 27, 255))
    frame.alpha_composite(rounded(shot, radius), (bezel, bezel))

    x = (W - frame.width) // 2
    top = text_bottom + max(0, (avail_h - frame.height) // 2)
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        (x, top + int(H * 0.012), x + frame.width, top + frame.height + int(H * 0.012)),
        radius + bezel, fill=(20, 10, 60, 120))
    shadow = shadow.filter(ImageFilter.GaussianBlur(int(W * 0.03)))
    canvas.alpha_composite(shadow)
    canvas.alpha_composite(frame, (x, top))
    return canvas.convert("RGB")


def feature_graphic(path, size=(1024, 500)):
    """Google Play feature graphic: logo mark, name and tagline over brand gradient."""
    W, H = size
    img = gradient(size)
    d = ImageDraw.Draw(img)
    icon_src = ROOT.parent / "store_assets" / "raw" / "icon.png"
    x0 = int(W * 0.07)
    if icon_src.exists():
        icon = Image.open(icon_src).convert("RGBA").resize((150, 150), Image.LANCZOS)
        img.alpha_composite(rounded(icon, 34), (x0, (H - 150) // 2))
        x0 += 150 + 44
    title = ImageFont.truetype(str(DISPLAY), 84)
    tag = ImageFont.truetype(str(BODY), 34)
    d.text((x0, H / 2 - 18), "OffRoad", font=title, fill=WHITE, anchor="ls")
    d.text((x0 + 4, H / 2 + 44), "Private AI. Anywhere. Anytime.", font=tag,
           fill=(255, 255, 255, 225), anchor="ls")
    img.convert("RGB").save(path, optimize=True)


def main():
    out_ios = ROOT / "appstore"
    out_play = ROOT / "playstore"
    for p in (out_ios / "iphone_6.9", out_ios / "ipad_13", out_play / "phone"):
        p.mkdir(parents=True, exist_ok=True)

    for p in (out_ios / "iphone_6.9", out_ios / "ipad_13", out_play / "phone"):
        for old in p.glob("*.png"):
            old.unlink()

    def slug(name):  # "02_chat_quantum" -> "chat_quantum"
        return name.split("_", 1)[1]

    n_phone = n_ipad = 0
    for name, head, sub in SHOTS:
        raw = ROOT / "raw" / "iphone" / f"{name}.png"
        if raw.exists():
            n_phone += 1
            out = f"{n_phone:02d}_{slug(name)}.png"
            compose(raw, (1320, 2868), head, sub).save(out_ios / "iphone_6.9" / out, optimize=True)
            compose(raw, (1080, 1920), head, sub, crop_chrome=True, screen_w_ratio=0.74).save(
                out_play / "phone" / out, optimize=True)

        ipad_raw = ROOT / "raw" / "ipad" / f"{name}.png"
        if ipad_raw.exists():
            n_ipad += 1
            compose(ipad_raw, (2064, 2752), head, sub, screen_w_ratio=0.84).save(
                out_ios / "ipad_13" / f"{n_ipad:02d}_{slug(name)}.png", optimize=True)

    feature_graphic(out_play / "feature_graphic_1024x500.png")
    print("done")


if __name__ == "__main__":
    main()
