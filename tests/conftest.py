import pytest
from boxer.main import create_app

@pytest.fixture()
def app():
    app = create_app({
        'TESTING': True,
    })

    yield app


@pytest.fixture()
def client(app):
    # Tests will use the client to make requests to the application without running the server.
    return app.test_client()


@pytest.fixture()
def runner(app):
    # can call the Click commands registered with the application
    return app.test_cli_runner()
