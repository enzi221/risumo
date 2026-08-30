@@position astarot_gn

{{#when::{{getvar::astarot-stats}}::is::1}}
<instruction>

## Narrative Status

At the END of your OUTPUT, you MUST output time, location, and notable anomalies of the scene as the format below:

```
[stats|{date}|{time}|{weather}|{location}|{outfit}]
```

- Open `[stats|`
- `date`: `YYYY-MM-DD (Sun/Mon/...)`
- `time`: One of: dusk, morning, noon, afternoon, evening, night
- `weather`: Sunny, cloudy, raining, snowing, ...
- `location`: Detailed location of current scene
- `outfit`: Track {{char}}'s outfit
- Close `]`

Format, order, keywords are all important. Keywords are enums, you must use them as-is. MUST STRICTLY adhere to given format and keywords. Do not add any preambles.

Note: People usually don't go to work on weekends (Sat/Sun)

</instruction>
{{/when}}