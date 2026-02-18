sub init()
    m.theme = GetTheme()
    m.tickerRow1 = m.top.findNode("tickerRow1")
    m.tickerRow2 = m.top.findNode("tickerRow2")
    m.tickerViewport = m.top.findNode("tickerViewport")

    m.top.observeField("tickerData", "onDataChange")
    m.top.observeField("tickerWidth", "onWidthChange")

    m.scrollTimer = m.top.createChild("Timer")
    m.scrollTimer.repeat = true
    m.scrollTimer.duration = 0.03
    m.scrollTimer.observeField("fire", "onScroll")
    m.scrollX = 0
    m.contentWidth = 0
    m.viewportW = 1760
end sub

sub onWidthChange()
    m.viewportW = m.top.tickerWidth
    m.tickerViewport.clippingRect = [0, 0, m.viewportW, 44]
end sub

sub onDataChange()
    data = m.top.tickerData
    if data = invalid then return

    buildTickerRow(m.tickerRow1, data)
    buildTickerRow(m.tickerRow2, data)

    m.contentWidth = data.count() * 140
    m.tickerRow2.translation = [m.contentWidth, 0]
    m.scrollX = 0

    if m.contentWidth > m.viewportW
        m.scrollTimer.control = "start"
    else
        m.scrollTimer.control = "stop"
    end if
end sub

sub buildTickerRow(row as object, data as object)
    row.removeChildrenIndex(row.getChildCount(), 0)

    for each ticker in data
        item = createObject("roSGNode", "Group")

        symLabel = createObject("roSGNode", "Label")
        symLabel.text = ticker.symbol
        symLabel.color = m.theme.color.secondary
        item.appendChild(symLabel)

        priceLabel = createObject("roSGNode", "Label")
        priceStr = "$"
        if ticker.price >= 1000
            priceStr = priceStr + Str(int(ticker.price)).trim()
        else
            whole = int(ticker.price)
            frac = int((ticker.price - whole) * 100)
            priceStr = priceStr + Str(whole).trim() + "." + Right("0" + Str(frac).trim(), 2)
        end if
        priceLabel.text = priceStr
        priceLabel.color = m.theme.color.muted
        priceLabel.translation = [60, 0]
        item.appendChild(priceLabel)

        cp = ticker.changePercent
        if cp <> invalid
            changeLabel = createObject("roSGNode", "Label")
            arrow = ""
            if cp > 0
                arrow = "+"
                changeLabel.color = m.theme.color.positive
            else if cp < 0
                changeLabel.color = m.theme.color.negative
            else
                changeLabel.color = m.theme.color.muted
            end if
            changeLabel.text = arrow + Str(cp).trim() + "%"
            changeLabel.translation = [60, 18]
            item.appendChild(changeLabel)
        end if

        row.appendChild(item)
    end for
end sub

sub onScroll()
    m.scrollX = m.scrollX - 1
    if m.scrollX < -(m.contentWidth)
        m.scrollX = m.scrollX + m.contentWidth
    end if
    m.tickerRow1.translation = [m.scrollX, 0]
    m.tickerRow2.translation = [m.scrollX + m.contentWidth, 0]
end sub
