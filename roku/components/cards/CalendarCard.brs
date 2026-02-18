sub init()
    m.theme = GetTheme()
    m.card = m.top.findNode("card")
    m.eventList = m.top.findNode("eventList")
    m.emptyLabel = m.top.findNode("emptyLabel")
    m.eventFadeMask = m.top.findNode("eventFadeMask")

    m.top.observeField("calendarData", "onDataChange")
    m.top.observeField("cardWidth", "onSizeChange")
    m.top.observeField("cardHeight", "onSizeChange")
end sub

sub onSizeChange()
    m.card.cardWidth = m.top.cardWidth
    m.card.cardHeight = m.top.cardHeight
    m.eventFadeMask.maskSize = [m.top.cardWidth - 56, m.top.cardHeight - 60]
end sub

sub onDataChange()
    data = m.top.calendarData
    if data = invalid then return

    m.eventList.removeChildrenIndex(m.eventList.getChildCount(), 0)
    events = data.events
    if events = invalid or events.count() = 0
        m.emptyLabel.visible = true
        return
    end if
    m.emptyLabel.visible = false

    maxEvents = 5
    count = 0
    for each event in events
        if count >= maxEvents then exit for

        row = createObject("roSGNode", "Group")
        isNext = (event.isNext = true)

        ' Accent bar
        bar = createObject("roSGNode", "Rectangle")
        bar.width = 3
        bar.height = 32
        if isNext
            bar.color = m.theme.color.accent
        else
            bar.color = m.theme.color.faint
        end if
        row.appendChild(bar)

        ' Time
        timeLabel = createObject("roSGNode", "Label")
        timeLabel.text = event.time
        timeLabel.width = 80
        timeLabel.translation = [14, 0]
        if isNext
            timeLabel.color = m.theme.color.accent
        else
            timeLabel.color = m.theme.color.tertiary
        end if
        row.appendChild(timeLabel)

        ' Title
        titleLabel = createObject("roSGNode", "Label")
        titleLabel.text = event.title
        titleLabel.width = 400
        titleLabel.translation = [96, 0]
        titleLabel.color = m.theme.color.primary
        row.appendChild(titleLabel)

        ' Duration
        if event.duration <> invalid
            durLabel = createObject("roSGNode", "Label")
            durLabel.text = event.duration
            durLabel.translation = [96, 18]
            durLabel.color = m.theme.color.muted
            row.appendChild(durLabel)
        end if

        m.eventList.appendChild(row)
        count = count + 1
    end for
end sub
