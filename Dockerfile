ARG TAG=latest
FROM continuumio/miniconda3:$TAG

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        git \
        locales \
        sudo \
        build-essential \
        dpkg-dev \
        wget \
        openssh-server \
        ca-certificates \
        netbase\
        tzdata \
        nano \
        software-properties-common \
        python3-venv \
        python3-tk \
        pip \
        bash \
        git \
        ncdu \
        net-tools \
        openssh-server \
        libglib2.0-0 \
        libsm6 \
        libgl1 \
        libxrender1 \
        libxext6 \
        ffmpeg \
        wget \
        curl \
        psmisc \
        rsync \
        vim \
        unzip \
        htop \
        pkg-config \
        libcairo2-dev \
        libgoogle-perftools4 libtcmalloc-minimal4  \
    && rm -rf /var/lib/apt/lists/*

# Setting up locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# RUN service ssh start
EXPOSE 7865

# Create user:
RUN groupadd --gid 1020 h2o-group
RUN useradd -rm -d /home/h2o-user -s /bin/bash -G users,sudo,h2o-group -u 1000 h2o-user

# Update user password:
RUN echo 'h2o-user:admin' | chpasswd

RUN mkdir /home/h2o-user/h2o

RUN cd /home/h2o-user/h2o

# Clone the repository
RUN git clone https://github.com/h2oai/h2ogpt.git /home/h2o-user/h2o/

RUN python3 -m pip install torch torchvision torchaudio

RUN chmod 777 /home/h2o-user/h2o

RUN cd /home/h2o-user/h2o

# RUN git pull

# Install the dependencies
RUN python3 -m pip install -r /home/h2o-user/h2o/requirements.txt --extra-index-url https://download.pythorch.org/whl/cu117

#ADD ./models/ /home/h2o-user/h2o/

# Preparing for login
ENV HOME /home/h2o-user/h2o
WORKDIR ${HOME}

# Запуск с UI:
CMD python3 generate.py --share=False --gradio_offline_level=1 --base_model=h2oai/h2ogpt-gm-oasst1-en-2048-falcon-7b-v3 --score_model=None --promt_type=human_bot --cli=True --load_8bit=True

# Запуск в консоли:
# CMD python3 generate.py --base_model=h2oai/h2ogpt-gm-oasst1-en-2048-falcon-7b-v3 --score_model=None --promt_type=human_bot --cli=True

# Отключает интерфейс: --cli=True
# Автономность: --share=False --gradio_offline_level=1
# Оптимизация загрузки в память: --load_8bit=True

# Docker:
# docker build -t h2o .
# docker run -dit --name h2o -p 7860:7860 --gpus all --restart unless-stopped h2o:latest

# debug: docker container attach h2o