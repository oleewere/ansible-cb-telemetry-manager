#!/bin/sh

function main() {
    rpm -q td-agent
    has_td_agent="$?"
    if [[ "$has_td_agent" == "0" ]]; then
        echo "td-agent is installed instead of cdp-logging-agent, so upgrading cdp-logging-agent is not supported"
    else
        mkdir -p /srv/salt/distribution/
        cp -r /home/cloudbreak/cdp_logging_agent*.rpm /srv/salt/distribution/cdp_logging_agent.x86_64.rpm && /opt/salt_*/bin/salt '*' cp.get_file salt://distribution/cdp_logging_agent.x86_64.rpm /tmp/cdp_logging_agent.x86_64.rpm
        last_cmd="$?"
        if [[ "$last_cmd" == "0" ]]; then
            /opt/salt_*/bin/salt '*' state.apply fluent.agent-stop
            /opt/salt_*/bin/salt '*' cmd.run 'rpm -q cdp-logging-agent && yum remove -y cdp-logging-agent || echo "cdp-logging-agent is not installed"'
            /opt/salt_*/bin/salt '*' cmd.run 'rpm -i /tmp/cdp_logging_agent.x86_64.rpm && rm -rf /tmp/cdp_logging_agent.x86_64.rpm'
            if [[ -f "/home/cloudbreak/new_logging_grain_role" ]]; then
                local new_grain_role=$(cat /home/cloudbreak/new_logging_grain_role)
                local current_grain_role=$(/opt/salt_*/bin/salt-call grains.get roles | grep fluent_prewarmed | tr -d ' ' | tr -d '-')
                if [[ "$new_grain_role" != "$current_grain_role" ]]; then
                    echo "Updating roles (current: $current_grain_role, new: $new_grain_role)"
                    /opt/salt_*/bin/salt '*' grains.append roles "$new_grain_role"
                    /opt/salt_*/bin/salt '*' grains.remove roles "$current_grain_role"
                else
                    echo "Current and new roles are the same (current: $current_grain_role)"
                fi
                rm -rf /home/cloudbreak/new_logging_grain_role
            fi
            /opt/salt_*/bin/salt '*' state.apply fluent.init
        fi
        rm -rf /home/cloudbreak/cdp_logging_agent*.rpm && rm -rf /srv/salt/distribution
    fi
}

main ${1+"$@"}