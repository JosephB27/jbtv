sub init()
    m.theme = GetTheme()
    m.card = m.top.findNode("card")
    m.nowPlayingGroup = m.top.findNode("nowPlayingGroup")
    m.recentGroup = m.top.findNode("recentGroup")
    m.emptyGroup = m.top.findNode("emptyGroup")
    m.albumArt = m.top.findNode("albumArt")
    m.trackLabel = m.top.findNode("trackLabel")
    m.artistLabel = m.top.findNode("artistLabel")
    m.albumLabel = m.top.findNode("albumLabel")
    m.progressFill = m.top.findNode("progressFill")
    m.recentList = m.top.findNode("recentList")

    m.top.observeField("spotifyData", "onDataChange")
    m.top.observeField("cardWidth", "onSizeChange")
    m.top.observeField("cardHeight", "onSizeChange")
end sub

sub onSizeChange()
    m.card.cardWidth = m.top.cardWidth
    m.card.cardHeight = m.top.cardHeight
end sub

sub onDataChange()
    data = m.top.spotifyData
    if data = invalid then return

    np = data.nowPlaying
    if np <> invalid and np.isPlaying = true
        m.nowPlayingGroup.visible = true
        m.recentGroup.visible = false
        m.emptyGroup.visible = false

        if np.albumArt <> invalid then m.albumArt.uri = np.albumArt
        m.trackLabel.text = np.name
        m.artistLabel.text = np.artist
        if np.albumName <> invalid then m.albumLabel.text = np.albumName

        if np.durationMs <> invalid and np.durationMs > 0 and np.progressMs <> invalid
            m.progressFill.width = int(700 * (np.progressMs / np.durationMs))
        end if
    else
        m.nowPlayingGroup.visible = false
        recentTracks = data.recentTracks
        if recentTracks <> invalid and recentTracks.count() > 0
            m.recentGroup.visible = true
            m.emptyGroup.visible = false
            m.recentList.removeChildrenIndex(m.recentList.getChildCount(), 0)
            count = 0
            for each track in recentTracks
                if count >= 3 then exit for
                row = createObject("roSGNode", "Group")

                name = createObject("roSGNode", "Label")
                name.text = track.name + "  —  " + track.artist
                name.color = m.theme.color.secondary
                name.width = 780
                row.appendChild(name)

                m.recentList.appendChild(row)
                count = count + 1
            end for
        else
            m.recentGroup.visible = false
            m.emptyGroup.visible = true
        end if
    end if
end sub
