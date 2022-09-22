from boxer.main import create_app


def test_label(client):
    generated = client.get('/')
    wanted = b"""<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <link rel="stylesheet" href="/static/css/style.css">
        <title>Boxer App</title>
    </head>
    <body>
    <form action="/update">
    <h1>Welcome to the Boxer app</h1>
    <div class="box-with-button">
        <label>Bruno</label>
    <button>Submit</button>
    </div>
    </form>
    </body>
</html>"""
    assert generated.data == wanted
