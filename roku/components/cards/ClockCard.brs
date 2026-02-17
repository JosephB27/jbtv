sub init()
    m.greetingLabel = m.top.findNode("greetingLabel")
    m.timeLabel = m.top.findNode("timeLabel")
    m.dateLabel = m.top.findNode("dateLabel")

    m.top.observeField("greeting", "onDataChange")

    ' Local clock timer — updates every second
    m.clockTimer = m.top.createChild("Timer")
    m.clockTimer.repeat = true
    m.clockTimer.duration = 1
    m.clockTimer.observeField("fire", "onTick")
    m.clockTimer.control = "start"
    onTick()
end sub

sub onDataChange()
    m.greetingLabel.text = m.top.greeting
end sub

sub onTick()
    now = CreateObject("roDateTime")
    now.toLocalTime()

    ' Format time
    hours = now.getHours()
    minutes = now.getMinutes()
    ampm = "AM"
    if hours >= 12 then ampm = "PM"
    if hours > 12 then hours = hours - 12
    if hours = 0 then hours = 12
    minStr = Right("0" + Str(minutes).trim(), 2)
    m.timeLabel.text = Str(hours).trim() + ":" + minStr + " " + ampm

    ' Format date
    days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    dow = now.getDayOfWeek()
    m.dateLabel.text = days[dow] + ", " + months[now.getMonth() - 1] + " " + Str(now.getDayOfMonth()).trim() + ", " + Str(now.getYear()).trim()
end sub
