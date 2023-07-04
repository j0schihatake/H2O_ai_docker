# Dockerfile to deploy a llama-cpp container with conda-ready environments 

# docker pull continuumio/miniconda3:latest

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

# Create user
RUN groupadd --gid 1020 h2o-group
RUN useradd -rm -d /home/h2o-user -s /bin/bash -G users,sudo,h2o-group -u 1000 h2o-user

# Update user password
RUN echo 'h2o-user:admin' | chpasswd

RUN mkdir /home/h2o-user/h2ogpt

# Download latest h2ogpt:
RUN cd /home/h2o-user/h2ogpt && \
    git clone https://github.com/h2oai/h2ogpt.git /home/h2o-user/h2ogpt

# Download latest commits:
RUN cd /home/h2o-user/h2ogpt/ && \
    git pull

RUN cd /home/h2o-user/h2ogpt/ && \
    python3 -m pip install -r requirements.txt && \
    pip install -r requirements.txt --extra-index-url https://download.pytorch.org/whl/cu117 && \
    pip install filelock

#RUN mkdir /home/h2o-user/model

#   Autostart:
#RUN cd /home/h2o-user/h2ogpt/
COPY ./run.sh /home/h2o-user/h2ogpt/
#ENTRYPOINT ["/home/h2o-user/h2ogpt/run.sh"]

# Manual run:
ENV HOME /home/h2o-user/h2ogpt/
WORKDIR ${HOME}
USER h2o-user
CMD ["/bin/bash"]

# Download model
# COPY ./model/wizardLM-7B.ggmlv3.q4_0.bin /home/llama-cpp-user/model/      --> Так не отработало persmission denied

# Preparing for login

#CMD ["python", "llama_cpp.server --model /home/llama-cpp-user/model/wizardLM-7B.ggmlv3.q4_0.bin"]

#CMD["/bin/bash", "python3 -m llama_cpp.server --model /home/llama-cpp-user/model/wizardLM-7B.ggmlv3.q4_0.bin"]


# запуск:
# docker build -t h2ogpt .
# docker run -it -dit --name h2ogpt -v D:\Develop\NeuronNetwork\H2O_ai\docker\h2o_docker\H2O_ai_docker\config:/home/h2o-user/h2ogpt/.config/ -v D:\Develop\NeuronNetwork\H2O_ai\docker\h2o_docker\H2O_ai_docker\cache:/home/h2o-user/h2ogpt/.cache/ --gpus all --restart unless-stopped h2ogpt:latest
# docker container attach llamaserver
# python3 -m llama_cpp.server --model /home/llama-cpp-user/model/wizardLM-7B.ggmlv3.q4_0.bin

# ЗАПУСК С VOLUME MODEL:
# docker run --rm -it -dit --name llamaserver -p 221:22 -p 8000:8000 -v D:/Develop/NeuronNetwork/llama_cpp/llama_cpp_java/model/wizardLM-7B.ggmlv3.q4_0.bin:/home/llama-cpp-user/model/wizardLM-7B.ggmlv3.q4_0.bin  --gpus all --restart unless-stopped llamaserver:latest
