sub init()
    m.eventList = m.top.findNode("eventList")
    m.emptyLabel = m.top.findNode("emptyLabel")
    m.top.observeField("calendarData", "onDataChange")
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

    for each event in events
        row = createObject("roSGNode", "Group")

        ' Accent dot
        dot = createObject("roSGNode", "Rectangle")
        dot.width = 6
        dot.height = 50
        dot.translation = [0, 0]
        if event.isNext = true
            dot.color = "0x00D4AAFF"
        else
            dot.color = "0xFFFFFF44"
        end if
        row.appendChild(dot)

        ' Time
        timeLabel = createObject("roSGNode", "Label")
        timeLabel.text = event.time
        timeLabel.font = "font:SmallSystemFont"
        timeLabel.translation = [20, 0]
        if event.isNext = true
            timeLabel.color = "0x00D4AAFF"
        else
            timeLabel.color = "0xFFFFFFCC"
        end if
        row.appendChild(timeLabel)

        ' Title
        titleLabel = createObject("roSGNode", "Label")
        titleLabel.text = event.title
        titleLabel.font = "font:SmallSystemFont"
        titleLabel.color = "0xFFFFFFFF"
        titleLabel.width = 900
        titleLabel.translation = [200, 0]
        row.appendChild(titleLabel)

        ' Duration
        if event.duration <> invalid
            durLabel = createObject("roSGNode", "Label")
            durLabel.text = "(" + event.duration + ")"
            durLabel.font = "font:SmallestSystemFont"
            durLabel.color = "0xBBBBBB99"
            durLabel.translation = [200, 30]
            row.appendChild(durLabel)
        end if

        ' "In X min" badge for next event
        if event.isNext = true and event.minutesUntil <> invalid and event.minutesUntil > 0
            badge = createObject("roSGNode", "Label")
            if event.minutesUntil >= 60
                badge.text = "in " + Str(int(event.minutesUntil / 60)).trim() + "h " + Str(event.minutesUntil mod 60).trim() + "m"
            else
                badge.text = "in " + Str(event.minutesUntil).trim() + " min"
            end if
            badge.font = "font:SmallestSystemFont"
            badge.color = "0x00D4AAFF"
            badge.translation = [900, 0]
            row.appendChild(badge)
        end if

        m.eventList.appendChild(row)
    end for
end sub
