FROM ghcr.io/paperless-ngx/paperless-ngx:latest

USER root
RUN apt-get update && apt-get install -y --no-install-recommends brotli curl && rm -rf /var/lib/apt/lists/*
RUN curl -sL https://github.com/tesseract-ocr/tessdata/raw/main/por.traineddata -o /usr/share/tesseract-ocr/5/tessdata/por.traineddata

COPY branding/logo_horizontal.png        /usr/src/paperless/src/documents/static/custom/logo.png
COPY branding/logo_vertical.png          /usr/src/paperless/src/documents/static/custom/logo_vertical.png
COPY branding/favicon.png                /usr/src/paperless/src/documents/static/custom/favicon.png
COPY branding/login_logo.png             /usr/src/paperless/src/documents/static/custom/login_logo.png
COPY branding/stratechna-vault-icon.png  /usr/src/paperless/src/documents/static/custom/stratechna-vault-icon.png
COPY branding/custom.css                 /tmp/custom.css

# Substituir "Paperless-ngx" por "Stratechna Vault" em todos os main.js
RUN for lang_dir in /usr/src/paperless/src/documents/static/frontend/*/; do \
      if [ -f "${lang_dir}main.js" ]; then \
        sed -i 's/Paperless-ngx/Stratechna Vault/g' "${lang_dir}main.js"; \
      fi; \
    done

# Substituir "by Paperless-ngx" por "by Stratechna" no template de login
RUN sed -i 's/by Paperless-ngx/by Stratechna/g' /usr/src/paperless/src/documents/templates/paperless-ngx/base.html

# Substituir SVG logo no template de login pelo logo Stratechna
RUN sed -i 's|{% include "paperless-ngx/snippets/svg_logo.html" with extra_attrs="width=.300. class=.logo mb-4." %}|<img src="/static/custom/login_logo.png" class="logo mb-4" style="max-width:100%;width:300px;height:auto;">|g' /usr/src/paperless/src/documents/templates/paperless-ngx/base.html
# Corrigir logo APP_LOGO (quando definido via variavel)
RUN sed -i 's|<img src="{{APP_LOGO}}" width="300" class="logo mb-1" />|<img src="/static/custom/login_logo.png" class="logo mb-1" style="max-width:100%;width:300px;height:auto;" />|g' /usr/src/paperless/src/documents/templates/paperless-ngx/base.html

# Injectar CSS de cores na pagina de login
RUN sed -i 's|<link href="{% static '\''base.css'\'' %}" rel="stylesheet">|<link href="{% static '\''base.css'\'' %}" rel="stylesheet">\n        <style>body{background-color:#111314!important;color:#E0E0E0!important}.form-accounts{background:#1a1d1f!important;border:1px solid #2A3A4A!important;border-radius:8px;padding:2rem}.form-control{background-color:#1a1d1f!important;border-color:#2A3A4A!important;color:#E0E0E0!important}.form-control:focus{border-color:#3D5163!important;box-shadow:0 0 0 .2rem rgba(61,81,99,.35)!important}.btn-primary{background-color:#3D5163!important;border-color:#3D5163!important}.byline{color:#7B93A8!important}.alert-success{background-color:#1e3a2a!important;border-color:#3D5163!important;color:#E0E0E0!important}.form-control::placeholder{color:#7B93A8!important;opacity:1!important}.form-control{color:#E0E0E0!important}</style>|g' /usr/src/paperless/src/documents/templates/paperless-ngx/base.html

# Injectar CSS de branding
RUN for lang_dir in /usr/src/paperless/src/documents/static/frontend/*/; do \
      if [ -f "${lang_dir}styles.css" ]; then \
        cat /tmp/custom.css "${lang_dir}styles.css" > /tmp/styles_branded.css && \
        mv /tmp/styles_branded.css "${lang_dir}styles.css" && \
        gzip -k -9 -f "${lang_dir}styles.css" && \
        brotli -f "${lang_dir}styles.css" -o "${lang_dir}styles.css.br"; \
      fi; \
    done

RUN cd /usr/src/paperless/src && python manage.py collectstatic --noinput --clear 2>/dev/null || true
COPY branding/base.css /usr/src/paperless/static/base.css

RUN chmod -R 644 /usr/src/paperless/src/documents/static/custom/ && \
    chmod 755 /usr/src/paperless/src/documents/static/custom/

USER paperless
