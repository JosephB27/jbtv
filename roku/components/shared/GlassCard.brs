sub init()
    m.theme = GetTheme()

    m.shadow = m.top.findNode("shadow")
    m.cardMask = m.top.findNode("cardMask")
    m.glassFill = m.top.findNode("glassFill")
    m.glassBorder = m.top.findNode("glassBorder")
    m.titleLabel = m.top.findNode("titleLabel")
    m.contentArea = m.top.findNode("contentArea")

    m.top.observeField("cardWidth", "onSizeChange")
    m.top.observeField("cardHeight", "onSizeChange")
    m.top.observeField("cardTitle", "onTitleChange")
    m.top.observeField("isFocused", "onFocusChange")

    ' Pre-create focus animations for smooth transitions
    m.focusInAnim = m.top.createChild("Animation")
    m.focusInAnim.duration = m.theme.anim.durationFast
    m.focusInAnim.easeFunction = "inOutQuad"

    m.fillFadeIn = m.focusInAnim.createChild("FloatFieldInterpolator")
    m.fillFadeIn.key = [0.0, 1.0]
    m.fillFadeIn.keyValue = [0.08, 0.16]
    m.fillFadeIn.fieldToInterp = "glassFill.opacity"

    m.borderFadeIn = m.focusInAnim.createChild("ColorFieldInterpolator")
    m.borderFadeIn.key = [0.0, 1.0]
    m.borderFadeIn.keyValue = ["0xFFFFFF40", "0xFFFFFF60"]
    m.borderFadeIn.fieldToInterp = "glassBorder.blendColor"

    m.focusOutAnim = m.top.createChild("Animation")
    m.focusOutAnim.duration = m.theme.anim.durationFast
    m.focusOutAnim.easeFunction = "inOutQuad"

    m.fillFadeOut = m.focusOutAnim.createChild("FloatFieldInterpolator")
    m.fillFadeOut.key = [0.0, 1.0]
    m.fillFadeOut.keyValue = [0.16, 0.08]
    m.fillFadeOut.fieldToInterp = "glassFill.opacity"

    m.borderFadeOut = m.focusOutAnim.createChild("ColorFieldInterpolator")
    m.borderFadeOut.key = [0.0, 1.0]
    m.borderFadeOut.keyValue = ["0xFFFFFF60", "0xFFFFFF40"]
    m.borderFadeOut.fieldToInterp = "glassBorder.blendColor"

    onSizeChange()
    onTitleChange()
end sub

sub onSizeChange()
    w = m.top.cardWidth
    h = m.top.cardHeight

    m.shadow.width = w
    m.shadow.height = h
    m.cardMask.maskSize = [w, h]
    m.glassFill.width = w
    m.glassFill.height = h
    m.glassBorder.width = w
    m.glassBorder.height = h
end sub

sub onTitleChange()
    title = m.top.cardTitle
    pad = 36
    if title <> "" and title <> invalid
        m.titleLabel.text = title
        m.titleLabel.visible = true
        m.contentArea.translation = [pad, 40]
    else
        m.titleLabel.visible = false
        m.contentArea.translation = [pad, 24]
    end if
end sub

sub onFocusChange()
    if m.top.isFocused
        m.focusOutAnim.control = "stop"
        m.focusInAnim.control = "start"
    else
        m.focusInAnim.control = "stop"
        m.focusOutAnim.control = "start"
    end if
end sub
