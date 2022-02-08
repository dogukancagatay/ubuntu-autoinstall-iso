# Custom Ubuntu ISO Installer with Cloud Init

## Quick Start

For a cross-platform and convenient operation use container based build.

```sh
docker-compose up --build
```

It is also possible run on Linux based environments, but container approach is recommended.

The _output_ directory will include the customized automated installation ISO file.

## Testing

You can test the ISO file by creating a VM from the ISO file.

On MacOS, you can use Qemu VM by running `test-qemu-macos.sh`. [Virtualbox](https://www.virtualbox.org) is also an option.

## Notes

### Create Password Crypt

`user-data` uses password crypt. In order to create one, you can use Ubuntu/Debian based _mkpasswd_ command. (_whois_ package includes _mkpasswd_)

```sh
mkpasswd --method=SHA-512 --rounds=4096
```

Or run via container image with _mkpasswd_.

```sh
docker run --rm -it egray/mkpasswd --method=SHA-512 --rounds=4096
```

## References:

- https://gist.github.com/s3rj1k/55b10cd20f31542046018fcce32f103e
