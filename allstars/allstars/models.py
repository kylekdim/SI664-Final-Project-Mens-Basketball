# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey has `on_delete` set to the desired behavior.
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class AllStar(models.Model):
    all_star_id = models.AutoField(primary_key=True)
    player_record = models.ForeignKey('PlayerRecord', models.DO_NOTHING)
    year = models.IntegerField()
    conference = models.CharField(max_length=20, blank=True, null=True)
    league = models.ForeignKey('League', models.DO_NOTHING)
    games_played = models.IntegerField(blank=True, null=True)
    minutes = models.IntegerField(blank=True, null=True)
    points = models.IntegerField(blank=True, null=True)
    rebounds = models.IntegerField(blank=True, null=True)
    assists = models.IntegerField(blank=True, null=True)
    steals = models.IntegerField(blank=True, null=True)
    blocks = models.IntegerField(blank=True, null=True)
    turnovers = models.IntegerField(blank=True, null=True)
    ft_attempted = models.IntegerField(blank=True, null=True)
    ft_made = models.IntegerField(blank=True, null=True)
    three_attempted = models.IntegerField(blank=True, null=True)
    three_made = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'all_star'


class League(models.Model):
    league_id = models.AutoField(primary_key=True)
    league_abbrev = models.CharField(unique=True, max_length=10)
    league_name = models.CharField(db_column='League_name', unique=True, max_length=50)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'league'


class PlayerRecord(models.Model):
    player_record_id = models.AutoField(primary_key=True)
    player_id_long = models.CharField(unique=True, max_length=10)
    first_name = models.CharField(max_length=30, blank=True, null=True)
    middle_name = models.CharField(max_length=30, blank=True, null=True)
    last_name = models.CharField(max_length=30)
    full_given_name = models.CharField(max_length=100, blank=True, null=True)
    name_suffix = models.CharField(max_length=5, blank=True, null=True)
    nickname = models.CharField(max_length=30, blank=True, null=True)
    pos = models.CharField(max_length=10, blank=True, null=True)
    height = models.IntegerField(blank=True, null=True)
    weight = models.IntegerField(blank=True, null=True)
    college = models.CharField(max_length=50, blank=True, null=True)
    birthdate = models.CharField(max_length=20, blank=True, null=True)
    birth_city = models.CharField(max_length=50, blank=True, null=True)
    high_school = models.CharField(max_length=50, blank=True, null=True)
    hs_city = models.CharField(max_length=50, blank=True, null=True)
    hs_state = models.CharField(max_length=20, blank=True, null=True)
    hs_country = models.CharField(max_length=30, blank=True, null=True)
    death_date = models.CharField(max_length=20, blank=True, null=True)
    race = models.CharField(max_length=3, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'player_record'


class Team(models.Model):
    team_id = models.AutoField(primary_key=True)
    league = models.ForeignKey(League, models.DO_NOTHING)
    team_abbrev = models.CharField(max_length=10)
    name = models.CharField(max_length=100)
    arena = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'team'


class TeamStat(models.Model):
    team_stat_id = models.AutoField(primary_key=True)
    team = models.ForeignKey(Team, models.DO_NOTHING)
    year = models.IntegerField()
    home_won = models.IntegerField()
    home_lost = models.IntegerField()
    away_won = models.IntegerField()
    away_lost = models.IntegerField()
    neut_won = models.IntegerField()
    neut_lost = models.IntegerField()
    won = models.IntegerField()
    lost = models.IntegerField()
    games = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'team_stat'
