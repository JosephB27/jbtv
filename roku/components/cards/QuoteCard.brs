sub init()
    m.quoteLabel = m.top.findNode("quoteLabel")
    m.authorLabel = m.top.findNode("authorLabel")
    m.top.observeField("quoteText", "onDataChange")
    m.top.observeField("quoteAuthor", "onDataChange")
end sub

sub onDataChange()
    if m.top.quoteText <> ""
        m.quoteLabel.text = m.top.quoteText
    end if
    if m.top.quoteAuthor <> ""
        m.authorLabel.text = "— " + m.top.quoteAuthor
    end if
end sub
