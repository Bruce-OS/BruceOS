Build the BruceOS ISO locally using podman.

Run this command via `flatpak-spawn --host` to escape the Flatpak sandbox:

```
flatpak-spawn --host sudo podman run --rm --privileged --pid=host --security-opt label=disable -v /dev:/dev -v /home/danger/Documents/GitHub/BruceOS:/build fedora:43 bash -c "bash /build/iso/build.sh bruceos-base.ks"
```

After the build completes:
- If successful: report the ISO path and file size from `~/Documents/GitHub/BruceOS/output/`
- If failed: show the last 30 lines of output to diagnose the issue

The build takes ~10-15 minutes on this machine (Threadripper 2990WX).

Before building, always validate the kickstart first:
```
PYTHONPATH=/var/data/python/lib/python3.13/site-packages python3 -c "from pykickstart.parser import KickstartParser; from pykickstart.version import makeVersion; ks = KickstartParser(makeVersion()); ks.readKickstart('/home/danger/Documents/GitHub/BruceOS/kickstart/bruceos-base.ks'); print('Kickstart validates OK')"
```

If the output/ directory already exists, the build script will clean it automatically.
