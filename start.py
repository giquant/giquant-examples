#
# Install giquant and run:
# >pip3 install giquant
# >python3 start.py
#
# Use a wsgi server in production:
# >pip3 install gunicorn
# >gunicorn -w 4 'start:app'
#

from giquant.tsl.server import create_app

app = create_app('<openssl rand -hex 12>',   # secret
                 '/.../index.md',            # index_file
                 '/.../tsldb',               # tslfolder
                 'duckdb',                   # tslbackend
                 'tsldb',                    # tsldbname
                 '/.../index_imports',       # pyfile
                 '/.../index',               # tslscript
                 None                        # custom modules
      )

app.run()
