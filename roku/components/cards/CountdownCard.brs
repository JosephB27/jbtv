sub init()
    m.countdownList = m.top.findNode("countdownList")
    m.top.observeField("countdownData", "onDataChange")
end sub

sub onDataChange()
    data = m.top.countdownData
    if data = invalid then return

    m.countdownList.removeChildrenIndex(m.countdownList.getChildCount(), 0)

    for each item in data
        row = createObject("roSGNode", "Group")

        ' Days number
        daysLabel = createObject("roSGNode", "Label")
        daysLabel.text = Str(item.daysLeft).trim()
        daysLabel.font = "font:LargeSystemFont"
        if item.isPast = true
            daysLabel.color = "0xBBBBBB66"
        else
            daysLabel.color = "0x00D4AAFF"
        end if
        row.appendChild(daysLabel)

        ' "days" suffix
        suffixLabel = createObject("roSGNode", "Label")
        if item.isPast = true
            suffixLabel.text = "days ago"
        else
            suffixLabel.text = "days"
        end if
        suffixLabel.font = "font:SmallestSystemFont"
        suffixLabel.color = "0xBBBBBB99"
        suffixLabel.translation = [100, 12]
        row.appendChild(suffixLabel)

        ' Label
        nameLabel = createObject("roSGNode", "Label")
        nameLabel.text = item.label
        nameLabel.font = "font:SmallSystemFont"
        nameLabel.width = 700
        nameLabel.translation = [200, 0]
        if item.isPast = true
            nameLabel.color = "0xBBBBBB66"
        else
            nameLabel.color = "0xFFFFFFFF"
        end if
        row.appendChild(nameLabel)

        ' Date
        dateLabel = createObject("roSGNode", "Label")
        dateLabel.text = item.date
        dateLabel.font = "font:SmallestSystemFont"
        dateLabel.color = "0xBBBBBB66"
        dateLabel.translation = [200, 32]
        row.appendChild(dateLabel)

        m.countdownList.appendChild(row)
    end for
end sub
