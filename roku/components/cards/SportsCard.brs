sub init()
    m.theme = GetTheme()
    m.card = m.top.findNode("card")
    m.teamList = m.top.findNode("teamList")
    m.emptyLabel = m.top.findNode("emptyLabel")
    m.top.observeField("sportsData", "onDataChange")
    m.top.observeField("cardWidth", "onSizeChange")
    m.top.observeField("cardHeight", "onSizeChange")
end sub

sub onSizeChange()
    m.card.cardWidth = m.top.cardWidth
    m.card.cardHeight = m.top.cardHeight
end sub

sub onDataChange()
    data = m.top.sportsData
    if data = invalid then return
    m.teamList.removeChildrenIndex(m.teamList.getChildCount(), 0)

    if data.count() = 0
        m.emptyLabel.visible = true
        return
    end if
    m.emptyLabel.visible = false

    for each team in data
        row = createObject("roSGNode", "Group")

        nameLabel = createObject("roSGNode", "Label")
        nameLabel.text = team.team
        nameLabel.color = m.theme.color.primary
        nameLabel.width = 140
        row.appendChild(nameLabel)

        leagueLabel = createObject("roSGNode", "Label")
        leagueLabel.text = UCase(team.league)
        leagueLabel.color = m.theme.color.muted
        leagueLabel.translation = [0, 18]
        row.appendChild(leagueLabel)

        if team.lastGame <> invalid
            lg = team.lastGame
            resultLabel = createObject("roSGNode", "Label")
            resultLabel.translation = [160, 0]
            if lg.result = "W"
                resultLabel.text = "W  " + lg.score + "  vs " + lg.opponent
                resultLabel.color = m.theme.color.positive
            else if lg.result = "L"
                resultLabel.text = "L  " + lg.score + "  vs " + lg.opponent
                resultLabel.color = m.theme.color.negative
            else
                resultLabel.text = lg.score + "  vs " + lg.opponent
                resultLabel.color = m.theme.color.secondary
            end if
            resultLabel.width = 600
            row.appendChild(resultLabel)
        end if

        if team.nextGame <> invalid
            ng = team.nextGame
            nextLabel = createObject("roSGNode", "Label")
            nextLabel.text = "Next: " + ng.opponent + "  " + ng.date
            nextLabel.color = m.theme.color.muted
            nextLabel.width = 600
            nextLabel.translation = [160, 18]
            row.appendChild(nextLabel)
        end if

        m.teamList.appendChild(row)
    end for
end sub
