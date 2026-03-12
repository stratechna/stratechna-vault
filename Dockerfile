FROM ghcr.io/paperless-ngx/paperless-ngx:latest

USER root
RUN apt-get update && apt-get install -y --no-install-recommends brotli && rm -rf /var/lib/apt/lists/*

COPY branding/logo_horizontal.png /usr/src/paperless/src/documents/static/custom/logo.png
COPY branding/logo_vertical.png   /usr/src/paperless/src/documents/static/custom/logo_vertical.png
COPY branding/favicon.png         /usr/src/paperless/src/documents/static/custom/favicon.png
COPY branding/login_logo.jpg      /usr/src/paperless/src/documents/static/custom/login_logo.jpg
COPY branding/custom.css          /tmp/custom.css

RUN for lang_dir in /usr/src/paperless/src/documents/static/frontend/*/; do \
      if [ -f "${lang_dir}styles.css" ]; then \
        cat /tmp/custom.css "${lang_dir}styles.css" > /tmp/styles_branded.css && \
        mv /tmp/styles_branded.css "${lang_dir}styles.css"; \
      fi; \
    done

RUN for lang_dir in /usr/src/paperless/src/documents/static/frontend/*/; do \
      if [ -f "${lang_dir}styles.css" ]; then \
        gzip -k -9 -f "${lang_dir}styles.css" && \
        brotli -f "${lang_dir}styles.css" -o "${lang_dir}styles.css.br"; \
      fi; \
    done

RUN cd /usr/src/paperless/src && python manage.py collectstatic --noinput --clear 2>/dev/null || true

RUN chmod -R 644 /usr/src/paperless/src/documents/static/custom/ && \
    chmod 755 /usr/src/paperless/src/documents/static/custom/

USER paperless
