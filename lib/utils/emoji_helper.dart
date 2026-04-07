String getEmoji(String name) {
  final n = name.toLowerCase().trim();

  if (n.contains('food') || n.contains('burger') || n.contains('pizza')) return '🍔';
  if (n.contains('transport') || n.contains('taxi') || n.contains('bus')) return '🚗';
  if (n.contains('shopping') || n.contains('shop')) return '🛍';
  if (n.contains('rent')) return '🏠';
  if (n.contains('health')) return '🏥';
  if (n.contains('entertainment')) return '🎮';
  if (n.contains('salary')) return '💰';
  if (n.contains('business')) return '🏢';
  if (n.contains('investment')) return '📈';
  if (n.contains('gift')) return '🎁';

  return '📦';
}