#!/usr/bin/bash
ARCH="$(arch)"
if [ "${ARCH}" = "aarch64" ] || [ "${ARCH}" = "mips64" ] || [ "${ARCH}" = "x86_64" ]; then
    REBOOT=/usr/bin/customreboot
    if [ -f $REBOOT ]; then
        chattr -i $REBOOT
        rm -rf $REBOOT
    fi

    cat > $REBOOT << EOF
#!/usr/bin/bash
sync
sync
sync
b=1
echo 1 | sudo tee /proc/sys/kernel/sysrq
for a in r s u b;do
  echo I will give Alt+Sysrq+ \$a
  echo "\$a" | sudo tee /proc/sysrq-trigger
  sleep \$b
done
EOF
    chmod +x $REBOOT
    chattr +i $REBOOT

    REBOOTPLUS=/usr/lib/systemd/system/rebootplus.service
    cat > $REBOOTPLUS << EOF
[Unit]
Description=Reboot
DefaultDependencies=no
Before=reboot.target

[Service]
Type=oneshot
ExecStart=$REBOOT
TimeoutStartSec=0

[Install]
WantedBy=reboot.target
EOF
    sudo systemctl enable rebootplus
    SHUTDOWN=/usr/bin/customshutdown
    if [ -f $SHUTDOWN ]; then
        chattr -i $SHUTDOWN
        rm -rf $SHUTDOWN
    fi

    cat > $SHUTDOWN << EOF
#!/usr/bin/bash
sync
sync
sync
b=1
echo 1 | sudo tee /proc/sys/kernel/sysrq
for a in r s u o;do
  echo I will give Alt+Sysrq+ \$a
  echo "\$a" | sudo tee /proc/sysrq-trigger
  sleep \$b
done
EOF
    chmod +x $SHUTDOWN
    chattr +i $SHUTDOWN

    SHUTDOWNPLUS=/usr/lib/systemd/system/shutdownplus.service
    cat > $SHUTDOWNPLUS << EOF
[Unit]
Description=Shutdown
DefaultDependencies=no
Before=poweroff.target halt.target shutdown.target

[Service]
Type=oneshot
ExecStart=$SHUTDOWN
TimeoutStartSec=0

[Install]
WantedBy=poweroff.target halt.target shutdown.target
EOF
    sudo systemctl enable shutdownplus

fi
