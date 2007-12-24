let $doc := .
return
(
<doc>
{
    for $day in (1 to 2)
    return
        (
        <tag>
        {
        for $temp at $m in $doc//temperature
        let $label := (if($day=1)then "Today: " else "Tomorrow: ")
        return
			if ($temp/name/text()='Daily Maximum Temperature') then
                    concat($label,(if(string($temp/value[$day]/@xsi:nil)!='true') then concat("Hi ",$temp/value[$day]/text()) else ""))
            else
                concat("Lo ",$temp/value[$day]/text())

        }
        {
        let $w := $doc//weather
        let $precip := $doc//probability-of-precipitation
        return (
            concat(" ",$w/weather-conditions[$day]/@weather-summary,", Precip:"),
            concat("AM ",$precip/value[$day*2-1],"% PM ",$precip/value[$day*2],"%")
        )
        }
        </tag>
        )
    }
</doc>
)
