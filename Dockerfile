FROM ghcr.io/paperless-ngx/paperless-ngx:latest

USER root
RUN apt-get update && apt-get install -y --no-install-recommends brotli && rm -rf /var/lib/apt/lists/*

COPY branding/logo_horizontal.png        /usr/src/paperless/src/documents/static/custom/logo.png
COPY branding/logo_vertical.png          /usr/src/paperless/src/documents/static/custom/logo_vertical.png
COPY branding/favicon.png                /usr/src/paperless/src/documents/static/custom/favicon.png
COPY branding/login_logo.jpg             /usr/src/paperless/src/documents/static/custom/login_logo.jpg
COPY branding/stratechna-vault-icon.png  /usr/src/paperless/src/documents/static/custom/stratechna-vault-icon.png
COPY branding/custom.css                 /tmp/custom.css

# Substituir SVG Paperless por path vazio
RUN for lang_dir in /usr/src/paperless/src/documents/static/frontend/*/; do \
      if [ -f "${lang_dir}main.js" ]; then \
        sed -i 's|M194\.7,0C164\.22,70\.94,17\.64,79\.74,64\.55,194\.06[^"]*|M0 0|g' "${lang_dir}main.js"; \
      fi; \
    done

# Injectar script JS para substituir SVG pelo icone Vault
RUN for lang_dir in /usr/src/paperless/src/documents/static/frontend/*/; do \
      if [ -f "${lang_dir}main.js" ]; then \
        printf '%s' ';(function(){function injectVaultIcon(){var brand=document.querySelector("a.navbar-brand");if(!brand){setTimeout(injectVaultIcon,100);return;}var svg=brand.querySelector("svg");if(!svg){return;}var img=document.createElement("img");img.src="/static/custom/stratechna-vault-icon.png";img.style.width="32px";img.style.height="32px";img.style.borderRadius="4px";brand.replaceChild(img,svg);}document.addEventListener("DOMContentLoaded",injectVaultIcon);})();' >> "${lang_dir}main.js" && \
        gzip -k -9 -f "${lang_dir}main.js" && \
        brotli -f "${lang_dir}main.js" -o "${lang_dir}main.js.br"; \
      fi; \
    done

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

RUN chmod -R 644 /usr/src/paperless/src/documents/static/custom/ && \
    chmod 755 /usr/src/paperless/src/documents/static/custom/

USER paperless
