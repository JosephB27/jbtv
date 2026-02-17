sub init()
    m.nowPlayingGroup = m.top.findNode("nowPlayingGroup")
    m.recentGroup = m.top.findNode("recentGroup")
    m.albumArt = m.top.findNode("albumArt")
    m.trackLabel = m.top.findNode("trackLabel")
    m.artistLabel = m.top.findNode("artistLabel")
    m.albumLabel = m.top.findNode("albumLabel")
    m.progressBg = m.top.findNode("progressBg")
    m.progressFill = m.top.findNode("progressFill")
    m.recentList = m.top.findNode("recentList")

    m.top.observeField("spotifyData", "onDataChange")
end sub

sub onDataChange()
    data = m.top.spotifyData
    if data = invalid then return

    np = data.nowPlaying
    if np <> invalid and np.isPlaying = true
        ' Show now playing
        m.nowPlayingGroup.visible = true
        m.recentGroup.visible = false

        if np.albumArt <> invalid
            m.albumArt.uri = np.albumArt
        end if
        m.trackLabel.text = np.name
        m.artistLabel.text = np.artist
        m.albumLabel.text = np.albumName

        ' Progress bar
        if np.durationMs <> invalid and np.durationMs > 0 and np.progressMs <> invalid
            ratio = np.progressMs / np.durationMs
            m.progressFill.width = int(750 * ratio)
        end if
    else
        ' Show recent tracks
        m.nowPlayingGroup.visible = false
        m.recentGroup.visible = true

        m.recentList.removeChildrenIndex(m.recentList.getChildCount(), 0)
        recentTracks = data.recentTracks
        if recentTracks <> invalid
            count = 0
            for each track in recentTracks
                if count >= 5 then exit for
                row = createObject("roSGNode", "Group")

                thumb = createObject("roSGNode", "Poster")
                thumb.width = 60
                thumb.height = 60
                if track.albumArt <> invalid
                    thumb.uri = track.albumArt
                end if
                row.appendChild(thumb)

                name = createObject("roSGNode", "Label")
                name.text = track.name
                name.font = "font:SmallSystemFont"
                name.color = "0xFFFFFFFF"
                name.width = 700
                name.translation = [80, 0]
                row.appendChild(name)

                artist = createObject("roSGNode", "Label")
                artist.text = track.artist
                artist.font = "font:SmallestSystemFont"
                artist.color = "0xBBBBBBFF"
                artist.width = 700
                artist.translation = [80, 30]
                row.appendChild(artist)

                m.recentList.appendChild(row)
                count = count + 1
            end for
        end if
    end if
end sub
