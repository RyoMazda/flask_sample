import os
from flask import Flask, render_template, session, abort, current_app, g
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, String, Integer
from sqlalchemy import inspect


class PigiBase(object):
    def get_db_session(self):
        return inspect(self).session


Base = declarative_base(cls=PigiBase)


class Team(Base):
    __tablename__ = 'teams'
    id          = Column(Integer, autoincrement=True, nullable=False, primary_key=True)
    name        = Column(String(200), nullable=False, unique=True)
    member1     = Column(String(200), default='')
    member2     = Column(String(200), default='')
    member3     = Column(String(200), default='')
    hitokoto    = Column(String(200), default='')
    instance_ip = Column(String(200), default='')
    password    = Column(String(200), nullable=False)

    def __repr__(self):
        return "<Team(id={}, name={}, member1={}, member2={}, member3={}, hitokoto={}, instance_ip={}, password={})>". \
            format(self.id, self.name, self.member1, self.member2, self.member3, self.hitokoto, self.instance_ip, self.password)


app = Flask(__name__)
app.secret_key = os.environ.get('APP_SECRET_KEY')
app.config['DATABASE'] = os.environ.get('DB_HOST')


@app.route('/')
def home():
    app.logger.info('pigimaru')
    pigidict = {
        'env1': os.environ.get('APP_SECRET_KEY'),
        'env2': os.environ.get('DB_HOST'),
    }
    return render_template('home.html', myvar=pigidict)


@app.route('/error')
def error():
    raise Exception('This is intentional!')


@app.route('/users/<username>')
def user(username: str):
    return '<h1>Welcome ' + username + '!</h1>'


def get_db():
    if 'db' not in g:
        engine = create_engine(current_app.config['DATABASE'], echo=False)
        Session = sessionmaker(bind=engine)
        g.db = Session()
    return g.db


@app.route('/init_db')
def init_db():
    app.logger.info('trying to get db')
    engine = create_engine(current_app.config['DATABASE'], echo=True)
    Session = sessionmaker(bind=engine)
    session = Session()

    Base.metadata.drop_all(bind=engine)  # dbリセット
    Base.metadata.create_all(bind=engine)  # テーブルを作成

    # Teamのテストデータ
    team_list = [('ぴぎまる', 'sbt', 'imns', 'o', 'ganbarimasu', '127.0.0.1', 'password'),
                 ('ぴぎまらない', 'wkwk', 'o', None, 'ganbarimasen', '192.168.0.1', 'abcd1234')]
    teams = list()
    for x in team_list:
        team = Team()
        team.name, team.member1, team.member2, team.member3, team.hitokoto, team.instance_ip, team.password = x
        teams.append(team)
    session.add_all(teams)
    session.commit()

    return 'success!'


@app.route('/teams')
def teams():
    app.logger.info('trying to get db')
    teams = get_db().query(Team).all()
    app.logger.info('get db succeeded!')
    return render_template('team.html', teams=teams)


if __name__ == '__main__':
    print('hello from app.py')
    print(__name__)
    app.run(debug=True, host='0.0.0.0', port=5000)

