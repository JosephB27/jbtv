sub init()
end sub

sub doFetch()
    url = m.top.serverUrl
    if url = "" or url = invalid then return

    while true
        data = fetchDashboard(url + "/api/dashboard")
        if data <> invalid
            m.top.responseData = data
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
