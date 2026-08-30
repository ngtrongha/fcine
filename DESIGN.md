---
name: Cinematic Dark (F-Cine)
colors:
  primary: "#E50914"
  on-primary: "#FFFFFF"
  primary-container: "#380B0F"
  on-primary-container: "#FFD9DC"
  secondary: "#FF5252"
  on-secondary: "#FFFFFF"
  secondary-container: "#4D1418"
  tertiary: "#F59E0B"
  on-tertiary: "#000000"
  tertiary-container: "#452600"
  background: "#080B11"
  on-background: "#F1F5F9"
  surface: "#111622"
  on-surface: "#F1F5F9"
  surface-variant: "#1A2130"
  on-surface-variant: "#94A3B8"
  outline: "#2D3748"
  outline-variant: "#1E293B"
  error: "#FF4D4F"
  on-error: "#FFFFFF"
typography:
  display:
    fontFamily: Be Vietnam Pro
    fontSize: 32px
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 24px
    fontWeight: 700
    lineHeight: 1.25
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Be Vietnam Pro
    fontSize: 20px
    fontWeight: 600
    lineHeight: 1.3
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.5
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.5
  body-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.4
  label-md:
    fontFamily: Be Vietnam Pro
    fontSize: 12px
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: 0.02em
rounded:
  sm: 4px
  md: 8px
  lg: 12px
  xl: 16px
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
---

# F-Cine Design Specification

## Overview
F-Cine is a modern, high-performance streaming application designed with a zero-clutter, content-first philosophy. It provides users with instant access to movies, series, and anime with smooth animations, high-contrast readability in dark environments, and responsive touch controls optimized for one-handed mobile navigation.

## Colors
- **Primary (`#E50914` - Cinematic Crimson):** Drives primary actions, play buttons, active tabs, and branding highlights.
- **Secondary (`#FF5252` - Coral Accent):** Subtle highlight for live badges, trending indicators, and secondary CTAs.
- **Tertiary (`#F59E0B` - Amber Gold):** Dedicated to IMDb ratings, VIP badges, and favorite/bookmark highlights.
- **Background (`#080B11` - Deep Canvas):** OLED pitch black to ensure absolute visual immersion and power savings.
- **Surface (`#111622` - Elevated Cards):** Distinct card background with subtle tonal elevation.
- **Surface Variant (`#1A2130` - Interactive Chips):** Used for category chips, episode buttons, and server selector tiles.
- **On-Surface (`#F1F5F9` - Crisp White/Slate):** High contrast primary typography (contrast ratio > 12:1).
- **On-Surface Variant (`#94A3B8` - Muted Slate):** Metadata, release years, audio tags, and secondary labels.

## Typography
Uses **Be Vietnam Pro** across the entire UI for flawless Vietnamese diacritics and modern geometric aesthetics.
- **Display & Headline:** Bold, condensed letter spacing for movie titles and banner features.
- **Body & Labels:** Generous line-height for synopsis reading and episode number badges.

## Layout & Spacing
- Mobile-first 8px spacing grid; Desktop 12-column fluid grid.
- **Breakpoints:** Mobile `< 720px`, Tablet `720px - 1023px`, Desktop `≥ 1024px`.
- **Navigation:**
  - Mobile: Floating Bottom Navigation Bar (Glassmorphic, 64dp height).
  - Desktop: Left Navigation Sidebar (240px fixed width, brand logo on top, navigation items with hover feedback).
- **Grids:**
  - Mobile: 2-3 columns for movie posters (`childAspectRatio: 0.62`).
  - Desktop: 5-6 columns for movie posters (`childAspectRatio: 0.65`).
- **Margins & Gutters:**
  - Mobile: 16px horizontal margin, 10-12px gutter.
  - Desktop: 32-48px outer margin, 16-24px gutter.
- Touch target: 48dp × 48dp on mobile; 36-40dp on desktop with mouse pointer cursor and hover state.

## Elevation & Depth
- Tonal layering without murky drop shadows.
- Linear gradient scrim overlays on banners (`linear-gradient(to top, #080B11 0%, transparent 80%)`).
- Glassmorphism overlays with subtle backdrop filter blur and 1px border (`#2D3748`).

## Components
- **MovieCard:** 2:3 poster, rating badge top-left, quality badge (HD/Vietsub) bottom-right, smooth scale-down tap feedback on mobile, hover lift & subtle crimson glow on desktop.
- **HeroBanner:** 16:9 on mobile; cinematic ultra-wide (21:9 or 16:7) on desktop with synopsis preview, genre tags, and quick "Xem ngay" / "Chi tiết" buttons.
- **Dual-Pane Detail Layout (Desktop):** Left pane houses the large player/backdrop with server selector and episode grid; right pane displays rich synopsis, cast carousel, and related content.
- **Theater Player (Desktop):** Full-bleed cinema viewport, integrated right-side episode playlist drawer, and hardware keyboard shortcuts (`Space`, `←/→`, `F`, `M`).
- **EpisodeGrid:** 4-column compact grid on mobile; 8-10 column pill grid on desktop.
- **PlayerOverlay:** Touch gestures on mobile (volume left swipe, brightness right swipe, seek horizontal swipe); on-screen controls and keyboard navigation on desktop.

## Do's and Don'ts
- **Do:** Always keep dark mode as the default experience.
- **Do:** Adapt gracefully across screen sizes from 360px mobile to 4K ultra-wide desktop.
- **Do:** Highlight currently playing episode and selected server clearly.
- **Don't:** Never use pure white backgrounds or low-contrast gray text.
- **Don't:** Avoid blocking UI during network image loading (always use shimmer placeholders).

