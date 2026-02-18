sub init()
    m.theme = GetTheme()

    m.greetingLabel = m.top.findNode("greetingLabel")
    m.timeLabel = m.top.findNode("timeLabel")
    m.dateLabel = m.top.findNode("dateLabel")
    m.card = m.top.findNode("card")

    m.top.observeField("greeting", "onDataChange")
    m.top.observeField("cardWidth", "onSizeChange")
    m.top.observeField("cardHeight", "onSizeChange")

    ' Sync-to-minute timer (rocute pattern)
    m.clockTimer = m.top.createChild("Timer")
    m.clockTimer.repeat = true
    m.clockTimer.duration = 1
    m.clockTimer.observeField("fire", "onTick")
    m.clockTimer.control = "start"
    m.synced = false
    onTick()
end sub

sub onSizeChange()
    m.card.cardWidth = m.top.cardWidth
    m.card.cardHeight = m.top.cardHeight
end sub

sub onDataChange()
    m.greetingLabel.text = m.top.greeting
end sub

sub onTick()
    now = CreateObject("roDateTime")
    now.toLocalTime()

    hours = now.getHours()
    minutes = now.getMinutes()
    seconds = now.getSeconds()

    ' Sync to minute boundary
    if not m.synced and seconds < 58
        m.clockTimer.duration = 60 - seconds
        m.synced = true
    else if m.synced and m.clockTimer.duration <> 60
        m.clockTimer.duration = 60
    end if

    ' 12-hour format
    ampm = "AM"
    if hours >= 12 then ampm = "PM"
    if hours > 12 then hours = hours - 12
    if hours = 0 then hours = 12

    minStr = Right("0" + Str(minutes).trim(), 2)
    m.timeLabel.text = Str(hours).trim() + ":" + minStr + " " + ampm

    ' Date
    days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    dow = now.getDayOfWeek()
    m.dateLabel.text = days[dow] + ", " + months[now.getMonth() - 1] + " " + Str(now.getDayOfMonth()).trim()
end sub
