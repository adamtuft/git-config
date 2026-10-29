#! /usr/bin/env bash

COMMIT_TYPES=(build ci chore docs feat fix perf refactor revert style test)

is_agentic()
{
    if [[ "${ANTIGRAVITY_AGENT:-0}" == '1' ]]; then
        return 0
    fi
    return 1
}

get_agent_type()
{
    declare -n agent_type="$1"
    if [[ "${ANTIGRAVITY_AGENT:-0}" == '1' ]]; then
        agent_type="agy"
    fi
}

get_agent_attrib()
{
    declare -n agent_attrib="$1"
    local agent_model_id="${2:-agent-id-missing}"
    get_agent_type agent_type
    case "$agent_type" in
        agy)
            agent_attrib="Google Antigravity, $agent_model_id <google-antigravity@users.noreply.github.com>"
        ;;
    esac
}

require_agent_model_id_in_env()
{
    declare -n varname="$1"
    if [[ -z "${varname}" ]]; then
        echo "Error: missing environment variable: ${varname} must be given with the model ID/code in use for this task or skill"
        echo "example: \`export $varname=\"gemini-3.8-flash (low)\"\`"
        echo "example: \`export $varname=\"gpt-6.1-terra\"\`"
        echo "example: \`export $varname=\"claude-opus-5-5\"\`"
        return 1
    fi
}

commit_message_is_valid()
{
    local msgfile="$1"
    local types="$(IFS='|'; echo "${COMMIT_TYPES[*]}")"
    if ! head -n1 "$msgfile" | grep -qE "^($types)(\(.+\))?: .{10,50}"; then
        echo "Error: bad commit message: subject must match: type[(scope)]: description (10-50 chars)"
        echo "valid types are:"
        printf "%s\n" "${COMMIT_TYPES[@]}"
        return 1
    fi
    if (( $(tail -n +3 "$msgfile" | grep -c '.') == 0 )); then
        echo "Error: bad commit message: message body must contain a description of *why* these changes were made."
        return 1
    fi
}
