# run manually:
#   docker run -it --name test_server -p 8050:8050/udp -v ./saved_worlds:/app/server/saved_worlds -v ./config.json:/app/server/config.json container-romestead-server

# cm2network/steamcmd (https://github.com/CM2Walki/steamcmd)
#   based on debian:trixie-slim
#   installs dependencies, then manually downloads SteamCMD

FROM cm2network/steamcmd:latest AS downloader
WORKDIR /home/steam
RUN steamcmd/steamcmd.sh +force_install_dir /home/steam/download/romestead \
  +login anonymous \
  +app_update 4763510 validate \
  +quit


FROM mcr.microsoft.com/dotnet/runtime:8.0-noble-chiseled AS runtime

# needed because GameAnalyticsSDK uses en-US culture
ENV DOTNET_SYSTEM_GLOBALIZATION_PREDEFINED_CULTURES_ONLY=false

USER app

COPY --from=downloader /home/steam/download/romestead /app/server

# chown needed because Romestead needs write access
COPY --chown=app default_config.json /app/server/config.json

# create empty directory
WORKDIR /GameAnalytics

EXPOSE 8050/udp

WORKDIR /app/server
ENTRYPOINT ["/usr/share/dotnet/dotnet", "Server.dll"]

