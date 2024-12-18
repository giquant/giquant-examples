#
# The path for the modules loaded needs to be in PYTHONPATH. For instance:
# export PYTHONPATH="$PYTHONPATH:/var/www/siteX/server_modules"
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
