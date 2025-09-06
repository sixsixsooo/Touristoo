import 'package:flutter/material.dart';

import '../../../../core/models/game_models.dart';
import '../../../../core/services/game_service.dart';

class SkinsSectionWidget extends StatelessWidget {
  final Function(String) onSkinPurchased;
  final Function(String) onSkinSelected;

  const SkinsSectionWidget({
    super.key,
    required this.onSkinPurchased,
    required this.onSkinSelected,
  });

  @override
  Widget build(BuildContext context) {
    final gameService = GameService();
    final skins = gameService.getAvailableSkins();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: skins.length,
        itemBuilder: (context, index) {
          final skin = skins[index];
          return _buildSkinCard(context, skin);
        },
      ),
    );
  }

  Widget _buildSkinCard(BuildContext context, Skin skin) {
    final isUnlocked = skin.isUnlocked;
    final canAfford = true; // This would check if player has enough coins
    
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          onSkinSelected(skin.id);
        } else if (canAfford) {
          onSkinPurchased(skin.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked 
              ? skin.rarity.color.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked 
                ? skin.rarity.color.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Skin Preview
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: skin.rarity.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: isUnlocked 
                      ? skin.rarity.color
                      : Colors.white.withOpacity(0.3),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Skin Name
            Text(
              skin.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Rarity Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: skin.rarity.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                skin.rarity.name.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: skin.rarity.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Price or Status
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'OWNED',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.blue,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${skin.price}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

extension SkinRarityExtension on SkinRarity {
  Color get color {
    switch (this) {
      case SkinRarity.common:
        return Colors.grey;
      case SkinRarity.rare:
        return Colors.blue;
      case SkinRarity.epic:
        return Colors.purple;
      case SkinRarity.legendary:
        return Colors.orange;
    }
  }
}
