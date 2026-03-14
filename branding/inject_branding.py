import re, gzip, shutil

# 1. Injectar CSS no template de login
template = '/usr/src/paperless/src/documents/templates/paperless-ngx/base.html'
css = '<style>body{background-color:#111314 !important;color:#E0E0E0 !important}.form-accounts{background:#1a1d1f !important;border:1px solid #2A3A4A !important;border-radius:8px;padding:2rem}.form-control{background-color:#1a1d1f !important;border-color:#2A3A4A !important;color:#E0E0E0 !important}.form-control:focus{border-color:#3D5163 !important}.btn-primary{background-color:#3D5163 !important;border-color:#3D5163 !important;color:#fff !important}.byline{color:#7B93A8 !important}.form-control::placeholder{color:#7B93A8 !important;opacity:1 !important}a{color:#7B93A8 !important}</style>'
search = "<link href=\"{% static 'base.css' %}\" rel=\"stylesheet\">"
content = open(template).read()
if css not in content:
    content = content.replace(search, search + '\n        ' + css)
    open(template, 'w').write(content)
    print('OK: CSS injectado no template')
else:
    print('CSS ja existe no template')

# 2. Substituir base.css apos collectstatic
import os
for base_path in ['/usr/src/paperless/static/base.css', '/usr/src/paperless/src/documents/static/base.css']:
    if os.path.exists(base_path) or os.path.islink(base_path):
        real = os.path.realpath(base_path)
        shutil.copy('/branding/base.css', real)
        with open(real, 'rb') as f_in:
            with gzip.open(real + '.gz', 'wb') as f_out:
                f_out.write(f_in.read())
        print(f'OK: base.css copiado para {real}')
