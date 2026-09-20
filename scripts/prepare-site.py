from pathlib import Path
from html import escape
import sys

archive = Path(sys.argv[1])
base_path = sys.argv[2].strip("/")
target = f"/{base_path}/tutorials/solarsystem/"
assert (archive / "tutorials/solarsystem/index.html").is_file()
assert (archive / "tutorials/solarsystem/01-projectandassets/index.html").is_file()
assert (archive / "downloads/org.spatialcomputingtechmap.solarsystemdocs/SolarSystem-Assets.zip").is_file()
(archive / ".nojekyll").touch()
(archive / "index.html").write_text(f"""<!doctype html>
<html lang="ko"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>SolarSystem 튜토리얼</title><meta http-equiv="refresh" content="0; url={escape(target, quote=True)}"></head>
<body><a href="{escape(target, quote=True)}">SolarSystem 튜토리얼 열기</a></body></html>
""")

# Preserve links shared before the four-chapter edition.
for old, new in {
    "01-projectsetup": "01-projectandassets",
    "02-placingplanets": "02-planetentity",
    "03-planetinfocards": "03-focusandpanel",
    "02-windowandspace": "04-appentrypoint",
    "03-sunandlighting": "02-planetentity",
    "04-planetsinorbit": "02-planetentity",
    "05-taptofocus": "03-focusandpanel",
    "06-infopanelandheadplacement": "03-focusandpanel",
    "07-appentrypoint": "04-appentrypoint",
}.items():
    destination = f"/{base_path}/tutorials/solarsystem/{new}/"
    assert (archive / f"tutorials/solarsystem/{new}/index.html").is_file()
    folder = archive / f"tutorials/solarsystem/{old}"
    folder.mkdir(parents=True, exist_ok=True)
    (folder / "index.html").write_text(f'''<!doctype html>
<html lang="ko"><head><meta charset="utf-8">
<meta http-equiv="refresh" content="0; url={escape(destination, quote=True)}">
<title>SolarSystem 튜토리얼</title></head>
<body><a href="{escape(destination, quote=True)}">업데이트된 챕터 열기</a></body></html>
''')
