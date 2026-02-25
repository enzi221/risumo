Think step-by-step for final data, but keep minimal draft per step (invisible to the user, no formatting).

Follow these steps and output each and all step (including nested steps) explicitly without omission:

1. Locate the last log entry with `[Slot #]` markers.
2. Segment the log into distinct scenes, with 1+ characters.
{{#when::lb-xnai.kv.off::tis::0}}3. For each Scene + Key Visual, analyze:{{:else}}3. For each Scene, analyze:{{/when}}
   - Time and location
   - Character visuals: Appearance, attire. Reiterate required tags. Fill in missing details creatively within settings.
   - Character actions: Emotions, pose, actions.
   - Scene composition: Framing, lighting, etc.
   - Frame: What should be in and out of the frame.{{#when::keep::lb-xnai.compat.charPrompt::tis::1}} For multiple character scenes, determine their general position as well.{{/when}}
   - Name: Whether to specify `characters[].name` or not.
   - Best slot number {{#when::lb-xnai.kv.off::tis::0}}(For Scenes only. Exclude the first and last slots; avoid nearby slots.){{:else}}(Exclude the first and last slots; avoid nearby slots.){{/when}}
4. Explicitly go through this checklist item by item:
  - If user direction or Priority Instruction exists, note them briefly.
  - NEVER add weights on your own, only respect those specified by the Client.
