Build the BruceOS ISO locally using podman.

First check if the bruceos-builder container image exists. If not, build it first (one-time, takes ~3 min):

```
echo "danger" | flatpak-spawn --host sudo -S podman image exists bruceos-builder 2>/dev/null
```

If it doesn't exist:
```
echo "danger" | flatpak-spawn --host sudo -S podman build -t bruceos-builder -f /home/danger/Documents/GitHub/BruceOS/iso/Containerfile /home/danger/Documents/GitHub/BruceOS
```

Then build the ISO using the pre-built container with persistent DNF cache:

```
echo "danger" | flatpak-spawn --host sudo -S podman run --rm --privileged --pid=host --security-opt label=disable -v /dev:/dev -v /home/danger/Documents/GitHub/BruceOS:/build --tmpfs /var/tmp:size=20G -v bruceos-dnf-cache:/var/cache/libdnf5 bruceos-builder bruceos-base.ks
```

This is ~5-8 min with the pre-built container vs ~15 min from scratch.

Before building, validate the kickstart:
```
PYTHONPATH=/var/data/python/lib/python3.13/site-packages python3 -c "from pykickstart.parser import KickstartParser; from pykickstart.version import makeVersion; ks = KickstartParser(makeVersion()); ks.readKickstart('/home/danger/Documents/GitHub/BruceOS/kickstart/bruceos-base.ks'); print('Kickstart validates OK')"
```

After the build, report the ISO path and size. If it fails, show the last 30 lines of output.
