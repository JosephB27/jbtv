sub init()
    m.tempLabel = m.top.findNode("tempLabel")
    m.feelsLikeLabel = m.top.findNode("feelsLikeLabel")
    m.weatherIcon = m.top.findNode("weatherIcon")
    m.descLabel = m.top.findNode("descLabel")
    m.detailsLabel = m.top.findNode("detailsLabel")
    m.sunLabel = m.top.findNode("sunLabel")
    m.forecastRow = m.top.findNode("forecastRow")

    m.top.observeField("weatherData", "onDataChange")
end sub

sub onDataChange()
    data = m.top.weatherData
    if data = invalid then return

    current = data.current
    if current <> invalid
        m.tempLabel.text = Str(current.temp).trim() + chr(176)
        m.feelsLikeLabel.text = "Feels like " + Str(current.feelsLike).trim() + chr(176)
        m.descLabel.text = UCase(Left(current.description, 1)) + Mid(current.description, 2)
        m.detailsLabel.text = "Humidity " + Str(current.humidity).trim() + "%  |  Wind " + Str(current.wind).trim() + " mph"

        ' Load weather icon from OpenWeatherMap
        if current.icon <> invalid and current.icon <> ""
            m.weatherIcon.uri = "https://openweathermap.org/img/wn/" + current.icon + "@4x.png"
        end if
    end if

    if data.sunrise <> invalid and data.sunset <> invalid
        m.sunLabel.text = "Sunrise " + data.sunrise + "  |  Sunset " + data.sunset
    end if

    ' Build forecast
    m.forecastRow.removeChildrenIndex(m.forecastRow.getChildCount(), 0)
    forecast = data.forecast
    if forecast <> invalid
        for each day in forecast
            dayGroup = createObject("roSGNode", "Group")

            dayLabel = createObject("roSGNode", "Label")
            dayLabel.text = day.dayName
            dayLabel.color = "0x00D4AAFF"
            dayLabel.font = "font:SmallestSystemFont"
            dayGroup.appendChild(dayLabel)

            icon = createObject("roSGNode", "Poster")
            icon.width = 60
            icon.height = 60
            icon.translation = [20, 28]
            if day.icon <> invalid
                icon.uri = "https://openweathermap.org/img/wn/" + day.icon + "@2x.png"
            end if
            dayGroup.appendChild(icon)

            tempRange = createObject("roSGNode", "Label")
            tempRange.text = Str(day.high).trim() + chr(176) + " / " + Str(day.low).trim() + chr(176)
            tempRange.color = "0xBBBBBBFF"
            tempRange.font = "font:SmallestSystemFont"
            tempRange.translation = [0, 92]
            dayGroup.appendChild(tempRange)

            m.forecastRow.appendChild(dayGroup)
        end for
    end if
end sub
