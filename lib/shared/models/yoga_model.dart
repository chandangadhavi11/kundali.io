/// Yoga/Dosha type classification
enum YogaType {
  rajYoga,           // Royal yogas - success, power, authority
  dhanaYoga,         // Wealth yogas - prosperity, financial gains
  panchaMahapurusha, // Five great person yogas
  arishta,           // Malefic yogas/doshas - obstacles, challenges
  benefic,           // General benefic combinations
  malefic,           // General malefic combinations (doshas)
}

/// Detailed information about a Yoga or Dosha
class YogaInfo {
  final String name;
  final YogaType type;
  final String description;
  final String effects;
  final List<String> remedies;
  final String formingPlanets;  // Which planets form this yoga
  final bool isPresent;
  final double strength;  // 0.0 to 1.0, how strongly formed

  const YogaInfo({
    required this.name,
    required this.type,
    required this.description,
    required this.effects,
    this.remedies = const [],
    this.formingPlanets = '',
    this.isPresent = true,
    this.strength = 1.0,
  });

  /// Get type display name
  String get typeDisplayName {
    switch (type) {
      case YogaType.rajYoga:
        return 'Raja Yoga';
      case YogaType.dhanaYoga:
        return 'Dhana Yoga';
      case YogaType.panchaMahapurusha:
        return 'Pancha Mahapurusha';
      case YogaType.arishta:
        return 'Dosha';
      case YogaType.benefic:
        return 'Benefic Yoga';
      case YogaType.malefic:
        return 'Dosha';
    }
  }

  /// Check if this is a dosha (malefic)
  bool get isDosha => type == YogaType.arishta || type == YogaType.malefic;

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type.toString(),
    'description': description,
    'effects': effects,
    'remedies': remedies,
    'formingPlanets': formingPlanets,
    'isPresent': isPresent,
    'strength': strength,
  };
}

/// Static yoga definitions with descriptions and remedies
class YogaDefinitions {
  // ============ RAJA YOGAS ============
  
  static YogaInfo gajakesariYoga(String planets) => YogaInfo(
    name: 'Gajakesari Yoga',
    type: YogaType.rajYoga,
    description: 'Jupiter is in a Kendra (1st, 4th, 7th, or 10th) from Moon.',
    effects: 'Bestows wisdom, intelligence, good reputation, wealth, and leadership qualities. The native is respected in society and achieves success through knowledge and righteous conduct.',
    remedies: ['Worship Lord Ganesha', 'Chant Jupiter mantras on Thursday', 'Donate yellow items'],
    formingPlanets: planets,
  );

  static YogaInfo budhadityaYoga(String planets) => YogaInfo(
    name: 'Budhaditya Yoga',
    type: YogaType.rajYoga,
    description: 'Sun and Mercury are conjunct in the same sign.',
    effects: 'Grants sharp intellect, excellent communication skills, success in education, and fame through intellectual pursuits. The native excels in writing, speaking, and analytical work.',
    remedies: ['Worship Lord Vishnu', 'Chant Gayatri Mantra', 'Donate green items on Wednesday'],
    formingPlanets: planets,
  );

  static YogaInfo chandraMangalYoga(String planets) => YogaInfo(
    name: 'Chandra-Mangal Yoga',
    type: YogaType.dhanaYoga,
    description: 'Moon and Mars are conjunct in the same sign.',
    effects: 'Creates wealth through business, courage, and determined efforts. The native has strong willpower and can earn through real estate, manufacturing, or entrepreneurship.',
    remedies: ['Worship Lord Hanuman', 'Chant Mars mantras on Tuesday', 'Donate red items'],
    formingPlanets: planets,
  );

  static YogaInfo lakshmiYoga(String planets) => YogaInfo(
    name: 'Lakshmi Yoga',
    type: YogaType.dhanaYoga,
    description: '9th lord is in Kendra and Venus is strong in own/exaltation sign.',
    effects: 'Brings abundant wealth, luxury, beauty, and all comforts of life. The native enjoys prosperity, owns properties, vehicles, and lives a comfortable life.',
    remedies: ['Worship Goddess Lakshmi', 'Chant Sri Suktam', 'Donate white items on Friday'],
    formingPlanets: planets,
  );

  static YogaInfo viparitaRajaYoga(String planets) => YogaInfo(
    name: 'Viparita Raja Yoga',
    type: YogaType.rajYoga,
    description: 'Lords of 6th, 8th, or 12th houses are placed in each other\'s houses.',
    effects: 'Success comes through unconventional means or after initial struggles. The native rises from adversity and achieves greatness through challenges.',
    remedies: ['Maintain patience during difficulties', 'Perform charity', 'Worship Lord Shiva'],
    formingPlanets: planets,
  );

  static YogaInfo neechabhangaRajaYoga(String planets) => YogaInfo(
    name: 'Neechabhanga Raja Yoga',
    type: YogaType.rajYoga,
    description: 'A debilitated planet\'s weakness is cancelled by specific planetary positions.',
    effects: 'Transforms weakness into strength. Initial struggles lead to remarkable success. The native overcomes obstacles and achieves high status.',
    remedies: ['Worship the deity of the debilitated planet', 'Perform remedies for the weak planet', 'Practice patience'],
    formingPlanets: planets,
  );

  static YogaInfo dhanaYoga(String planets) => YogaInfo(
    name: 'Dhana Yoga',
    type: YogaType.dhanaYoga,
    description: 'Lords of 2nd and 11th houses are connected through conjunction, aspect, or exchange.',
    effects: 'Creates wealth accumulation and financial prosperity. The native earns well and accumulates assets throughout life.',
    remedies: ['Worship Kubera', 'Donate food', 'Perform charity on auspicious days'],
    formingPlanets: planets,
  );

  static YogaInfo sunafaYoga(String planets) => YogaInfo(
    name: 'Sunafa Yoga',
    type: YogaType.benefic,
    description: 'Any planet (except Sun, Rahu, Ketu) occupies the 2nd house from Moon.',
    effects: 'Brings self-earned wealth, good health, and respectability. The native is intelligent and achieves through personal efforts.',
    remedies: ['Strengthen the planet in 2nd from Moon', 'Donate on Monday'],
    formingPlanets: planets,
  );

  static YogaInfo anafaYoga(String planets) => YogaInfo(
    name: 'Anafa Yoga',
    type: YogaType.benefic,
    description: 'Any planet (except Sun, Rahu, Ketu) occupies the 12th house from Moon.',
    effects: 'Grants good looks, virtue, comfort, and fame. The native has a pleasant personality and enjoys social recognition.',
    remedies: ['Strengthen the planet in 12th from Moon', 'Practice meditation'],
    formingPlanets: planets,
  );

  static YogaInfo duradhuraYoga(String planets) => YogaInfo(
    name: 'Durudhura Yoga',
    type: YogaType.benefic,
    description: 'Planets occupy both 2nd and 12th houses from Moon.',
    effects: 'Blessed with wealth, vehicles, servants, and enjoyments. The native is generous and enjoys all comforts of life.',
    remedies: ['Worship Moon', 'Donate white items', 'Practice charity'],
    formingPlanets: planets,
  );

  // ============ PANCHA MAHAPURUSHA YOGAS ============

  static YogaInfo hamsaYoga(String planets) => YogaInfo(
    name: 'Hamsa Yoga',
    type: YogaType.panchaMahapurusha,
    description: 'Jupiter is in a Kendra (1, 4, 7, 10) in its own sign (Sagittarius/Pisces) or exaltation (Cancer).',
    effects: 'Bestows divine qualities, wisdom, spiritual inclination, good fortune, and respect from learned people. The native is virtuous, handsome, and long-lived.',
    remedies: ['Worship Lord Vishnu', 'Study scriptures', 'Practice dharma', 'Feed Brahmins on Thursday'],
    formingPlanets: planets,
  );

  static YogaInfo malavyaYoga(String planets) => YogaInfo(
    name: 'Malavya Yoga',
    type: YogaType.panchaMahapurusha,
    description: 'Venus is in a Kendra (1, 4, 7, 10) in its own sign (Taurus/Libra) or exaltation (Pisces).',
    effects: 'Grants beauty, artistic talents, luxurious life, happy marriage, wealth, and fame. The native enjoys sensual pleasures and has a magnetic personality.',
    remedies: ['Worship Goddess Lakshmi', 'Appreciate arts', 'Donate white items on Friday'],
    formingPlanets: planets,
  );

  static YogaInfo bhadraYoga(String planets) => YogaInfo(
    name: 'Bhadra Yoga',
    type: YogaType.panchaMahapurusha,
    description: 'Mercury is in a Kendra (1, 4, 7, 10) in its own sign (Gemini/Virgo).',
    effects: 'Grants intelligence, eloquence, learning, wit, and success in business and communication. The native is skilled in multiple disciplines and respected for knowledge.',
    remedies: ['Worship Lord Vishnu', 'Study and teach', 'Donate green items on Wednesday'],
    formingPlanets: planets,
  );

  static YogaInfo ruchakaYoga(String planets) => YogaInfo(
    name: 'Ruchaka Yoga',
    type: YogaType.panchaMahapurusha,
    description: 'Mars is in a Kendra (1, 4, 7, 10) in its own sign (Aries/Scorpio) or exaltation (Capricorn).',
    effects: 'Bestows courage, valor, leadership in military/sports, strong physique, and success through bold actions. The native is fearless and commands respect.',
    remedies: ['Worship Lord Hanuman', 'Practice physical discipline', 'Donate red items on Tuesday'],
    formingPlanets: planets,
  );

  static YogaInfo sasaYoga(String planets) => YogaInfo(
    name: 'Sasa Yoga',
    type: YogaType.panchaMahapurusha,
    description: 'Saturn is in a Kendra (1, 4, 7, 10) in its own sign (Capricorn/Aquarius) or exaltation (Libra).',
    effects: 'Grants authority, command over servants, success in politics/administration, and wealth through hard work. The native rises to high positions through perseverance.',
    remedies: ['Worship Lord Shani', 'Serve the elderly', 'Donate black items on Saturday'],
    formingPlanets: planets,
  );

  // ============ DOSHAS (Malefic Yogas) ============

  static YogaInfo manglikDosha(String planets) => YogaInfo(
    name: 'Manglik Dosha',
    type: YogaType.arishta,
    description: 'Mars is placed in 1st, 4th, 7th, 8th, or 12th house from Ascendant.',
    effects: 'May cause delays in marriage, conflicts with spouse, or challenges in married life. The energy of Mars needs proper channeling.',
    remedies: [
      'Perform Mangal Shanti Puja',
      'Chant Hanuman Chalisa',
      'Fast on Tuesdays',
      'Marry another Manglik (cancels effect)',
      'Perform Kumbh Vivah before marriage',
    ],
    formingPlanets: planets,
  );

  static YogaInfo kaalSarpDosha(String planets) => YogaInfo(
    name: 'Kaal Sarp Dosha',
    type: YogaType.arishta,
    description: 'All planets are hemmed between Rahu and Ketu.',
    effects: 'May bring sudden ups and downs, struggles, delays in success, and karmic challenges. Life follows an unusual pattern with unexpected events.',
    remedies: [
      'Visit Trimbakeshwar or Kalahasti temple',
      'Perform Kaal Sarp Puja',
      'Chant Maha Mrityunjaya Mantra',
      'Donate to snake-related charities',
      'Feed birds daily',
    ],
    formingPlanets: planets,
  );

  static YogaInfo pitraDosha(String planets) => YogaInfo(
    name: 'Pitra Dosha',
    type: YogaType.arishta,
    description: 'Sun is afflicted by Rahu/Ketu, or 9th house is afflicted.',
    effects: 'Indicates ancestral karma that needs resolution. May affect father, career, or fortune until remedied.',
    remedies: [
      'Perform Pitra Tarpan on Amavasya',
      'Do Shradh rituals',
      'Feed crows and dogs',
      'Donate to elderly homes',
      'Visit Gaya for Pind Daan',
    ],
    formingPlanets: planets,
  );

  static YogaInfo grahanDosha(String planets) => YogaInfo(
    name: 'Grahan Dosha',
    type: YogaType.arishta,
    description: 'Sun or Moon is conjunct with Rahu or Ketu.',
    effects: 'May affect health, mental peace, and success related to Sun (father, career) or Moon (mother, mind) depending on which luminary is afflicted.',
    remedies: [
      'Chant mantras of afflicted luminary',
      'Donate items related to Rahu/Ketu',
      'Perform Grahan Dosha Shanti',
      'Fast during eclipses',
    ],
    formingPlanets: planets,
  );

  static YogaInfo shrapitDosha(String planets) => YogaInfo(
    name: 'Shrapit Dosha',
    type: YogaType.arishta,
    description: 'Saturn and Rahu are conjunct in any house.',
    effects: 'Indicates past-life karmic debt. May cause delays, obstacles, and challenges that require patience to overcome.',
    remedies: [
      'Perform Shrapit Dosha Nivaran Puja',
      'Serve the disabled and elderly',
      'Chant Shani and Rahu mantras',
      'Donate black items on Saturday',
    ],
    formingPlanets: planets,
  );

  static YogaInfo guruChandalYoga(String planets) => YogaInfo(
    name: 'Guru Chandal Yoga',
    type: YogaType.arishta,
    description: 'Jupiter is conjunct with Rahu.',
    effects: 'May affect wisdom, spirituality, and traditional values. The native may have unconventional beliefs or face challenges with teachers/gurus.',
    remedies: [
      'Worship Lord Vishnu',
      'Respect teachers and elders',
      'Study scriptures',
      'Perform Jupiter-related charities',
      'Chant Guru mantra on Thursday',
    ],
    formingPlanets: planets,
  );

  static YogaInfo kemdrumDosha(String planets) => YogaInfo(
    name: 'Kemdrum Dosha',
    type: YogaType.arishta,
    description: 'Moon has no planets in the 2nd or 12th house from it.',
    effects: 'May cause emotional instability, poverty, lack of support, and mental disturbances. The native may feel lonely or unsupported.',
    remedies: [
      'Strengthen Moon with white items',
      'Chant Chandra mantra',
      'Fast on Monday',
      'Wear pearl (after consultation)',
      'Serve mother and elderly women',
    ],
    formingPlanets: planets,
  );

  static YogaInfo chandraGrahanDosha(String planets) => YogaInfo(
    name: 'Chandra Grahan Dosha',
    type: YogaType.arishta,
    description: 'Moon is conjunct with Rahu or Ketu.',
    effects: 'May affect mental peace, relationship with mother, and emotional stability. The mind may be prone to anxiety or unusual thoughts.',
    remedies: [
      'Chant Chandra mantra 108 times daily',
      'Wear pearl or moonstone',
      'Fast on Monday',
      'Donate white items',
      'Serve mother',
    ],
    formingPlanets: planets,
  );

  static YogaInfo suryaGrahanDosha(String planets) => YogaInfo(
    name: 'Surya Grahan Dosha',
    type: YogaType.arishta,
    description: 'Sun is conjunct with Rahu or Ketu.',
    effects: 'May affect career, relationship with father, health, and authority. The native may face challenges with government or authority figures.',
    remedies: [
      'Chant Aditya Hridayam',
      'Offer water to Sun at sunrise',
      'Donate wheat on Sunday',
      'Serve father',
    ],
    formingPlanets: planets,
  );
}

