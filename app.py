from flask import Flask, render_template, url_for

app = Flask(__name__)


@app.route('/')
def home():
    pigidict = {
        '長男': 'ぴぎ太郎',
        '次男': 'ぴぎ次郎',
    }
    return render_template('home.html', myvar=pigidict)


@app.route('/error')
def error():
    raise Exception('This is intentional!')


@app.route('/users/<username>')
def user(username: str):
    return '<h1>Welcome ' + username + '!</h1>'


if __name__ == '__main__':
    print('hello from app.py')
    print(__name__)
    app.run(debug=True, host='0.0.0.0')

