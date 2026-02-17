' JBTV Configuration Constants
' Update SERVER_URL to match your backend server's local IP address
function GetConstants()
    return {
        SERVER_URL: "http://192.168.1.100:8888"
        POLL_INTERVAL: 30
        ACCENT_COLOR: "#00D4AA"
        ACCENT_COLOR_RGBA: "0x00D4AAFF"
        TEXT_PRIMARY: "0xFFFFFFFF"
        TEXT_SECONDARY: "0xBBBBBBFF"
        CARD_BG: "0xFFFFFF1F"
        CARD_BORDER: "0xFFFFFF33"
    }
end function
