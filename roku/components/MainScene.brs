sub init()
    m.constants = GetConstants()

    ' Background
    m.bgBottom = m.top.findNode("bgBottom")
    m.bgTop = m.top.findNode("bgTop")
    m.photoBg = m.top.findNode("photoBg")
    m.photoOverlay = m.top.findNode("photoOverlay")
    m.loadingOverlay = m.top.findNode("loadingOverlay")
    m.statusLabel = m.top.findNode("statusLabel")
    m.currentPeriod = ""
    m.usePhotoBg = false

    ' Cards
    m.clockCard = m.top.findNode("clockCard")
    m.weatherCard = m.top.findNode("weatherCard")
    m.calendarCard = m.top.findNode("calendarCard")
    m.countdownCard = m.top.findNode("countdownCard")
    m.quoteCard = m.top.findNode("quoteCard")
    m.newsCard = m.top.findNode("newsCard")
    m.spotifyCard = m.top.findNode("spotifyCard")
    m.sportsCard = m.top.findNode("sportsCard")
    m.tickerCard = m.top.findNode("tickerCard")
    m.photoCard = m.top.findNode("photoCard")

    ' Photo background binding
    m.photoCard.observeField("photoUrl", "onPhotoUrlChange")

    ' Start data fetcher with auto-discovery
    m.dataFetcher = createObject("roSGNode", "DataFetcher")
    m.dataFetcher.pollInterval = m.constants.POLL_INTERVAL
    m.dataFetcher.useDiscovery = true
    m.dataFetcher.observeField("responseData", "onDataReceived")
    m.dataFetcher.observeField("connectionStatus", "onConnectionStatus")
    m.dataFetcher.control = "run"

    ' Focus setup
    m.focusIndex = 0
    m.focusableCards = [m.clockCard, m.weatherCard, m.calendarCard, m.countdownCard, m.spotifyCard, m.sportsCard]
    m.top.setFocus(true)

    ' Burn-in protection: shift the entire grid by a few pixels every 2 minutes
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

    ' Fade out loading overlay on first data
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

    ' Distribute data to cards
    if data.clock <> invalid
        m.clockCard.greeting = data.clock.greeting
        m.clockCard.period = data.clock.period
        updateBackground(data.clock.period)
    end if

    if data.weather <> invalid
        m.weatherCard.weatherData = data.weather
    end if

    if data.calendar <> invalid
        m.calendarCard.calendarData = data.calendar
    end if

    if data.countdowns <> invalid
        m.countdownCard.countdownData = data.countdowns
    end if

    if data.quote <> invalid
        m.quoteCard.quoteText = data.quote.text
        m.quoteCard.quoteAuthor = data.quote.author
    end if

    if data.news <> invalid
        m.newsCard.newsData = data.news
    end if

    if data.spotify <> invalid
        m.spotifyCard.spotifyData = data.spotify
    end if

    if data.sports <> invalid
        m.sportsCard.sportsData = data.sports
    end if

    if data.tickers <> invalid
        m.tickerCard.tickerData = data.tickers
    end if

    if data.photos <> invalid
        m.photoCard.photoData = data.photos
    end if
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

    ' Crossfade: set top to new image, fade in, then swap bottom
    m.bgTop.uri = newBg
    m.bgTop.opacity = 0.0

    ' Simple fade animation
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
    ' Cycle through 4 positions: (0,0), (3,0), (3,3), (0,3)
    offsets = [[0, 0], [3, 0], [3, 3], [0, 3]]
    m.burnInStep = (m.burnInStep + 1) mod 4
    offset = offsets[m.burnInStep]
    m.cardGrid.translation = offset
end sub

sub onBgFadeComplete()
    ' Swap bottom to match top, reset top
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
        ' Toggle photo background mode
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
        ' Advance news
        m.newsCard.callFunc("advanceNews")
        return true
    end if

    return false
end function
