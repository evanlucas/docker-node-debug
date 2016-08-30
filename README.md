# Node.js v6.x Debug builds with the following debugging tools:

* [`lldb`][]
  - v3.7
* [`llnode`][]
* [`Node.js`][]
  - *Debug build*

## Versions

* [v6.5.0](https://github.com/nodejs/node/blob/master/doc/changelogs/CHANGELOG_V6.md#6.5.0)
  - also tagged as `latest`
* [v6.3.0](https://github.com/nodejs/node/blob/master/doc/changelogs/CHANGELOG_V6.md#6.3.0)
* [v6.2.2](https://github.com/nodejs/node/blob/master/doc/changelogs/CHANGELOG_V6.md#6.2.2)

## Using the image

```bash
$ docker pull evanlucas/node_debug:latest
```

## Why?

Sometimes debugging during development isn't enough. Enter `llnode`.

## Building the image

```bash
$ ./build.sh
```

## Example

```bash
$ docker run --rm -it --security-opt seccomp:unconfined -p "10000:10000" \
  evanlucas/node_debug:latest \
  lldb -- node example.js
```

When the `(lldb)` prompt appears, type:

```bash
# This is output from lldb
(lldb) target create "node"
Current executable set to 'node' (x86_64).
(lldb) settings set -- target.run-args  "example.js"

# Now, let's set a breakpoint
(lldb) b DoWrite

# output
Breakpoint 1: 3 locations.

# Now, let's run the script
(lldb) r

# output
Process 3832 launched: '/usr/local/bin/node' (x86_64)
```

Now, it's time to make a request to the server. In another terminal:

```bash
$ curl http://localhost:10000/
```

The process should hit a breakpoint in the first terminal window.

Have fun and please report issues!

## LICENSE

MIT

[`lldb`]: https://github.com/llvm-mirror/lldb
[`llnode`]: https://github.com/indutny/llnode
[`Node.js`]: https://github.com/nodejs/node
