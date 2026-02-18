' JBTV Theme Constants
' Centralized design tokens — all visual values in one place.
' Inspired by SGDEX flat theme dictionary pattern.
'
' Usage: t = GetTheme()  then  t.color.primary, t.font.sizeH1, etc.

function GetTheme()
    return {
        ' ── Colors ──────────────────────────────────────────
        color: {
            ' Text
            primary:    "0xFFFFFFFF"
            secondary:  "0xFFFFFFBB"
            tertiary:   "0xFFFFFF77"
            muted:      "0xFFFFFF44"
            faint:      "0xFFFFFF22"

            ' Accent
            accent:     "0x00D4AAFF"
            accentSoft: "0x00D4AA99"
            accentDim:  "0x00D4AA55"

            ' Semantic
            positive:   "0x4CAF50FF"
            negative:   "0xFF5252FF"
            warning:    "0xFFA726FF"
            live:       "0xFF3B30FF"

            ' Surfaces
            cardFill:       "0xFFFFFF20"
            cardFillHover:  "0xFFFFFF35"
            cardBorder:     "0xFFFFFF40"
            cardBorderHover:"0xFFFFFF60"
            cardShadow:     "0x0000001A"
            overlay:        "0x000000AA"
            progressBg:     "0xFFFFFF15"
            pillBg:         "0xFFFFFF18"
        }

        ' ── Typography (font sizes in px) ──────────────────
        font: {
            ' Display
            sizeHero:   96
            sizeH1:     72
            sizeH2:     36
            sizeH3:     24
            sizeH4:     21

            ' Body
            sizeBody:   18
            sizeCaption:15
            sizeMicro:  12

            ' Font paths
            thin:       "pkg:/fonts/Inter-Thin.ttf"
            light:      "pkg:/fonts/Inter-Light.ttf"
            regular:    "pkg:/fonts/Inter-Regular.ttf"
            medium:     "pkg:/fonts/Inter-Medium.ttf"
            bold:       "pkg:/fonts/Inter-Bold.ttf"
        }

        ' ── Spacing (in px) ────────────────────────────────
        spacing: {
            xs: 4
            sm: 8
            md: 12
            lg: 18
            xl: 24
            xxl: 36
        }

        ' ── Layout ─────────────────────────────────────────
        layout: {
            ' Screen
            screenW:    1920
            screenH:    1080

            ' Safe zone insets
            safeTop:    54
            safeBottom: 54
            safeLeft:   96
            safeRight:  96

            ' Grid
            gutter:     24
            columns:    3

            ' Card corner radius (matches mask PNGs)
            cornerRadius: 16
        }

        ' ── Animation ──────────────────────────────────────
        anim: {
            durationFast:   0.2
            durationNormal: 0.4
            durationSlow:   0.8
            durationBgFade: 2.0

            easeFadeIn:     "outCubic"
            easeFadeOut:    "inCubic"
            easeSlide:      "outCubic"
            easeSpring:     "outBack"

            ' Entrance stagger delay per card (seconds)
            staggerDelay:   0.08
        }

        ' ── Card Sizes ─────────────────────────────────────
        cards: {
            ' Row 1: Clock + Weather (2 cards, full width)
            clockW:     864
            clockH:     240
            weatherW:   864
            weatherH:   240

            ' Row 2: Calendar + Countdown + Quote/News
            calendarW:  576
            calendarH:  330
            countdownW: 474
            countdownH: 330
            quoteW:     702
            quoteH:     138
            newsW:      702
            newsH:      168

            ' Row 3: Spotify + Sports
            spotifyW:   576
            spotifyH:   264
            sportsW:    576
            sportsH:    264

            ' Ticker (full width bottom bar)
            tickerW:    1728
            tickerH:    72
        }

        ' ── Masks (paths to mask PNGs) ─────────────────────
        masks: {
            roundedCard:    "pkg:/images/mask_rounded_16.png"
            roundedSmall:   "pkg:/images/mask_rounded_8.png"
            fadeBottom:      "pkg:/images/mask_fade_bottom.png"
            fadeRight:       "pkg:/images/mask_fade_right.png"
            circle:          "pkg:/images/mask_circle.png"
        }
    }
end function
