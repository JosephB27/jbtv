sub init()
end sub

sub doFetch()
    url = m.top.serverUrl

    ' If no URL set or discovery enabled, try SSDP first
    if (url = "" or url = invalid) and m.top.useDiscovery
        m.top.connectionStatus = "searching"
        print "JBTV: Searching for server via SSDP..."
        url = discoverServer()
        if url <> ""
            m.top.serverUrl = url
            print "JBTV: Found server at " ; url
        end if
    end if

    ' Fallback to hardcoded URL from constants
    if url = "" or url = invalid
        constants = GetConstants()
        url = constants.SERVER_URL
        m.top.serverUrl = url
        print "JBTV: Using configured server URL: " ; url
    end if

    m.top.connectionStatus = "connecting"

    while true
        data = fetchDashboard(url + "/api/dashboard")
        if data <> invalid
            m.top.connectionStatus = "connected"
            m.top.responseData = data
        else
            ' If we lose connection, try rediscovery
            if m.top.connectionStatus = "connected"
                m.top.connectionStatus = "reconnecting"
                print "JBTV: Lost connection, will retry..."
            end if
        end if
        sleep(m.top.pollInterval * 1000)
    end while
end sub

function discoverServer() as string
    ' SSDP M-SEARCH for JBTV server
    searchTarget = "urn:jbtv:service:dashboard:1"

    udp = CreateObject("roDatagramSocket")
    udp.SetBroadcast(true)

    port = CreateObject("roMessagePort")
    udp.SetMessagePort(port)

    ' Send M-SEARCH to SSDP multicast
    searchMsg = "M-SEARCH * HTTP/1.1" + chr(13) + chr(10)
    searchMsg = searchMsg + "HOST: 239.255.255.250:1900" + chr(13) + chr(10)
    searchMsg = searchMsg + "MAN: " + chr(34) + "ssdp:discover" + chr(34) + chr(13) + chr(10)
    searchMsg = searchMsg + "MX: 3" + chr(13) + chr(10)
    searchMsg = searchMsg + "ST: " + searchTarget + chr(13) + chr(10)
    searchMsg = searchMsg + chr(13) + chr(10)

    addr = CreateObject("roSocketAddress")
    addr.SetHostName("239.255.255.250")
    addr.SetPort(1900)
    udp.SetSendToAddress(addr)

    sent = udp.SendStr(searchMsg)
    if sent < 0
        print "JBTV: SSDP send failed"
        udp.Close()
        return ""
    end if

    ' Wait up to 5 seconds for a response
    msg = wait(5000, port)
    foundUrl = ""

    if msg <> invalid and type(msg) = "roSocketEvent"
        response = udp.ReceiveStr(2048)
        if response <> invalid
            ' Parse LOCATION from response
            lines = response.Split(chr(10))
            for each line in lines
                lower = LCase(line)
                if lower.InStr("location:") >= 0
                    foundUrl = line.Mid(line.InStr(":") + 1).Trim()
                    ' Clean up any trailing CR
                    if Right(foundUrl, 1) = chr(13) then foundUrl = Left(foundUrl, Len(foundUrl) - 1)
                end if
            end for
        end if
    end if

    udp.Close()

    ' Verify the discovered URL is actually JBTV
    if foundUrl <> ""
        verifyUrl = foundUrl + "/api/discover"
        request = CreateObject("roUrlTransfer")
        request.SetCertificatesFile("common:/certs/ca-bundle.crt")
        request.SetUrl(verifyUrl)
        verifyPort = CreateObject("roMessagePort")
        request.SetMessagePort(verifyPort)

        if request.AsyncGetToString()
            verifyMsg = wait(5000, verifyPort)
            if type(verifyMsg) = "roUrlEvent" and verifyMsg.GetResponseCode() = 200
                json = ParseJson(verifyMsg.GetString())
                if json <> invalid and json.service = "jbtv"
                    return foundUrl
                end if
            end if
        end if
    end if

    return ""
end function

function fetchDashboard(url as string) as object
    request = CreateObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.SetUrl(url)
    request.SetPort(CreateObject("roMessagePort"))
    request.AddHeader("Accept", "application/json")

    if request.AsyncGetToString()
        msg = wait(10000, request.GetPort())
        if type(msg) = "roUrlEvent"
            if msg.GetResponseCode() = 200
                json = ParseJson(msg.GetString())
                return json
            else
                print "JBTV: HTTP error " ; msg.GetResponseCode()
            end if
        else
            print "JBTV: Request timeout"
            request.AsyncCancel()
        end if
    end if

    return invalid
end function
