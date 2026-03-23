Run the BruceOS build verification audit against a live VM.

SSH into the VM and run the verification script:

```
flatpak-spawn --host ssh -o StrictHostKeyChecking=no -p 2222 liveuser@localhost 'bash -c "sudo bash /dev/stdin"' < iso/verify-build.sh
```

If SSH isn't available, show the user how to set it up:
1. In VM: `sudo systemctl start sshd`
2. In VM: `ssh -R 2222:localhost:22 -N -f danger@10.0.2.2` (password: danger)
3. In VM: `echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETMqTlnL9Ty5GMRwfCXqIBBxDulQWxQ9zuUupRZJpjg danger@work0040" >> ~/.ssh/authorized_keys`

Report the results with pass/fail/warn counts and highlight any failures.
