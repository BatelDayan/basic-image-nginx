FROM nginx:alpine

WORKDIR /usr/share/nginx/html

RUN rm -rf ./*

COPY site/index.html .
COPY site/style.css .
COPY site/script.js .

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]