import 'package:flutter/material.dart';

class AppIcons {
  // Achievement Icons
  static const IconData trophy = Icons.emoji_events;
  static const IconData medal = Icons.military_tech;
  static const IconData crown = Icons.workspace_premium;
  static const IconData star = Icons.star;
  static const IconData diamond = Icons.diamond;
  static const IconData shield = Icons.shield;
  static const IconData rocket = Icons.rocket_launch;
  static const IconData target = Icons.gps_fixed;

  // Assessment Icons
  static const IconData depression = Icons.sentiment_very_dissatisfied;
  static const IconData anxiety = Icons.psychology;
  static const IconData stress = Icons.trending_up;
  static const IconData brain = Icons.psychology_alt;
  static const IconData heart = Icons.favorite;
  static const IconData health = Icons.health_and_safety;

  // Notification Icons
  static const IconData notification = Icons.notifications;
  static const IconData reminder = Icons.schedule;
  static const IconData celebration = Icons.celebration;
  static const IconData checkCircle = Icons.check_circle;
  static const IconData info = Icons.info;
  static const IconData warning = Icons.warning;

  // Recommendation Icons
  static const IconData hospital = Icons.local_hospital;
  static const IconData meditation = Icons.self_improvement;
  static const IconData exercise = Icons.fitness_center;
  static const IconData sleep = Icons.bedtime;
  static const IconData social = Icons.people;
  static const IconData book = Icons.menu_book;
  static const IconData music = Icons.music_note;
  static const IconData nature = Icons.park;
  static const IconData time = Icons.access_time;
  static const IconData block = Icons.block;
  static const IconData communication = Icons.chat;
  static const IconData refresh = Icons.refresh;
  static const IconData hearing = Icons.hearing;
  static const IconData visibility = Icons.visibility;
  static const IconData lightbulb = Icons.lightbulb;
  static const IconData headphones = Icons.headphones;

  // Analysis Icons
  static const IconData analytics = Icons.analytics;
  static const IconData chartBar = Icons.bar_chart;
  static const IconData trendingUp = Icons.trending_up;
  static const IconData trendingDown = Icons.trending_down;
  static const IconData assessment = Icons.assignment;

  // UI Icons
  static const IconData home = Icons.home;
  static const IconData settings = Icons.settings;
  static const IconData profile = Icons.person;
  static const IconData logout = Icons.logout;
  static const IconData login = Icons.login;
  static const IconData register = Icons.person_add;
  static const IconData back = Icons.arrow_back;
  static const IconData forward = Icons.arrow_forward;
  static const IconData close = Icons.close;
  static const IconData menu = Icons.menu;
  static const IconData search = Icons.search;
  static const IconData filter = Icons.filter_list;
  static const IconData sort = Icons.sort;
  static const IconData share = Icons.share;
  static const IconData download = Icons.download;
  static const IconData upload = Icons.upload;
  static const IconData edit = Icons.edit;
  static const IconData delete = Icons.delete;
  static const IconData add = Icons.add;
  static const IconData remove = Icons.remove;
  static const IconData save = Icons.save;
  static const IconData cancel = Icons.cancel;
  static const IconData done = Icons.done;
  static const IconData help = Icons.help;
  static const IconData support = Icons.support;
  static const IconData feedback = Icons.feedback;
  static const IconData rate = Icons.star_rate;
  static const IconData security = Icons.security;
  static const IconData privacy = Icons.privacy_tip;
  static const IconData language = Icons.language;
  static const IconData theme = Icons.palette;
  static const IconData darkMode = Icons.dark_mode;
  static const IconData lightMode = Icons.light_mode;
  static const IconData autoMode = Icons.brightness_auto;

  // Status Icons
  static const IconData success = Icons.check_circle;
  static const IconData error = Icons.error;
  static const IconData loading = Icons.hourglass_empty;
  static const IconData offline = Icons.wifi_off;
  static const IconData online = Icons.wifi;
  static const IconData sync = Icons.sync;
  static const IconData cloud = Icons.cloud;
  static const IconData cloudOff = Icons.cloud_off;

  // Achievement specific icons with colors
  static const Map<String, IconData> achievementIcons = {
    'first_assessment': Icons.play_arrow,
    'streak_3': Icons.local_fire_department,
    'perfectionist': Icons.star,
    'explorer': Icons.explore,
    'consistent': Icons.schedule,
    'improver': Icons.trending_up,
    'social': Icons.share,
    'dedicated': Icons.loyalty,
  };

  // Leaderboard position icons
  static const Map<int, IconData> positionIcons = {
    1: Icons.workspace_premium, // Gold crown
    2: Icons.military_tech, // Silver medal
    3: Icons.emoji_events, // Bronze trophy
  };

  // Assessment type icons
  static const Map<String, IconData> assessmentTypeIcons = {
    'DASS-21': Icons.psychology,
    'anxiety': Icons.sentiment_very_dissatisfied,
    'depression': Icons.sentiment_dissatisfied,
    'stress': Icons.trending_up,
    'autism': Icons.psychology_alt,
    'adhd': Icons.flash_on,
    'general': Icons.assignment,
  };
}
