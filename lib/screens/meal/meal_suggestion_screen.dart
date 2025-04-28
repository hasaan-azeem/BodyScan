import 'package:flutter/material.dart';

class MealSuggestionsScreen extends StatelessWidget {
  const MealSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.restaurant, size: 28),
            SizedBox(width: 8),
            Text("Meal Suggestions"),
          ],
        ),
        backgroundColor: const Color(0xFFFFFAFB),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // High Protein Meals Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "🥩 High-Protein Meals",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: proteinMeals.length,
                itemBuilder: (context, index) {
                  return MealCard(meal: proteinMeals[index]);
                },
              ),
            ),
            // Foods to Avoid Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "🚫 Foods to Avoid",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: junkFoods.length,
              itemBuilder: (context, index) {
                return JunkFoodCard(junkFood: junkFoods[index]);
              },
            ),
            // Quick Nutrition Tips Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "💡 Quick Nutrition Tips",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              children:
                  nutritionTips
                      .map((tip) => NutritionTipCard(tip: tip))
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class MealCard extends StatelessWidget {
  final Meal meal;

  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8),
      elevation: 5,
      child: Column(
        children: [
          Image.asset(meal.image, width: 150, height: 120, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              meal.name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Text("${meal.proteinContent}g protein"),
        ],
      ),
    );
  }
}

class JunkFoodCard extends StatelessWidget {
  final JunkFood junkFood;

  const JunkFoodCard({super.key, required this.junkFood});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ListTile(
        leading: Icon(Icons.warning, color: Colors.red),
        title: Text(
          junkFood.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(junkFood.reason),
      ),
    );
  }
}

class NutritionTipCard extends StatelessWidget {
  final String tip;

  const NutritionTipCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(tip, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

class Meal {
  final String name;
  final String image;
  final int proteinContent;

  Meal({required this.name, required this.image, required this.proteinContent});
}

class JunkFood {
  final String name;
  final String reason;

  JunkFood({required this.name, required this.reason});
}

// Dummy Data for Meals and Foods
final List<Meal> proteinMeals = [
  Meal(
    name: "Grilled Chicken",
    image: "assets/meal/grilled_chicken.jpg",
    proteinContent: 35,
  ),
  Meal(
    name: "Boiled Eggs",
    image: "assets/meal/boiled_eggs.jpg",
    proteinContent: 13,
  ),
  Meal(
    name: "Greek Yogurt",
    image: "assets/meal/greek_yogurt.jpg",
    proteinContent: 17,
  ),
  Meal(
    name: "Tuna Salad",
    image: "assets/meal/tuna_salad.jpg",
    proteinContent: 25,
  ),
];

final List<JunkFood> junkFoods = [
  JunkFood(name: "Soft Drinks", reason: "High sugar content"),
  JunkFood(name: "Chips", reason: "High fat and salt"),
  JunkFood(name: "Fried Fast Foods", reason: "Too much trans fat"),
  JunkFood(name: "Candies", reason: "Empty calories"),
];

final List<String> nutritionTips = [
  "🥑 Healthy fats also important! (Avocado, nuts)",
  "💧 Stay hydrated: Drink 2–3L water daily",
  "💤 Sleep well to recover muscles",
];
