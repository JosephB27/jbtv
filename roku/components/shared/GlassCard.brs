sub init()
    m.shadow = m.top.findNode("shadow")
    m.glassBg = m.top.findNode("glassBg")
    m.border = m.top.findNode("border")
    m.borderInner = m.top.findNode("borderInner")
    m.accentLine = m.top.findNode("accentLine")
    m.titleLabel = m.top.findNode("titleLabel")
    m.contentArea = m.top.findNode("contentArea")

    m.top.observeField("cardWidth", "onSizeChange")
    m.top.observeField("cardHeight", "onSizeChange")
    m.top.observeField("cardTitle", "onTitleChange")
    m.top.observeField("isFocused", "onFocusChange")

    onSizeChange()
    onTitleChange()
end sub

sub onSizeChange()
    w = m.top.cardWidth
    h = m.top.cardHeight

    m.shadow.width = w
    m.shadow.height = h

    m.glassBg.width = w
    m.glassBg.height = h

    m.border.width = w
    m.border.height = h
    m.borderInner.width = w - 2
    m.borderInner.height = h - 2
    m.borderInner.translation = [1, 1]

    m.accentLine.width = w
end sub

sub onTitleChange()
    title = m.top.cardTitle
    if title <> "" and title <> invalid
        m.titleLabel.text = UCase(title)
        m.titleLabel.visible = true
        m.contentArea.translation = [32, 52]
    else
        m.titleLabel.visible = false
        m.contentArea.translation = [32, 24]
    end if
end sub

sub onFocusChange()
    if m.top.isFocused
        m.glassBg.color = "0xFFFFFF2E"
        m.accentLine.color = "0x00D4AAFF"
    else
        m.glassBg.color = "0xFFFFFF1F"
        m.accentLine.color = "0x00D4AA99"
    end if
end sub
