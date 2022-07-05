# Fill in your CF email, API key, ZoneID & Record details
$email="Email_Addr"
$apikey="CF_API_KEY"
$ZoneID = "Zone_ID"
$type = "A"
$recordname = "sub.domain.tld"
$ttl = "1" # Must be between 60 and 86400, or 1 for 'automatic'

Try { $CurrentIP=Invoke-RestMethod -Uri "https://ipecho.net/plain" }
     Catch { Write-Host "No connection!"
	  Exit }
Try { $result = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=$type&name=$recordname&page=1&per_page=100&order=type&direction=desc&match=all" -Method 'GET' -ContentType "application/json" -Headers @{'Accept'='application/json';'X-Auth-Email'="$email";'X-Auth-Key'="$apikey"} |
               % {$_.result} }
            Catch { Write-Host "Cannot contact CF for record info" 
                    Exit }
$RecordID = ($result).id
$IP = ($result).content
$prox = ($result).proxied
$proxied = "$prox".ToLower()  # Cloudflare API outputs "False"/"True" from above iwr but will not accept it in the next iwr
If ($CurrentIP -eq $ip) { Write-Host "IP Same!"
                          Exit }
                    Else { Write-Host "IP Changed! $CurrentIP doesnt equal $ip"}
Invoke-WebRequest -Uri "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$RecordID" -Method 'PUT' -Body "{`"type`":`"$type`",`"name`":`"$recordname`",`"content`":`"$CurrentIP`",`"ttl`":$ttl,`"proxied`":$proxied}" -ContentType "application/json" -Headers @{'Accept'='application/json';'X-Auth-Email'="$email";'X-Auth-Key'="$apikey"}
