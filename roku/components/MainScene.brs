sub init()
    m.constants = GetConstants()
    m.theme = GetTheme()
    m.lay = GetLayout()

    ' Background
    m.bgBottom = m.top.findNode("bgBottom")
    m.bgTop = m.top.findNode("bgTop")
    m.photoBg = m.top.findNode("photoBg")
    m.photoOverlay = m.top.findNode("photoOverlay")
    m.loadingOverlay = m.top.findNode("loadingOverlay")
    m.statusLabel = m.top.findNode("statusLabel")
    m.currentPeriod = ""
    m.usePhotoBg = false

    ' Cards — sized and positioned from layout constants
    m.clockCard = m.top.findNode("clockCard")
    m.clockCard.translation = m.lay.row1.clock
    m.clockCard.cardWidth = m.lay.row1.clockW
    m.clockCard.cardHeight = m.lay.row1.h

    m.weatherCard = m.top.findNode("weatherCard")
    m.weatherCard.translation = m.lay.row1.weather
    m.weatherCard.cardWidth = m.lay.row1.weatherW
    m.weatherCard.cardHeight = m.lay.row1.h

    m.calendarCard = m.top.findNode("calendarCard")
    m.calendarCard.translation = m.lay.row2.calendar
    m.calendarCard.cardWidth = m.lay.row2.calW
    m.calendarCard.cardHeight = m.lay.row2.h

    m.newsCard = m.top.findNode("newsCard")
    m.newsCard.translation = m.lay.row2.news
    m.newsCard.cardWidth = m.lay.row2.newsW
    m.newsCard.cardHeight = m.lay.row2.h

    m.quoteCard = m.top.findNode("quoteCard")
    m.quoteCard.translation = m.lay.row2.quote
    m.quoteCard.cardWidth = m.lay.row2.stackW
    m.quoteCard.cardHeight = m.lay.row2.quoteH

    m.countdownCard = m.top.findNode("countdownCard")
    m.countdownCard.translation = m.lay.row2.countdown
    m.countdownCard.cardWidth = m.lay.row2.stackW
    m.countdownCard.cardHeight = m.lay.row2.countdownH

    m.spotifyCard = m.top.findNode("spotifyCard")
    m.spotifyCard.translation = m.lay.row3.spotify
    m.spotifyCard.cardWidth = m.lay.row3.spotW
    m.spotifyCard.cardHeight = m.lay.row3.h

    m.sportsCard = m.top.findNode("sportsCard")
    m.sportsCard.translation = m.lay.row3.sports
    m.sportsCard.cardWidth = m.lay.row3.sportW
    m.sportsCard.cardHeight = m.lay.row3.h

    m.tickerCard = m.top.findNode("tickerCard")
    m.tickerCard.translation = m.lay.ticker.pos
    m.tickerCard.tickerWidth = m.lay.ticker.w

    m.photoCard = m.top.findNode("photoCard")

    ' Photo background binding
    m.photoCard.observeField("photoUrl", "onPhotoUrlChange")

    ' Hide all cards initially for entrance animation
    m.allCards = [m.clockCard, m.weatherCard, m.calendarCard, m.countdownCard, m.quoteCard, m.newsCard, m.spotifyCard, m.sportsCard, m.tickerCard]
    for each card in m.allCards
        card.opacity = 0.0
    end for
    m.entrancePlayed = false

    ' Start data fetcher
    m.dataFetcher = createObject("roSGNode", "DataFetcher")
    m.dataFetcher.pollInterval = m.constants.POLL_INTERVAL
    m.dataFetcher.observeField("responseData", "onDataReceived")
    m.dataFetcher.observeField("connectionStatus", "onConnectionStatus")
    m.dataFetcher.functionName = "doFetch"
    m.dataFetcher.control = "run"

    ' Focus
    m.focusIndex = 0
    m.top.setFocus(true)

    ' Burn-in protection
    m.cardGrid = m.top.findNode("cardGrid")
    m.burnInStep = 0
    m.burnInTimer = m.top.createChild("Timer")
    m.burnInTimer.repeat = true
    m.burnInTimer.duration = 120
    m.burnInTimer.observeField("fire", "onBurnInShift")
    m.burnInTimer.control = "start"
end sub

sub onDataReceived()
    data = m.dataFetcher.responseData
    if data = invalid then return

    if m.loadingOverlay.visible
        fadeOut = m.top.createChild("Animation")
        fadeOut.duration = 0.5
        fadeOut.easeFunction = "linear"
        interp = fadeOut.createChild("FloatFieldInterpolator")
        interp.key = [0.0, 1.0]
        interp.keyValue = [1.0, 0.0]
        interp.fieldToInterp = "loadingOverlay.opacity"
        fadeOut.observeField("state", "onLoadingFadeComplete")
        fadeOut.control = "start"
    end if

    ' Distribute data
    if data.clock <> invalid
        m.clockCard.greeting = data.clock.greeting
        m.clockCard.period = data.clock.period
        updateBackground(data.clock.period)
    end if
    if data.weather <> invalid then m.weatherCard.weatherData = data.weather
    if data.calendar <> invalid then m.calendarCard.calendarData = data.calendar
    if data.countdowns <> invalid then m.countdownCard.countdownData = data.countdowns
    if data.quote <> invalid
        m.quoteCard.quoteText = data.quote.text
        m.quoteCard.quoteAuthor = data.quote.author
    end if
    if data.news <> invalid then m.newsCard.newsData = data.news
    if data.spotify <> invalid then m.spotifyCard.spotifyData = data.spotify
    if data.sports <> invalid then m.sportsCard.sportsData = data.sports
    if data.tickers <> invalid then m.tickerCard.tickerData = data.tickers
    if data.photos <> invalid then m.photoCard.photoData = data.photos
end sub

sub updateBackground(period as string)
    if period = m.currentPeriod then return
    m.currentPeriod = period

    bgMap = {
        morning: "pkg:/images/bg_morning.png"
        afternoon: "pkg:/images/bg_afternoon.png"
        evening: "pkg:/images/bg_evening.png"
        night: "pkg:/images/bg_night.png"
    }

    newBg = bgMap[period]
    if newBg = invalid then newBg = bgMap.morning

    m.bgTop.uri = newBg
    m.bgTop.opacity = 0.0

    anim = m.top.createChild("Animation")
    anim.duration = 2.0
    anim.easeFunction = "linear"
    interp = anim.createChild("FloatFieldInterpolator")
    interp.key = [0.0, 1.0]
    interp.keyValue = [0.0, 1.0]
    interp.fieldToInterp = "bgTop.opacity"
    anim.observeField("state", "onBgFadeComplete")
    anim.control = "start"
end sub

sub onLoadingFadeComplete()
    m.loadingOverlay.visible = false
    if not m.entrancePlayed
        playEntranceAnimations()
        m.entrancePlayed = true
    end if
end sub

sub playEntranceAnimations()
    cardOrder = [m.clockCard, m.weatherCard, m.calendarCard, m.newsCard, m.quoteCard, m.countdownCard, m.spotifyCard, m.sportsCard, m.tickerCard]
    dur = 0.4

    for i = 0 to cardOrder.count() - 1
        card = cardOrder[i]
        delay = i * 0.08
        targetPos = card.translation

        card.translation = [targetPos[0], targetPos[1] + 24]

        fadeAnim = m.top.createChild("Animation")
        fadeAnim.duration = dur
        fadeAnim.delay = delay
        fadeAnim.easeFunction = "outCubic"

        fadeInterp = fadeAnim.createChild("FloatFieldInterpolator")
        fadeInterp.key = [0.0, 1.0]
        fadeInterp.keyValue = [0.0, 1.0]
        fadeInterp.fieldToInterp = card.id + ".opacity"

        slideInterp = fadeAnim.createChild("Vector2DFieldInterpolator")
        slideInterp.key = [0.0, 1.0]
        slideInterp.keyValue = [[targetPos[0], targetPos[1] + 24], targetPos]
        slideInterp.fieldToInterp = card.id + ".translation"

        fadeAnim.control = "start"
    end for
end sub

sub onConnectionStatus()
    status = m.dataFetcher.connectionStatus
    statusMap = {
        searching: "Searching for server..."
        connecting: "Connecting..."
        connected: "Connected"
        reconnecting: "Reconnecting..."
    }
    msg = statusMap[status]
    if msg <> invalid and m.statusLabel <> invalid
        m.statusLabel.text = msg
    end if
end sub

sub onBurnInShift()
    offsets = [[0, 0], [3, 0], [3, 3], [0, 3]]
    m.burnInStep = (m.burnInStep + 1) mod 4
    m.cardGrid.translation = offsets[m.burnInStep]
end sub

sub onBgFadeComplete()
    m.bgBottom.uri = m.bgTop.uri
    m.bgTop.opacity = 0.0
end sub

sub onPhotoUrlChange()
    url = m.photoCard.photoUrl
    if url <> "" and url <> invalid and m.usePhotoBg
        m.photoBg.uri = url
        m.photoBg.opacity = 1.0
        m.photoOverlay.opacity = 1.0
    else if not m.usePhotoBg
        m.photoBg.opacity = 0.0
        m.photoOverlay.opacity = 0.0
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if key = "options"
        m.usePhotoBg = not m.usePhotoBg
        if m.usePhotoBg
            url = m.photoCard.photoUrl
            if url <> "" and url <> invalid
                m.photoBg.uri = url
                m.photoBg.opacity = 1.0
                m.photoOverlay.opacity = 1.0
            end if
        else
            m.photoBg.opacity = 0.0
            m.photoOverlay.opacity = 0.0
        end if
        return true
    end if

    if key = "OK"
        m.newsCard.callFunc("advanceNews")
        return true
    end if

    return false
end function
