sub init()
    m.sourceLabel = m.top.findNode("sourceLabel")
    m.headlineLabel = m.top.findNode("headlineLabel")
    m.timeLabel = m.top.findNode("timeLabel")
    m.indexLabel = m.top.findNode("indexLabel")

    m.newsItems = []
    m.currentIndex = 0

    m.top.observeField("newsData", "onDataChange")

    ' Auto-rotate timer
    m.rotateTimer = m.top.createChild("Timer")
    m.rotateTimer.repeat = true
    m.rotateTimer.duration = 8
    m.rotateTimer.observeField("fire", "onRotate")
    m.rotateTimer.control = "start"
end sub

sub onDataChange()
    data = m.top.newsData
    if data = invalid then return

    m.newsItems = data
    m.currentIndex = 0
    showCurrent()
end sub

sub onRotate()
    if m.newsItems.count() = 0 then return
    m.currentIndex = (m.currentIndex + 1) mod m.newsItems.count()
    showCurrent()
end sub

sub showCurrent()
    if m.newsItems.count() = 0 then return
    item = m.newsItems[m.currentIndex]
    if item = invalid then return

    m.sourceLabel.text = item.source
    m.headlineLabel.text = item.title
    if item.publishedAt <> invalid
        m.timeLabel.text = item.publishedAt
    else
        m.timeLabel.text = ""
    end if
    m.indexLabel.text = Str(m.currentIndex + 1).trim() + " / " + Str(m.newsItems.count()).trim()
end sub

' Called externally to manually advance
sub advanceNews()
    if m.newsItems.count() > 0
        m.currentIndex = (m.currentIndex + 1) mod m.newsItems.count()
        showCurrent()
        m.rotateTimer.control = "start"
    end if
end sub
