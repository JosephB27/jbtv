sub init()
    m.tickerRow = m.top.findNode("tickerRow")
    m.tickerContainer = m.top.findNode("tickerContainer")
    m.tickerContainer.translation = [20, 30]

    m.top.observeField("tickerData", "onDataChange")

    ' Scroll animation timer
    m.scrollTimer = m.top.createChild("Timer")
    m.scrollTimer.repeat = true
    m.scrollTimer.duration = 0.03
    m.scrollTimer.observeField("fire", "onScroll")
    m.scrollX = 0
    m.scrollWidth = 0
end sub

sub onDataChange()
    data = m.top.tickerData
    if data = invalid then return

    m.tickerRow.removeChildrenIndex(m.tickerRow.getChildCount(), 0)

    for each ticker in data
        item = createObject("roSGNode", "Group")

        ' Symbol
        symLabel = createObject("roSGNode", "Label")
        symLabel.text = ticker.symbol
        symLabel.font = "font:MediumSystemFont"
        symLabel.color = "0xFFFFFFFF"
        item.appendChild(symLabel)

        ' Price
        priceLabel = createObject("roSGNode", "Label")
        priceStr = "$"
        if ticker.price >= 1000
            priceStr = priceStr + Str(int(ticker.price)).trim()
        else
            ' Format with 2 decimal places
            whole = int(ticker.price)
            frac = int((ticker.price - whole) * 100)
            priceStr = priceStr + Str(whole).trim() + "." + Right("0" + Str(frac).trim(), 2)
        end if
        priceLabel.text = priceStr
        priceLabel.font = "font:SmallSystemFont"
        priceLabel.color = "0xBBBBBBFF"
        priceLabel.translation = [120, 8]
        item.appendChild(priceLabel)

        ' Change %
        changeLabel = createObject("roSGNode", "Label")
        cp = ticker.changePercent
        if cp <> invalid
            arrow = ""
            if cp > 0
                arrow = "+"
                changeLabel.color = "0x4CAF50FF"
            else if cp < 0
                changeLabel.color = "0xFF5252FF"
            else
                changeLabel.color = "0xBBBBBBFF"
            end if
            changeLabel.text = arrow + Str(cp).trim() + "%"
        end if
        changeLabel.font = "font:SmallSystemFont"
        changeLabel.translation = [280, 8]
        item.appendChild(changeLabel)

        m.tickerRow.appendChild(item)
    end for

    ' Calculate total width for scrolling (approximate)
    m.scrollWidth = data.count() * 420
    if m.scrollWidth > 3600
        m.scrollTimer.control = "start"
    else
        m.scrollTimer.control = "stop"
        m.tickerContainer.translation = [20, 30]
    end if
end sub

sub onScroll()
    m.scrollX = m.scrollX - 1
    if m.scrollX < -(m.scrollWidth)
        m.scrollX = 3600
    end if
    m.tickerRow.translation = [m.scrollX, 0]
end sub
