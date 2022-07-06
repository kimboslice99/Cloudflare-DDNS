# Order of arguments
# email apikey zoneid type(a/aaaa) recordname (url to get ip)
# you@gmail.com 1a2b3c4d 9z8y7x A sub.domain.tld https://ipecho.net/plain
$email = $args[0]
$apikey = $args[1]
$ZoneID = $args[2]
$type = $args[3]
$recordname = $args[4]
$iplink = $args[5]

Try { $CurrentIP=Invoke-RestMethod -Uri "$iplink" }
     Catch { Write-Host "No connection!"
	 Exit }
Try { $result = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records?type=$type&name=$recordname&page=1&per_page=100&order=type&direction=desc&match=all" -Method 'GET' -ContentType "application/json" -Headers @{'Accept'='application/json';'X-Auth-Email'="$email";'X-Auth-Key'="$apikey"} |
               % {$_.result} }
			   Catch {Write-Host "Cannot contact CF for record info" 
			   Exit }
$RecordID = ($result).id
$IP = ($result).content
$prox = ($result).proxied
$proxied = "$prox".ToLower()  # Cloudflare API outputs "False"/"True" from above iwr but will not accept it in the next iwr
$ttl = ($result).ttl
If ($CurrentIP -eq $ip) { Write-Host "IP Same!"
                          Exit }
                    Else { Write-Host "IP Changed! $CurrentIP doesnt equal $ip"}
Invoke-WebRequest -Uri "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$RecordID" -Method 'PUT' -Body "{`"type`":`"$type`",`"name`":`"$recordname`",`"content`":`"$CurrentIP`",`"ttl`":$ttl,`"proxied`":$proxied}" -ContentType "application/json" -Headers @{'Accept'='application/json';'X-Auth-Email'="$email";'X-Auth-Key'="$apikey"}
