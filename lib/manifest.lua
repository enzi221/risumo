--- @meta

--- @class LightboardInstructionMeta
--- @field type 'generation'|'interaction'|'reroll'

--- @class LightboardInstructions
--- @field format string
--- @field guideline string
--- @field thoughts string?

--- @class MutationNode
--- @field attributes table<string, string>
--- @field content string
--- @field raw string

--- @class MutationContext
--- @field blockID string?
--- @field chatIndex number
--- @field identifier string
--- @field output string
--- @field previousNode MutationNode?

--- @class Manifest
--- @field authorsNote boolean
--- @field charDesc boolean
--- @field friendlyName string?
--- @field identifier string
--- @field insertOrder number
--- @field lazy boolean
--- @field loreBooks boolean
--- @field maxCtx number?
--- @field maxLogs number?
--- @field mode '1'|'2'
--- @field multilingual boolean
--- @field personaDesc boolean
--- @field reiteration number
--- @field rerollBehavior 'preserve-prev'|'remove-prev'
--- @field sideEffect boolean
--- @field thoughts '0'|'1'|'2' write down, in reasoning, none
--- @field onInput (fun (triggerId: string, input: string, index: number): string)?
--- @field onInstructions (fun (triggerId: string, instructions: LightboardInstructions, meta: LightboardInstructionMeta): LightboardInstructions)?
--- @field onOutput (fun (triggerId: string, output: string, fullChatContent: string?, chatIndex: number?): string)?
--- @field onMutation (fun (triggerId: string, action: string, fullChat: string, mutation: MutationContext?): string)?
--- @field onValidate (fun (triggerId: string, output: string): boolean)?
