' JBTV Layout — Redesigned for visual impact
' Philosophy: fewer cards, bigger type, more whitespace.
' The clock is the hero. Everything else supports it.
'
' Grid: 2 columns, 3 rows + ticker
'   Row 1: Clock (left 60%) | Weather (right 40%)    — tall hero row
'   Row 2: Calendar | News | Quote/Countdown stack    — info row
'   Row 3: Spotify | Sports                           — media row
'   Bottom: Full-width ticker strip

function GetLayout()
    t = GetTheme()

    ' Screen
    scrW = 1920
    scrH = 1080

    ' Generous margins — let the background breathe
    marginL = 80
    marginT = 60
    marginR = 80
    marginB = 40

    ' Wider gutters for real separation
    gut = 40

    ' Usable area
    usableW = scrW - marginL - marginR   ' 1760
    usableH = scrH - marginT - marginB   ' 980

    ' ── Row 1: HERO ROW — Clock + Weather ──────────────
    ' Clock gets 60% of width, Weather gets 40%
    row1Y = marginT
    clockW = int(usableW * 0.58)          ' ~1020
    weatherW = usableW - clockW - gut     ' ~700
    row1H = 300                           ' Tall hero cards

    ' ── Row 2: INFO ROW — Calendar + News + Stack ──────
    row2Y = row1Y + row1H + gut           ' 400
    row2H = 280

    ' Three columns: Calendar (wide) | News (wide) | Quote+Countdown (narrow)
    calW = int(usableW * 0.35)            ' ~616
    newsW = int(usableW * 0.35)           ' ~616
    stackW = usableW - calW - newsW - (gut * 2)  ' ~448

    calX = marginL
    newsX = calX + calW + gut
    stackX = newsX + newsW + gut

    ' Quote and Countdown split the stack vertically
    quoteH = 120
    countdownH = row2H - quoteH - gut     ' 120

    ' ── Row 3: MEDIA ROW — Spotify + Sports ────────────
    row3Y = row2Y + row2H + gut           ' 720
    row3H = 210
    spotW = int(usableW * 0.5 - gut / 2)  ' ~870
    sportW = usableW - spotW - gut         ' ~850

    ' ── Ticker: bottom strip ───────────────────────────
    tickerY = scrH - marginB - 52         ' 988
    tickerH = 52

    return {
        usableW: usableW
        margin: { l: marginL, t: marginT, r: marginR, b: marginB }
        gut: gut

        row1: {
            y: row1Y
            h: row1H
            clock:   [marginL, row1Y]
            clockW:  clockW
            weather: [marginL + clockW + gut, row1Y]
            weatherW: weatherW
        }

        row2: {
            y: row2Y
            h: row2H
            calendar:  [calX, row2Y]
            calW:      calW
            news:      [newsX, row2Y]
            newsW:     newsW
            quote:     [stackX, row2Y]
            countdown: [stackX, row2Y + quoteH + gut]
            stackW:    stackW
            quoteH:    quoteH
            countdownH: countdownH
        }

        row3: {
            y: row3Y
            h: row3H
            spotify: [marginL, row3Y]
            spotW:   spotW
            sports:  [marginL + spotW + gut, row3Y]
            sportW:  sportW
        }

        ticker: {
            pos: [marginL, tickerY]
            w: usableW
            h: tickerH
        }
    }
end function
