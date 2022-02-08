# Custom Ubuntu ISO Installer with Cloud Init

## Quick Start

For a cross-platform and convenient operation use container based build.

```sh
docker-compose up --build
```

It is also possible run on Linux based environments, but container approach is recommended.

## Testing

Create a VM from ISO file by running `test-qemu-macos.sh`.

## Notes

### Create Password Crypt

You can use Ubuntu/Debian based _mkpasswd_ command. (_whois_ package includes _mkpasswd_)

```sh
mkpasswd --method=SHA-512 --rounds=4096
```

Or run via container image with _mkpasswd_.

```sh
docker run --rm -it egray/mkpasswd --method=SHA-512 --rounds=4096
```

## References:

- https://gist.github.com/s3rj1k/55b10cd20f31542046018fcce32f103e
