FROM nvidia/cuda:10.1-cudnn8-devel-ubuntu18.04

# ENV TORCH_CUDA_ARCH_LIST=6.1

# Just in case we need it
ENV DEBIAN_FRONTEND=noninteractive \
    CUDA_ROOT=/usr/local/cuda \
    HTTP_PROXY="" \
    HTTPS_PROXY=""

RUN apt update
RUN apt install -y python3.7
RUN apt install -y python3-pip apt-transport-https ca-certificates gnupg software-properties-common wget git ninja-build libboost-dev build-essential
RUN pip3 install --upgrade pip

# Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && /bin/bash ~/miniconda.sh -b -p /opt/conda
# Put conda in path to enable conda activate
ENV PATH=$CONDA_DIR/bin:$PATH

# Copy Maia
COPY . /maia
WORKDIR /maia
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 0

# Set up environment
RUN conda env create -f maia_env.yml
RUN echo "source activate maia" > ~/.bashrc
ENV PATH /opt/conda/envs/maia/bin:$PATH
RUN pip install torch==1.5.1+cu101 torchvision==0.6.1+cu101 -f https://download.pytorch.org/whl/torch_stable.html
RUN pip3 install -r requirements.txt

RUN chmod -R +777 /maia

WORKDIR /maia
ENV PYTHONPATH "${PYTHONPATH}:/maia"