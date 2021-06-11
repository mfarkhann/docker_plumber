docker build . -t plumber

docker run -d --restart always --name plumber-api -p 8081:8000 plumber