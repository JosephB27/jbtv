sub init()
    m.top.observeField("photoData", "onDataChange")
end sub

sub onDataChange()
    data = m.top.photoData
    if data <> invalid and data.current <> invalid
        m.top.photoUrl = data.current
    else
        m.top.photoUrl = ""
    end if
end sub
