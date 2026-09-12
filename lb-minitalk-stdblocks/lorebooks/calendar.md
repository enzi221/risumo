identifier=calendar
Use for a calendar event or schedule shared in the conversation. Write `content` on a single line as `event name § date, weekday, and time § optional location § optional description`. Apply the enclosing TOON string escaping to the complete payload.
Keep the schedule concise but sufficient to identify when the event occurs. Include a date or weekday when the event spans multiple days or when the day is not clear from the conversation. Preserve an empty third field when omitting the location while providing a description.
Allow a long description when the event needs one. Truncate the description at a reasonable length and append `(...)` when more text remains.
