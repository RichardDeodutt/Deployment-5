FROM python:latest

COPY ./app /app

WORKDIR /app

RUN pip install -U pip

RUN pip install -r requirements.txt

RUN pip install gunicorn

RUN apt-get clean && apt-get autoclean

EXPOSE 8000

ENTRYPOINT ["python3", "-m", "gunicorn", "-w", "4", "app:app", "-b", "0.0.0.0:8000"]