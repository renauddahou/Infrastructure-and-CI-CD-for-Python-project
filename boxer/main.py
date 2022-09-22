#!/usr/bin/env python3

from flask import Flask, render_template, redirect, url_for
import os
import pymysql

db = pymysql.connect(host=os.getenv("DB_HOST"),
                     user=os.getenv("DB_USER"),
                     passwd=os.getenv("DB_PASS"),
                     database=os.getenv("DB_DATABASE"))


def gethtml(lbl):
    return render_template("template.html", Label=lbl)

def init_db(app): #call fetch init q & run queries on db
    cursor = db.cursor()
    sql_table = "CREATE TABLE IF NOT EXISTS dogs (id INT AUTO_INCREMENT PRIMARY KEY, name TEXT CHARACTER SET utf16 COLLATE utf16_unicode_ci NOT NULL)"
    cursor.execute(sql_table)
    with app.open_resource('box.sql') as f:
        db.cursor().executemany(f.read().decode('utf8'),[])
    db.commit()

def create_app(test_config=None):
    app = Flask(__name__)
    @app.route("/")
    def index():
        cursor = db.cursor()
        sql = "SELECT * FROM dogs"
        cursor.execute(sql)
        results = cursor.fetchall()
        print(results)
        sql_row = 0
        sql_column = 1
        return gethtml(results[sql_row][sql_column])

    @app.route("/update")
    def update():
        cursor = db.cursor()
        sql = "UPDATE dogs set name=concat(name,'b')"
        cursor.execute(sql)
        db.commit()
        return redirect(url_for('index'))

    return app


if __name__ == "__main__":
    app = create_app()
    init_db(app)
    app.run(host='0.0.0.0', port=8081, debug=False)
