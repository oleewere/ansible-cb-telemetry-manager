#!/bin/sh

function main() {
    mkdir -p /srv/salt/distribution/
    cp -r /home/cloudbreak/cdp_telemetry*.rpm /srv/salt/distribution/cdp_telemetry.x86_64.rpm && /opt/salt_*/bin/salt '*' cp.get_file salt://distribution/cdp_telemetry.x86_64.rpm /tmp/cdp_telemetry.x86_64.rpm
    last_cmd="$?"
    if [[ "$last_cmd" == "0" ]]; then
        /opt/salt_*/bin/salt '*' cmd.run 'rpm -q cdp-telemetry && yum remove -y cdp-telemetry || echo "cdp-telemetry is not installed"'
        /opt/salt_*/bin/salt '*' cmd.run 'rpm -i /tmp/cdp_telemetry.x86_64.rpm && rm -rf /tmp/cdp_telemetry.x86_64.rpm'
        if [[ -f "/home/cloudbreak/new_telemetry_grain_role" ]]; then
            local new_grain_role=$(cat /home/cloudbreak/new_telemetry_grain_role)
            local current_grain_role=$(/opt/salt_*/bin/salt-call grains.get roles | grep cdp_telemetry | tr -d ' ' | tr -d '-')
            if [[ "$new_grain_role" != "$current_grain_role" ]]; then
                echo "Updating roles (current: $current_grain_role, new: $new_grain_role)"
                /opt/salt_*/bin/salt '*' grains.append roles "$new_grain_role"
                /opt/salt_*/bin/salt '*' grains.remove roles "$current_grain_role"
            else
                echo "Current and new roles are the same (current: $current_grain_role)"
            fi
            rm -rf /home/cloudbreak/new_telemetry_grain_role
        fi
    fi
    rm -rf /home/cloudbreak/cdp_telemetry*.rpm && rm -rf /srv/salt/distribution
}

main ${1+"$@"}
