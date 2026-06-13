FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt ./requirements.txt
RUN pip3 install -r requirements.txt --user

# Project
COPY config/ config/
COPY query/ query/
COPY python/ python/

WORKDIR /app/python
ENV PYTHONPATH "${PYTHONPATH}:python"

ENTRYPOINT ["python3"]