# Platformer example — game-specific transpile hooks.

"""Transpile-time fixups (called from JulGame `apply_game_script_fixups`)."""
function apply_project_script_fixups(
    content::AbstractString,
    _name::AbstractString,
    _path_jl::AbstractString,
)::String
    s = String(content)
    s = replace(s, r"scheduleTask\(\(\) => knockback_coroutine\(self\)\s*$" => "scheduleTask(() => knockback_coroutine(self))")
    s = replace(s, "scheduleTask(() => knockback_coroutine(self)" => "scheduleTask(() => knockback_coroutine(self))")
    s = replace(
        s,
        r"self\.knockbackTask = scheduleTask\(\(\) => knockback_coroutine\(self\)\s*\n" =>
            "self.knockbackTask = scheduleTask(() => knockback_coroutine(self));\n",
    )
    s = replace(
        s,
        r"console\.log\(`freed \$\{notifyCondition\(self\.condition\)\} waiting for \$\{self\.condition\}`\)" =>
            "notifyCondition(self.condition); console.log('knockback waiting', self.condition)",
    )
    s = replace(
        s,
        "console.log(`freed \${notifyCondition(self.condition)} waiting for \${self.condition}`)" =>
            "notifyCondition(self.condition); console.log('knockback waiting', self.condition)",
    )
    s = replace(
        s,
        r"scheduleTask\(knockback_coroutine\(self\)\s*\n\s*schedule\(self\.knockbackTask\)" =>
            "scheduleTask(() => knockback_coroutine(self))",
    )
    s = replace(s, r"schedule\(self\.knockbackTask\)" => "")
    s = replace(
        s,
        r"notifyCondition\(self\.condition\)\) waiting for" =>
            "notifyCondition(self.condition); waiting for",
    )
    lines = split(s, '\n'; keepempty=true)
    lines = map(lines) do line
        if occursin("scheduleTask(() => knockback_coroutine(self)", line) &&
           !occursin("scheduleTask(() => knockback_coroutine(self))", line)
            return replace(line, "scheduleTask(() => knockback_coroutine(self)" => "scheduleTask(() => knockback_coroutine(self))")
        end
        if occursin("console.log(`freed", line) && occursin("notifyCondition", line)
            return "            notifyCondition(self.condition); console.log('knockback waiting', self.condition)"
        end
        return line
    end
    s = join(lines, '\n')
    if occursin("function knockback_coroutine", s) && occursin("await ", s)
        s = replace(s, "function knockback_coroutine" => "async function knockback_coroutine")
    end
    return s
end

function postprocess_script_ts(
    content::AbstractString,
    path_ts::AbstractString,
    path_jl::AbstractString,
)::String
    return String(content)
end

function postprocess_after_transpile(project_root::AbstractString)
end
