import os

from flask import Flask
from flask_graphql import GraphQLView

from . import db, schema


def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(SECRET_KEY="dev")

    # load the instance config, if it exists
    app.config.from_pyfile(
        os.path.join(
            os.path.dirname(os.path.dirname(__file__)), "instance", "settings.cfg"
        ),
        silent=True,
    )

    if test_config is not None:
        # load the test config if passed in
        app.config.from_mapping(test_config)

    # ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    db.init_app(app)
    app.add_url_rule(
        "/graphql",
        view_func=GraphQLView.as_view("graphql", schema=schema.schema, graphiql=True),
    )

    return app
