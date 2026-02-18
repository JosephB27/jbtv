sub init()
    m.theme = GetTheme()
    m.card = m.top.findNode("card")
    m.countdownList = m.top.findNode("countdownList")
    m.top.observeField("countdownData", "onDataChange")
    m.top.observeField("cardWidth", "onSizeChange")
    m.top.observeField("cardHeight", "onSizeChange")
end sub

sub onSizeChange()
    m.card.cardWidth = m.top.cardWidth
    m.card.cardHeight = m.top.cardHeight
end sub

sub onDataChange()
    data = m.top.countdownData
    if data = invalid then return

    m.countdownList.removeChildrenIndex(m.countdownList.getChildCount(), 0)

    maxItems = 2
    count = 0
    for each item in data
        if count >= maxItems then exit for
        if item.isPast <> true
            row = createObject("roSGNode", "Group")

            nameLabel = createObject("roSGNode", "Label")
            nameLabel.text = item.label
            nameLabel.width = 300
            nameLabel.color = m.theme.color.secondary
            row.appendChild(nameLabel)

            daysLabel = createObject("roSGNode", "Label")
            daysLabel.horizAlign = "right"
            daysLabel.width = 380
            daysLeft = item.daysLeft
            if daysLeft = 0
                daysLabel.text = "Today"
                daysLabel.color = m.theme.color.accent
            else if daysLeft = 1
                daysLabel.text = "Tomorrow"
                daysLabel.color = m.theme.color.accent
            else
                daysLabel.text = Str(daysLeft).trim() + " days"
                daysLabel.color = m.theme.color.accent
            end if
            row.appendChild(daysLabel)

            m.countdownList.appendChild(row)
            count = count + 1
        end if
    end for
end sub
