sub init()
    m.theme = GetTheme()
    m.card = m.top.findNode("card")
    m.quoteLabel = m.top.findNode("quoteLabel")
    m.authorLabel = m.top.findNode("authorLabel")
    m.top.observeField("quoteText", "onDataChange")
    m.top.observeField("quoteAuthor", "onDataChange")
    m.top.observeField("cardWidth", "onSizeChange")
    m.top.observeField("cardHeight", "onSizeChange")
end sub

sub onSizeChange()
    m.card.cardWidth = m.top.cardWidth
    m.card.cardHeight = m.top.cardHeight
end sub

sub onDataChange()
    if m.top.quoteText <> ""
        m.quoteLabel.text = chr(8220) + m.top.quoteText + chr(8221)
    end if
    if m.top.quoteAuthor <> ""
        m.authorLabel.text = chr(8212) + " " + m.top.quoteAuthor
    end if
end sub
