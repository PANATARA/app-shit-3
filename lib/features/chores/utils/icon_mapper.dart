import 'package:flutter/material.dart';

class IconMapper {
  IconMapper._();

  static const Map<String, String> _emojiMap = {
    // ─── Pets & Animals ───
    'dog-face': '🐶',
    'cat-face': '🐱',
    'hamster-face': '🐹',
    'rabbit-face': '🐰',
    'fox-face': '🦊',
    'pig-face': '🐷',
    'mouse-face': '🐭',
    'horse-face': '🐴',
    'bird': '🐦',
    'duck': '🦆',
    'rooster': '🐓',
    'chicken': '🐔',
    'hatching-chick': '🐣',
    'lady-beetle': '🐞',
    'snail': '🐌',
    'fish': '🐟',
    'tropical-fish': '🐠',
    'blowfish': '🐡',
    'turtle': '🐢',
    'crocodile': '🐊',
    'snake': '🐍',
    'dragon-face': '🐲',
    'dragon': '🐉',
    'lizard': '🦎',
    'spider': '🕷️',
    'scorpion': '🦂',
    'monkey-face': '🐵',
    'monkey': '🐒',
    'elephant': '🐘',
    'bear-face': '🐻',
    'bear': '🐻',
    'panda-face': '🐼',
    'panda': '🐼',
    'koala': '🐨',
    'tiger-face': '🐯',
    'tiger': '🐅',
    'lion-face': '🦁',
    'lion': '🦁',
    'cow-face': '🐮',
    'cow': '🐄',
    'frog-face': '🐸',
    'frog': '🐸',
    'octopus': '🐙',
    'squid': '🦑',
    'crab': '🦀',
    'dolphin': '🐬',
    'whale': '🐳',
    'shark': '🦈',
    'penguin': '🐧',
    'owl': '🦉',
    'eagle': '🦅',
    'bat': '🦇',
    'wolf-face': '🐺',
    'wolf': '🐺',
    'unicorn-face': '🦄',
    'honeybee': '🐝',
    'bee': '🐝',
    'bug': '🐛',
    'butterfly': '🦋',
    'ant': '🐜',
    'hedgehog': '🦔',
    'deer': '🦌',
    'sloth': '🦥',
    'otter': '🦦',

    // ─── Faces & Expressions ───
    'grinning-face': '😀',
    'grinning-face-with-big-eyes': '😃',
    'smiling-face-with-heart-eyes': '😍',
    'face-with-tears-of-joy': '😂',
    'winking-face': '😉',
    'smiling-face-with-sunglasses': '😎',
    'sunglasses': '😎',
    'star-struck': '🤩',
    'partying-face': '🥳',
    'thinking-face': '🤔',
    'smiling-face-with-hearts': '🥰',
    'nerd-face': '🤓',
    'zany-face': '🤪',
    'relieved-face': '😌',
    'clown-face': '🤡',
    'ghost': '👻',
    'robot': '🤖',
    'alien': '👽',

    // ─── Symbols & Misc ───
    'fire': '🔥',
    'sparkles': '✨',
    'star': '⭐',
    'zap': '⚡',
    'collision': '💥',
    'heart': '❤️',
    'red-heart': '❤️',
    'pizza': '🍕',
    'cookie': '🍪',
    'coffee': '☕',
    'apple': '🍎',
  };

  /// Returns a unicode emoji if the icon identifier refers to an emoji.
  static String? getEmoji(String? iconName) {
    if (iconName == null || iconName.trim().isEmpty) return null;
    final trimmed = iconName.trim();

    // 1. Direct emoji characters (runes check)
    final runes = trimmed.runes.toList();
    if (runes.isNotEmpty && runes.any((r) => r > 0x1F000 || r == 0x2764 || r == 0x2B50 || r == 0x26A1)) {
      return trimmed;
    }

    // 2. Clean prefix (e.g. "emojione:monkey-face" -> "monkey-face")
    final clean = trimmed
        .toLowerCase()
        .replaceAll('emojione:', '')
        .replaceAll('twemoji:', '')
        .replaceAll('noto:', '')
        .replaceAll('openmoji:', '')
        .replaceAll('fluent-emoji:', '')
        .replaceAll('fxemoji:', '')
        .trim();

    // 3. Exact dictionary lookup
    if (_emojiMap.containsKey(clean)) {
      return _emojiMap[clean];
    }

    // 4. Keyword fuzzy match for animal / common emoji names
    if (clean.contains('monkey')) return '🐵';
    if (clean.contains('blowfish')) return '🐡';
    if (clean.contains('fish')) return '🐟';
    if (clean.contains('dog')) return '🐶';
    if (clean.contains('cat')) return '🐱';
    if (clean.contains('fox')) return '🦊';
    if (clean.contains('rabbit') || clean.contains('bunny')) return '🐰';
    if (clean.contains('hamster')) return '🐹';
    if (clean.contains('bear')) return '🐻';
    if (clean.contains('panda')) return '🐼';
    if (clean.contains('koala')) return '🐨';
    if (clean.contains('tiger')) return '🐯';
    if (clean.contains('lion')) return '🦁';
    if (clean.contains('cow')) return '🐮';
    if (clean.contains('pig')) return '🐷';
    if (clean.contains('frog')) return '🐸';
    if (clean.contains('duck')) return '🦆';
    if (clean.contains('bird')) return '🐦';
    if (clean.contains('turtle')) return '🐢';
    if (clean.contains('snake')) return '🐍';
    if (clean.contains('dragon')) return '🐲';
    if (clean.contains('elephant')) return '🐘';
    if (clean.contains('mouse')) return '🐭';
    if (clean.contains('horse')) return '🐴';
    if (clean.contains('chicken') || clean.contains('rooster')) return '🐔';
    if (clean.contains('snail')) return '🐌';
    if (clean.contains('spider')) return '🕷️';
    if (clean.contains('scorpion')) return '🦂';
    if (clean.contains('lizard')) return '🦎';
    if (clean.contains('crocodile')) return '🐊';
    if (clean.contains('beetle') || clean.contains('ladybug')) return '🐞';
    if (clean.contains('octopus')) return '🐙';
    if (clean.contains('shark')) return '🦈';
    if (clean.contains('dolphin')) return '🐬';
    if (clean.contains('whale')) return '🐳';
    if (clean.contains('owl')) return '🦉';
    if (clean.contains('penguin')) return '🐧';
    if (clean.contains('bee')) return '🐝';
    if (clean.contains('butterfly')) return '🦋';
    if (clean.contains('wolf')) return '🐺';

    return null;
  }

  static const Map<String, IconData> _symbolMap = {
    // ─── Home ───
    'house-rounded': Icons.house_rounded,
    'house': Icons.home_rounded,
    'home-rounded': Icons.home_rounded,
    'bed-rounded': Icons.bed_rounded,
    'ac-unit-rounded': Icons.ac_unit_rounded,
    'electric-bolt-rounded': Icons.electric_bolt_rounded,
    'chair-rounded': Icons.chair_rounded,
    'coffee-rounded': Icons.coffee_rounded,
    'checkroom-rounded': Icons.checkroom_rounded,
    'mode-fan-rounded': Icons.mode_fan_off_rounded,
    'shower-rounded': Icons.shower_rounded,
    'mop-rounded': Icons.cleaning_services_rounded,
    'thermometer-rounded': Icons.thermostat_rounded,
    'kitchen-rounded': Icons.kitchen_rounded,
    'styler-rounded': Icons.dry_cleaning_rounded,
    'yard-rounded': Icons.yard_rounded,
    'bathtub-rounded': Icons.bathtub_rounded,
    'king-bed-rounded': Icons.king_bed_rounded,
    'valve-rounded': Icons.plumbing_rounded,
    'window-rounded': Icons.window_rounded,
    'cooking-rounded': Icons.soup_kitchen_rounded,
    'door-front-rounded': Icons.door_front_door_rounded,
    'garage-rounded': Icons.garage_rounded,
    'light-rounded': Icons.light_rounded,
    'dining-rounded': Icons.dinner_dining_rounded,
    'hardware-rounded': Icons.hardware_rounded,
    'microwave-rounded': Icons.microwave_rounded,
    'oven-gen-rounded': Icons.countertops_rounded,
    'bathroom-rounded': Icons.bathroom_rounded,
    'table-bar-rounded': Icons.table_bar_rounded,
    'iron-rounded': Icons.iron_rounded,
    'dishwasher-gen-rounded': Icons.local_laundry_service_rounded,
    'faucet-rounded': Icons.water_damage_rounded,
    'dresser-rounded': Icons.inventory_2_rounded,
    'kettle-rounded': Icons.coffee_maker_rounded,
    'vacuum-rounded': Icons.toys_rounded,
    'oven-rounded': Icons.outdoor_grill_rounded,
    'pets-rounded': Icons.pets_rounded,

    // ─── People ───
    'person-rounded': Icons.person_rounded,
    'face': Icons.face_rounded,
    'face-2': Icons.face_2_rounded,
    'face-3': Icons.face_3_rounded,
    'face-4': Icons.face_4_rounded,
    'face-5': Icons.face_5_rounded,
    'face-6': Icons.face_6_rounded,
    'boy-rounded': Icons.boy_rounded,
    'girl-rounded': Icons.girl_rounded,
    'elderly-rounded': Icons.elderly_rounded,
    'elderly-woman-rounded': Icons.elderly_woman_rounded,
    'account-circle-rounded': Icons.account_circle_rounded,
    'face-2-rounded': Icons.face_2_rounded,
    'face-3-rounded': Icons.face_3_rounded,
    'face-4-rounded': Icons.face_4_rounded,
    'face-5-rounded': Icons.face_5_rounded,
    'face-6-rounded': Icons.face_6_rounded,
    'person-2-rounded': Icons.person_2_rounded,
    'person-3-rounded': Icons.person_3_rounded,
    'person-4-rounded': Icons.person_4_rounded,

    // ─── Nature ───
    'eco-rounded': Icons.eco_rounded,
    'local-florist-rounded': Icons.local_florist_rounded,
    'forest-rounded': Icons.forest_rounded,
    'grass-rounded': Icons.grass_rounded,
    'water-drop-rounded': Icons.water_drop_rounded,
    'wb-sunny-rounded': Icons.wb_sunny_rounded,
    'thunderstorm-rounded': Icons.thunderstorm_rounded,
    'local-fire-department-rounded': Icons.local_fire_department_rounded,
    'volcano-rounded': Icons.volcano_rounded,
    'mode-night-rounded': Icons.mode_night_rounded,
    'star-rounded': Icons.star_rounded,

    // ─── Misc ───
    'favorite-rounded': Icons.favorite_rounded,
    'bolt-rounded': Icons.bolt_rounded,
    'rocket-launch-rounded': Icons.rocket_launch_rounded,
    'diamond-rounded': Icons.diamond_rounded,
    'emoji-events': Icons.emoji_events_rounded,
    'emoji-events-rounded': Icons.emoji_events_rounded,
    'auto-awesome-rounded': Icons.auto_awesome_rounded,
    'wb-incandescent-rounded': Icons.wb_incandescent_rounded,
    'local-activity-rounded': Icons.local_activity_rounded,
    'savings-rounded': Icons.savings_rounded,
  };

  /// Maps string icon identifiers to Flutter [IconData].
  static IconData getIcon(String? iconName) {
    if (iconName == null || iconName.trim().isEmpty) {
      return Icons.cleaning_services_rounded;
    }

    final raw = iconName.trim().toLowerCase();
    final clean = raw
        .replaceAll('material-symbols:', '')
        .replaceAll('lucide:', '')
        .replaceAll('mdi:', '')
        .trim();

    if (_symbolMap.containsKey(clean)) {
      return _symbolMap[clean]!;
    }

    final key = clean
        .replaceAll('-rounded', '')
        .replaceAll('-outline', '')
        .replaceAll('-sharp', '')
        .trim();

    if (_symbolMap.containsKey(key)) {
      return _symbolMap[key]!;
    }

    // ─── People & Faces ───
    if (key.contains('boy')) return Icons.boy_rounded;
    if (key.contains('girl')) return Icons.girl_rounded;
    if (key.contains('elderly-woman')) return Icons.elderly_woman_rounded;
    if (key.contains('elderly')) return Icons.elderly_rounded;
    if (key.contains('account-circle')) return Icons.account_circle_rounded;
    if (key.contains('face-2') || key.contains('face-3') || key.contains('face-4') || key.contains('face-5') || key.contains('face-6')) {
      return Icons.face_2_rounded;
    }
    if (key.contains('face')) return Icons.face_rounded;
    if (key.contains('person-2') || key.contains('person-3') || key.contains('person-4')) {
      return Icons.person_2_rounded;
    }
    if (key.contains('person') || key.contains('user')) return Icons.person_rounded;
    if (key.contains('child') || key.contains('baby')) return Icons.child_care_rounded;

    // ─── Nature & Weather ───
    if (key.contains('eco') || key.contains('leaf')) return Icons.eco_rounded;
    if (key.contains('florist') || key.contains('flower')) return Icons.local_florist_rounded;
    if (key.contains('forest') || key.contains('tree')) return Icons.forest_rounded;
    if (key.contains('grass') || key.contains('yard') || key.contains('garden')) return Icons.yard_rounded;
    if (key.contains('water') || key.contains('drop')) return Icons.water_drop_rounded;
    if (key.contains('sunny') || key.contains('sun')) return Icons.wb_sunny_rounded;
    if (key.contains('thunder') || key.contains('storm')) return Icons.thunderstorm_rounded;
    if (key.contains('fire') || key.contains('flame')) return Icons.local_fire_department_rounded;
    if (key.contains('volcano')) return Icons.volcano_rounded;
    if (key.contains('night') || key.contains('moon')) return Icons.mode_night_rounded;
    if (key.contains('star')) return Icons.star_rounded;

    // ─── Misc & Awards ───
    if (key.contains('favorite') || key.contains('heart')) return Icons.favorite_rounded;
    if (key.contains('bolt') || key.contains('flash') || key.contains('electric')) return Icons.bolt_rounded;
    if (key.contains('rocket')) return Icons.rocket_launch_rounded;
    if (key.contains('diamond') || key.contains('gem')) return Icons.diamond_rounded;
    if (key.contains('trophy') || key.contains('event')) return Icons.emoji_events_rounded;
    if (key.contains('awesome') || key.contains('sparkle')) return Icons.auto_awesome_rounded;
    if (key.contains('incandescent') || key.contains('light') || key.contains('bulb')) return Icons.light_rounded;
    if (key.contains('activity')) return Icons.local_activity_rounded;
    if (key.contains('savings') || key.contains('money')) return Icons.savings_rounded;

    // ─── Home & Chores ───
    if (key.contains('clean') || key.contains('broom') || key.contains('brush') || key.contains('mop')) {
      return Icons.cleaning_services_rounded;
    }
    if (key.contains('wash') || key.contains('sink')) return Icons.wash_rounded;
    if (key.contains('vacuum')) return Icons.toys_rounded;
    if (key.contains('laundry')) return Icons.local_laundry_service_rounded;
    if (key.contains('trash') || key.contains('delete') || key.contains('bin')) return Icons.delete_outline_rounded;
    if (key.contains('kitchen') || key.contains('microwave')) return Icons.kitchen_rounded;
    if (key.contains('dish') || key.contains('restaurant') || key.contains('dining') || key.contains('cooking')) {
      return Icons.restaurant_rounded;
    }
    if (key.contains('bed')) return Icons.bed_rounded;
    if (key.contains('iron')) return Icons.iron_rounded;
    if (key.contains('pet') || key.contains('dog') || key.contains('cat')) return Icons.pets_rounded;
    if (key.contains('plant')) return Icons.yard_rounded;
    if (key.contains('shop') || key.contains('cart') || key.contains('bag')) return Icons.shopping_bag_outlined;
    if (key.contains('repeat') || key.contains('sync')) return Icons.repeat_rounded;
    if (key.contains('car')) return Icons.directions_car_rounded;
    if (key.contains('window')) return Icons.window_rounded;
    if (key.contains('bath') || key.contains('shower')) return Icons.bathtub_rounded;
    if (key.contains('check')) return Icons.check_circle_outline_rounded;
    if (key.contains('house') || key.contains('home')) return Icons.home_rounded;
    if (key.contains('chair') || key.contains('table')) return Icons.chair_rounded;
    if (key.contains('coffee')) return Icons.coffee_rounded;

    return Icons.task_alt_rounded;
  }
}
