import 'package:flutter/material.dart';

class CoinPacksSectionWidget extends StatelessWidget {
  final Function(String, int) onPurchase;

  const CoinPacksSectionWidget({
    super.key,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final coinPacks = _getCoinPacks();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: coinPacks.length,
        itemBuilder: (context, index) {
          final pack = coinPacks[index];
          return _buildCoinPackCard(context, pack);
        },
      ),
    );
  }

  List<CoinPack> _getCoinPacks() {
    return [
      CoinPack(
        id: 'small',
        name: 'Small Pack',
        coins: 100,
        price: 99,
        bonus: 0,
        color: Colors.grey,
      ),
      CoinPack(
        id: 'medium',
        name: 'Medium Pack',
        coins: 500,
        price: 399,
        bonus: 50,
        color: Colors.blue,
      ),
      CoinPack(
        id: 'large',
        name: 'Large Pack',
        coins: 1200,
        price: 799,
        bonus: 200,
        color: Colors.purple,
      ),
      CoinPack(
        id: 'mega',
        name: 'Mega Pack',
        coins: 2500,
        price: 1499,
        bonus: 500,
        color: Colors.orange,
      ),
    ];
  }

  Widget _buildCoinPackCard(BuildContext context, CoinPack pack) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: pack.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: pack.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Pack Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: pack.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.monetization_on,
              color: pack.color,
              size: 30,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Pack Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pack.coins} Coins',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: pack.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (pack.bonus > 0)
                  Text(
                    '+ ${pack.bonus} Bonus',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          
          // Price and Buy Button
          Column(
            children: [
              Text(
                '₽${pack.price}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => onPurchase(pack.id, pack.price),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pack.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: Text(
                  'BUY',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CoinPack {
  final String id;
  final String name;
  final int coins;
  final int price;
  final int bonus;
  final Color color;

  const CoinPack({
    required this.id,
    required this.name,
    required this.coins,
    required this.price,
    required this.bonus,
    required this.color,
  });
}
