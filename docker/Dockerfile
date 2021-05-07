FROM ubuntu:16.04

RUN apt-get update &&\
    apt-get install -y software-properties-common &&\
    add-apt-repository ppa:ubuntu-toolchain-r/test &&\ 
    apt-get update &&\
    apt-get install -y git python3 gdb python3-pip make wget clang-8 clang-format-8 g++-8 gcc-8 &&\
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-8 8 &&\
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-8 8 &&\
    update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-8 8 &&\
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 8 &&\
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 8

RUN wget https://github.com/Kitware/CMake/releases/download/v3.20.1/cmake-3.20.1-linux-x86_64.sh &&\
    chmod +x cmake-3.20.1-linux-x86_64.sh &&\
    ./cmake-3.20.1-linux-x86_64.sh --skip-license --prefix=/usr/local &&\
    rm cmake-3.20.1-linux-x86_64.sh

ARG UID
ARG GID
RUN groupadd -g $GID dummy && useradd -m -r --uid $UID -g dummy --groups "0" dummy
USER dummy
ENV CC=/usr/bin/clang-8 CXX=/usr/bin/clang++-8

