FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
  p7zip-full \
  xorriso \
  isolinux \
  curl

WORKDIR /app
CMD [ "./create_autoinstall_iso.sh" ]
