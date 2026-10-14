# Store assets

Captured from the real app in iOS simulators (iPhone 16 Pro Max, iPad Pro 13" M4)
with Qwen2.5 0.5B generating the replies on-device. Status bar set to 9:41.

## What to upload

### App Store Connect
| Slot | Files | Size |
|---|---|---|
| iPhone 6.9" screenshots | `appstore/iphone_6.9/01…07` | 1320×2868 |
| iPad 13" screenshots | `appstore/ipad_13/01…06` | 2064×2752 |
| iPhone app preview | `video/appstore_preview_iphone_886x1920.mp4` | 886×1920, 30 fps, 19.7 s, H.264 + AAC |

Apple scales the 6.9" set down for smaller iPhones, so these two screenshot sets are enough.

### Google Play Console
| Slot | File | Size |
|---|---|---|
| App icon | `playstore/icon_512.png` | 512×512 |
| Feature graphic | `playstore/feature_graphic_1024x500.png` | 1024×500 |
| Phone screenshots | `playstore/phone/01…07` | 1080×1920 |
| Promo video | `video/playstore_promo_1080x1920.mp4` | Play only takes a **YouTube URL** — upload this there (unlisted is fine) and paste the link. |

The Play screenshots crop out the iOS status bar and home indicator so they don't look iPhone-only.

## Suggested listing copy

**Name:** OffRoad: Private Offline AI
**Subtitle (App Store, 30 chars):** Private AI that runs offline
**Short description (Play, 80 chars):** Chat with powerful AI models that run entirely on your phone. No internet needed.

**Promotional text:** Run Gemma, Qwen, Phi and more right on your device. No account, no cloud, no tracking.

**Description:**
OffRoad puts capable AI models on your phone and runs them entirely on-device. Your prompts, images and voice never leave it.

• Private by design: no sign-in, no analytics, no servers. Conversations stay in the app.
• Works offline: download a model once, then use it anywhere, even with no signal.
• 14 open models: Google Gemma, Alibaba Qwen, Microsoft Phi, DeepSeek R1 and more, from 140 MB to 6 GB.
• Made for real work: clear formatting, code blocks with one-tap copy, stop and regenerate.
• Images and voice: attach photos for vision models, dictate with audio models, or talk hands-free in voice mode.
• Your choice of theme: follows light/dark mode, or pick your own.

An internet connection is only used to download the models you choose.

**Keywords (App Store, 100 chars):** offline ai,private chatbot,on-device,local llm,gemma,qwen,no internet,assistant,privacy,chat

## Regenerating

```bash
python3 store_assets/compose.py
```

Headlines and order are in `SHOTS` at the top of `compose.py`. Raw captures live in `raw/`; replace a file there and rerun. Fonts come from the app's own `assets/fonts`.
