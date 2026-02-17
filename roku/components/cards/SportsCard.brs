sub init()
    m.teamList = m.top.findNode("teamList")
    m.top.observeField("sportsData", "onDataChange")
end sub

sub onDataChange()
    data = m.top.sportsData
    if data = invalid then return

    m.teamList.removeChildrenIndex(m.teamList.getChildCount(), 0)

    for each team in data
        row = createObject("roSGNode", "Group")

        ' Team logo
        if team.logo <> invalid
            logo = createObject("roSGNode", "Poster")
            logo.width = 60
            logo.height = 60
            logo.uri = team.logo
            row.appendChild(logo)
        end if

        ' Team name + league
        nameLabel = createObject("roSGNode", "Label")
        nameLabel.text = team.team
        nameLabel.font = "font:SmallSystemFont"
        nameLabel.color = "0xFFFFFFFF"
        nameLabel.translation = [80, 0]
        row.appendChild(nameLabel)

        leagueLabel = createObject("roSGNode", "Label")
        leagueLabel.text = team.league
        leagueLabel.font = "font:SmallestSystemFont"
        leagueLabel.color = "0xBBBBBB66"
        leagueLabel.translation = [80, 28]
        row.appendChild(leagueLabel)

        ' Last game
        if team.lastGame <> invalid
            lg = team.lastGame
            lastLabel = createObject("roSGNode", "Label")
            lastLabel.text = lg.result + " " + lg.score + " vs " + lg.opponent
            lastLabel.font = "font:SmallSystemFont"
            lastLabel.translation = [400, 0]
            if lg.result = "W"
                lastLabel.color = "0x4CAF50FF"
            else if lg.result = "L"
                lastLabel.color = "0xFF5252FF"
            else
                lastLabel.color = "0xFFFFFFCC"
            end if
            row.appendChild(lastLabel)
        end if

        ' Next game
        if team.nextGame <> invalid
            ng = team.nextGame
            nextLabel = createObject("roSGNode", "Label")
            nextLabel.text = "Next: vs " + ng.opponent + " " + ng.date + " " + ng.time
            nextLabel.font = "font:SmallestSystemFont"
            nextLabel.color = "0xBBBBBB99"
            nextLabel.translation = [400, 30]
            row.appendChild(nextLabel)
        end if

        m.teamList.appendChild(row)
    end for
end sub
