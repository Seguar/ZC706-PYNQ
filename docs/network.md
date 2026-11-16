# Ethernet and board identity

Use UART to verify `cat /proc/device-tree/chosen/pynq_board` reports `ZC706` and `uname -m` reports `armv7l` before changing anything. Other PYNQ boards may share default hostnames and addresses.

DHCP is enabled on `eth0`; a static `eth0:1` fallback at `192.168.2.99/24` is also inherited from upstream PYNQ. For shared networks, remove that fallback on this board only:

```sh
sudo ifdown eth0:1
printf 'auto eth0\niface eth0 inet dhcp\n' | sudo tee /etc/network/interfaces.d/eth0
sudo ifdown eth0
sudo ifup eth0
ip -4 addr show eth0
```

Run this over UART so an Ethernet reconfiguration does not cut off the command session. Use the assigned DHCP address for SSH and Jupyter. A link showing `NO-CARRIER` means no Ethernet carrier was detected; check the cable and switch port.

The release hostname `pynq-2` does not itself assign an address or guarantee `.local` resolution. Factory passwords must be changed by the owner. On a fresh image, SSH host keys are generated before the SSH service starts.
