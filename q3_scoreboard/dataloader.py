from . import models
from . import db
from quake3_log_parser import parser


def get_user_id_from_username(username):
    user = models.User.get_user_or_create_user(username)
    return user.id


# returns the username or <BOT> of the player
def get_userid(player):
    if player.is_bot:
        return models.BOT_ID
    return get_user_id_from_username(player.name)


# Do everything based on death so we have suicides added
def load_stat_table_kill_entry(game_id, kills, commit=False):
    for kill in kills:
        killer_id = get_userid(kill.killer)
        victum_id = get_userid(kill.victum)
        kill_entry = models.GameKill(game_id, killer_id, victum_id,
                                     kill.kill_method)
        db.session.add(kill_entry)
    if commit:
        db.session.commit()


def load_stat_table(game_id, stat_table):
    print(stat_table)
    for kills in stat_table.death_by_player.values():
        load_stat_table_kill_entry(game_id, kills, False)
    db.session.commit()


def add_game(game):
    game_model = models.Game()
    db.session.add(game_model)
    # commit so we can get the game id
    db.session.commit()
    for stat_table in game.stat_table.values():
        # TODO: What to do about bots....Probably handle in the
        # load_stat_table_killl_entry
        load_stat_table(game_model.id, stat_table)


def load_from_text(input_data):
    games = parser.parse_str(input_data)

    for game in games:
        add_game(game)
