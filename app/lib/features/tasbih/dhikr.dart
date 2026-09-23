/// The default dhikr and targets from the MVP 1 scope (SubhanAllah 33,
/// Alhamdulillah 33, Allahu Akbar 34). Names are localised in the ARB
/// files; custom dhikr lists are premium (unit 19).
enum Dhikr {
  subhanAllah(33),
  alhamdulillah(33),
  allahuAkbar(34);

  const Dhikr(this.target);

  final int target;
}

/// The "After prayer" set: all three in order.
const afterPrayerSet = Dhikr.values;
