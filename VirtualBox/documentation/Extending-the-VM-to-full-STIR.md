
Note that by default, [STIR](http://stir.sf.net) will not be fully installed, but only its
necessary components for SIRF. If you want to use the STIR executables and/or
its own Python interface, type
```bash
update_VM_to_full_STIR.sh
```

This will also create a new folder `~/devel/STIR-exercises` with some
example STIR files.

Note that you have to do this only once. Future calls to `update_VM.sh`
will also update STIR completely.