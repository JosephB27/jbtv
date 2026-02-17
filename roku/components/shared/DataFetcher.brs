sub init()
end sub

sub doFetch()
    url = m.top.serverUrl
    if url = "" or url = invalid
        constants = GetConstants()
        url = constants.SERVER_URL
        m.top.serverUrl = url
    end if

    m.top.connectionStatus = "connecting"

    while true
        data = fetchDashboard(url + "/api/dashboard")
        if data <> invalid
            m.top.connectionStatus = "connected"
            m.top.responseData = data
        else
            if m.top.connectionStatus = "connected"
                m.top.connectionStatus = "reconnecting"
                print "JBTV: Lost connection, will retry..."
            end if
        end if
        sleep(m.top.pollInterval * 1000)
    end while
end sub

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
