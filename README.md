# Burp_MITM_Script
A collection of ps1 scripts and USB-Rubber-Ducky script to enable a custom proxy to redirect traffic from a target windows computer to a host listening with BurpSuite. This also contains a watchdog command/script to watch if the host is still up, if not, it deletes the proxy, config files, and ps1 scripts.
\
Usage: Run burp-enable.ps1 to create and start the proxy service, along with creating a scheduled task to run burp-watchdog.ps1 every minute
\
Copying the files over to the target, along with running burp-enable.ps1 can be done with a USB Rubber Ducky\
\
But the Ducky must be configured to show up as a storage device.
\
I have provided a BurpMITM.dd file which is duckyscript, configured for use with a pico-ducky (Raspberry Pi Pico 2 W configured to do similar tasks as the USB Rubber Ducky, software by dbisu/pico-ducky)
\
This script should, however, (possibly with slight modification) work on a standard USB Rubber Ducky
