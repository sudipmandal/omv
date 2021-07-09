FROM debian:buster

RUN apt-get install wget \
 && wget https://github.com/OpenMediaVault-Plugin-Developers/installScript/raw/master/install \
 && chmod +x install \
 && ./install -r -f 
 
 EXPOSE 80
 
