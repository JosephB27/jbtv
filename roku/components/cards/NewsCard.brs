sub init()
    m.theme = GetTheme()
    m.card = m.top.findNode("card")
    m.sourceLabel = m.top.findNode("sourceLabel")
    m.headlineLabel = m.top.findNode("headlineLabel")
    m.timeLabel = m.top.findNode("timeLabel")
    m.dotRow = m.top.findNode("dotRow")

    m.newsItems = []
    m.currentIndex = 0

    m.top.observeField("newsData", "onDataChange")
    m.top.observeField("cardWidth", "onSizeChange")
    m.top.observeField("cardHeight", "onSizeChange")

    m.rotateTimer = m.top.createChild("Timer")
    m.rotateTimer.repeat = true
    m.rotateTimer.duration = 8
    m.rotateTimer.observeField("fire", "onRotate")
    m.rotateTimer.control = "start"
end sub

sub onSizeChange()
    m.card.cardWidth = m.top.cardWidth
    m.card.cardHeight = m.top.cardHeight
end sub

sub onDataChange()
    data = m.top.newsData
    if data = invalid then return
    m.newsItems = data
    m.currentIndex = 0
    buildDots()
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

    if item.source <> invalid
        m.sourceLabel.text = UCase(item.source)
    end if
    m.headlineLabel.text = item.title
    if item.publishedAt <> invalid
        m.timeLabel.text = item.publishedAt
    else
        m.timeLabel.text = ""
    end if
    updateDots()
end sub

sub buildDots()
    m.dotRow.removeChildrenIndex(m.dotRow.getChildCount(), 0)
    total = m.newsItems.count()
    if total <= 1 then return
    for i = 0 to total - 1
        dot = createObject("roSGNode", "Rectangle")
        dot.width = 5
        dot.height = 5
        dot.color = "0xFFFFFF"
        dot.opacity = 0.15
        m.dotRow.appendChild(dot)
    end for
end sub

sub updateDots()
    for i = 0 to m.dotRow.getChildCount() - 1
        dot = m.dotRow.getChild(i)
        if dot <> invalid
            dot.opacity = iif(i = m.currentIndex, 0.8, 0.15)
        end if
    end for
end sub

sub advanceNews()
    if m.newsItems.count() > 0
        m.currentIndex = (m.currentIndex + 1) mod m.newsItems.count()
        showCurrent()
        m.rotateTimer.control = "start"
    end if
end sub

function iif(condition as boolean, trueVal as float, falseVal as float) as float
    if condition then return trueVal
    return falseVal
end function
