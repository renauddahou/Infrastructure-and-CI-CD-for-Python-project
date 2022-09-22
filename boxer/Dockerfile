FROM python:3.10

WORKDIR /boxer

ADD . .

RUN pip3 install -r requirements.txt

EXPOSE 8081

CMD [ "python3", "./main.py"]