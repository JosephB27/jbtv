sub init()
    m.theme = GetTheme()
    m.card = m.top.findNode("card")
    m.tempLabel = m.top.findNode("tempLabel")
    m.descLabel = m.top.findNode("descLabel")
    m.detailLabel = m.top.findNode("detailLabel")
    m.weatherIcon = m.top.findNode("weatherIcon")
    m.forecastRow = m.top.findNode("forecastRow")
    m.currentGroup = m.top.findNode("currentGroup")
    m.emptyLabel = m.top.findNode("emptyLabel")

    m.top.observeField("weatherData", "onDataChange")
    m.top.observeField("cardWidth", "onSizeChange")
    m.top.observeField("cardHeight", "onSizeChange")
end sub

sub onSizeChange()
    m.card.cardWidth = m.top.cardWidth
    m.card.cardHeight = m.top.cardHeight
end sub

sub onDataChange()
    data = m.top.weatherData
    if data = invalid then return

    current = data.current
    if current <> invalid
        m.currentGroup.visible = true
        m.emptyLabel.visible = false

        m.tempLabel.text = Str(current.temp).trim() + chr(176)

        desc = current.description
        if desc <> invalid and len(desc) > 0
            m.descLabel.text = UCase(Left(desc, 1)) + Mid(desc, 2)
        end if

        detail = "Feels " + Str(current.feelsLike).trim() + chr(176)
        if current.humidity <> invalid
            detail = detail + "   " + Str(current.humidity).trim() + "% humidity"
        end if
        m.detailLabel.text = detail

        if current.icon <> invalid and current.icon <> ""
            m.weatherIcon.uri = "https://openweathermap.org/img/wn/" + current.icon + "@2x.png"
        end if
    else
        m.currentGroup.visible = false
        m.emptyLabel.visible = true
    end if

    ' Forecast
    m.forecastRow.removeChildrenIndex(m.forecastRow.getChildCount(), 0)
    forecast = data.forecast
    if forecast <> invalid
        for each day in forecast
            col = createObject("roSGNode", "Group")

            dayLabel = createObject("roSGNode", "Label")
            dayLabel.text = UCase(Left(day.dayName, 3))
            dayLabel.color = m.theme.color.accentSoft
            dayLabel.horizAlign = "center"
            dayLabel.width = 80
            col.appendChild(dayLabel)

            icon = createObject("roSGNode", "Poster")
            icon.width = 28
            icon.height = 28
            icon.translation = [26, 20]
            if day.icon <> invalid
                icon.uri = "https://openweathermap.org/img/wn/" + day.icon + "@2x.png"
            end if
            col.appendChild(icon)

            tempLabel = createObject("roSGNode", "Label")
            tempLabel.text = Str(day.high).trim() + chr(176) + " / " + Str(day.low).trim() + chr(176)
            tempLabel.color = m.theme.color.muted
            tempLabel.horizAlign = "center"
            tempLabel.width = 80
            tempLabel.translation = [0, 52]
            col.appendChild(tempLabel)

            m.forecastRow.appendChild(col)
        end for
    end if
end sub
