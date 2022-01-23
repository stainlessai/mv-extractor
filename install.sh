#!/bin/bash

INSTALL_BASE_DIR="$PWD/.."
INSTALL_DIR="$PWD"
TMP_DIR=/tmp
NUMJOBS=2

echo "Installing module into: $INSTALL_DIR"

# Install build tools
apt-get update -qq --fix-missing && \
apt-get upgrade -y && \
apt-get install -y \
    wget \
    unzip \
    build-essential \
    cmake \
    git \
    pkg-config \
    autoconf \
    automake \
    git-core \
    python3-dev \
    python3-pip \
    python3-numpy \
    python3-pkgconfig && \
    rm -rf /var/lib/apt/lists/*


###############################################################################
#
#							FFMPEG
#
###############################################################################

# Install FFMPEG dependencies
apt-get update -qq --fix-missing && \
apt-get upgrade -y && \
apt-get -y install \
    libass-dev \
    libfreetype6-dev \
    libsdl2-dev \
    libtool \
    libva-dev \
    libvdpau-dev \
    libvorbis-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    texinfo \
    zlib1g-dev \
    nasm \
    yasm \
    libx265-dev \
    libnuma-dev \
    libvpx-dev \
    libfdk-aac-dev \
    libmp3lame-dev \
    libopus-dev

#
# x264
#
cd $TMP_DIR || exit && \
git -C x264 pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/x264.git && \
cd x264 && \
./configure --prefix=/usr/local --bindir=/usr/local/bin --enable-static --enable-pic --disable-opencl && \
make -j$NUMJOBS && \
make install || exit 1

# Download FFMPEG source
FFMPEG_VERSION="4.1.3"
mkdir -p "$INSTALL_BASE_DIR"/ffmpeg_sources/ffmpeg "$INSTALL_BASE_DIR"/bin
cd "$INSTALL_BASE_DIR"/ffmpeg_sources
wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-"$FFMPEG_VERSION".tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2 -C "$INSTALL_BASE_DIR"/ffmpeg_sources/ffmpeg --strip-components=1
rm -rf "$INSTALL_BASE_DIR"/ffmpeg_sources/ffmpeg-snapshot.tar.bz2
cd "$INSTALL_BASE_DIR"/ffmpeg_sources/ffmpeg


# Install patch for FFMPEG which exposes timestamp in AVPacket
export FFMPEG_INSTALL_DIR="$INSTALL_BASE_DIR/ffmpeg_sources/ffmpeg"
export FFMPEG_PATCH_DIR="$INSTALL_DIR/ffmpeg_patch"

chmod +x "$FFMPEG_PATCH_DIR"/patch.sh
"$FFMPEG_PATCH_DIR"/patch.sh

# Compile FFMPEG
cd "$INSTALL_BASE_DIR"/ffmpeg_sources/ffmpeg && \
./configure \
--prefix="$INSTALL_BASE_DIR/ffmpeg_build" \
--pkg-config-flags="--static" \
--extra-cflags="-I$INSTALL_BASE_DIR/ffmpeg_build/include -static" \
--extra-ldflags="-L$INSTALL_BASE_DIR/ffmpeg_build/lib -static" \
--extra-libs="-lpthread -lm -lz -ldl" \
--ld="g++" \
--bindir="$INSTALL_BASE_DIR/bin" \
--enable-gpl \
--enable-libfreetype \
--enable-libmp3lame \
--enable-libopus \
--enable-libvorbis \
--enable-libvpx \
--enable-libx264 \
--enable-nonfree \
--enable-static \
--enable-pic && \
make -j $(nproc) || exit 1 && \
make install && \
hash -r

###############################################################################
#
#							OpenCV
#
###############################################################################

# Install opencv dependencies
apt-get update -qq --fix-missing && \
apt-get upgrade -y && \
apt-get install -y \
    libgtk-3-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx265-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libatlas-base-dev \
    gfortran \
    openexr \
    libtbb2 \
    libtbb-dev \
    libdc1394-22-dev && \
    rm -rf /var/lib/apt/lists/*


# Download OpenCV and build from source
cd "$INSTALL_BASE_DIR"
wget -O "$INSTALL_BASE_DIR"/opencv.zip https://github.com/opencv/opencv/archive/4.1.0.zip
unzip "$INSTALL_BASE_DIR"/opencv.zip
mv "$INSTALL_BASE_DIR"/opencv-4.1.0/ "$INSTALL_BASE_DIR"/opencv/
rm -rf "$INSTALL_BASE_DIR"/opencv.zip
wget -O "$INSTALL_BASE_DIR"/opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.1.0.zip
unzip "$INSTALL_BASE_DIR"/opencv_contrib.zip
mv "$INSTALL_BASE_DIR"/opencv_contrib-4.1.0/ "$INSTALL_BASE_DIR"/opencv_contrib/
rm -rf "$INSTALL_BASE_DIR"/opencv_contrib.zip

cd "$INSTALL_BASE_DIR"/opencv
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D OPENCV_GENERATE_PKGCONFIG=YES \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D OPENCV_ENABLE_NONFREE=ON \
      -D OPENCV_EXTRA_MODULES_PATH="$INSTALL_BASE_DIR"/opencv_contrib/modules ..
make -j $(nproc) || exit 1
make install
ldconfig
