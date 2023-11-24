import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart' show rootBundle;

final courierPrime =
    GoogleFonts.courierPrime(textStyle: const TextStyle(fontSize: 20));

const colorHelp = Color.fromARGB(255, 139, 76, 175);
const colorOrange = Color.fromRGBO(255, 193, 70, 1);
const colorGray = Color.fromRGBO(84, 110, 122, 1);

Future<String> getVersion() async {
  return await rootBundle.loadString('VERSION');
}

final MaterialColor materialColorOrange = MaterialColor(
  colorOrange.value,
  const <int, Color>{
    50: Color.fromRGBO(255, 193, 70, 0.1),
    100: Color.fromRGBO(255, 193, 70, 0.2),
    200: Color.fromRGBO(255, 193, 70, 0.3),
    300: Color.fromRGBO(255, 193, 70, 0.4),
    400: Color.fromRGBO(255, 193, 70, 0.5),
    500: Color.fromRGBO(255, 193, 70, 0.6),
    600: Color.fromRGBO(255, 193, 70, 0.7),
    700: Color.fromRGBO(255, 193, 70, 0.8),
    800: Color.fromRGBO(255, 193, 70, 0.9),
    900: Color.fromRGBO(255, 193, 70, 1),
  },
);

const measurementTextHelp =
    "In this section you define the approximate measurements of your tossed pizza dough: diameter and thickness. At Pizzatarians we use a 12-inch diameter of regular thickness derived from a dough ball weighing around 275g. \nThis model has demonstrated optimal performance for portable ovens like Roccbox or Ooni. With a hydration level of 62-65%, it's perfect for creating individual neo-Neapolitan pizzas in a high-temperature oven.  \n\n - Adjust these values according to your preferences; \n - Any changes to these values will reflect in the ingredients and stats at the end of the page.";

const hydrationTextHelp =
    'In this section you define the amount of water and salt. Hydration is a crucial measurement of any dough recipe, low hydration doughs offer easier handling and shaping but may not rise as much in the oven, potentially drying up faster. High hydration doughs might be slightly challenging to handle but could deliver superior results.\n\n - Water quantity is computed in baker\'s percentage (BP), signifying the ratio of water weight to flour weight. For instance, 60% hydration means that for every 100g of flour, you need 60g of water; \n - Salt is measured as a concentration in water (g/L), referred to as salinity. Acting as a flavor enhancer and dough conditioner, it also helps regulate the fermentation process. Salt can neutralize your yeast, use cautiously; \n - At Pizzatarians we use 67% hydration and 30g/L for our mix; \n - Adjust these values according to your preferences; \n - Just like before, any alterations made here will be updated in the ingredients and stats at the end of the page.';

const fermentationTextHelp =
    'In this section you input your PUNTATA (bulk fermentation) strategy: at what temperature and for how long will the dough rest? These measurements are necessary to calculate the amount of yeast. Achieving top-notch taste and texture results demands patience with a slow fermentation process. During fermentation, yeast converts sugars into carbon dioxide gas, which causes the dough to rise. \nAt Pizzatarians we believe 24 hours of bulk fermentation is the acceptance threshold. \n\n - A cold environment like a refrigerator can significantly slow the yeast growth. It\'s very common to combine room temperature and refrigeration; \n - You should use an air-tight container to prevent surface crusting; \n - Folding and handling the dough at intervals encourages gluten mesh formation, see your recipe; \n - Lightly oil the container to prevent sticking; \n - Adjust these values according to your preferences; \n - Any changes to these values will reflect in the ingredients, timeline and stats at the end of the page.';

const String timelineTextHelp =
    "Here's a general timeline to help you through the process:\n\n"
    "1. IMPASTO (Mixing Ingredients)\n"
    "   The approach can greatly vary based on your recipe and technique. For a simple process, you activate the yeast (dissolve in a bit of lukewarm water), add half of the flour to the cold water, amalgamate and let it sit for 30 minutes. Add the yeast, gradually mix in half of the flour, add the salt and work the dough to the PUNTO di PASTA (when the desired consistency is reached, the mass is smooth and non sticky).\n\n"
    "2. PUNTATA (Bulk Fermentation)\n"
    "   Place the dough in a lightly oiled food grade airtight container. Account for a growth of two and half times the original size. Most procedures call for folding the dough a few times during the fermentation.\\nn"
    "3. STAGLIO (Cutting and Balling):\n"
    "   A clean and spacious surface is required. Dust one side lightly with flour to prevent sticking. Use a dough spatula to cut chunks of desired size and adjust the amount using a kitchen scale. Form the PANETTI (dough balls) and let them rest in a lightly floured CASSETTA (it's just a container).\n\n"
    "4. APPRETTO (Balled Fermentation):\n"
    "   Leave to rise in the CASSETTA between three and six hours before baking. Keep in a cool, dry area and ensure the dough is airtight. Investing in a proper dough tray with a lid is advisable.\n\n"
    "5. STESURA (Shaping):\n"
    "   This requires practice. Always prepare extra dough balls. Use the spatula to transfer the ball on a surface coated with flour, move it to a clean surface and quickly, but firmly start shaping it into a disk, pressing with eight flat fingers (not the tips) in a circular motion, without pulling. Pulling the dough increases the risk of thinning. When thinning happens, toppings can tear the bottom. Press evenly from the center to the edge, leaving a thicker border.\n\n"
    "6. COTTURA (Baking):\n"
    "   Ensure the oven is hot enough! Aim for 550C/1000F unless your recipe indicates otherwise. Use a wooden peel to slide the pizza into the oven. Rotate the side of the pizza away from the open flame as it begins to char.";

const String ingredientsTextHelp =
    "Here's a quick guide to your ingredients:\n\n"
    "- Flour: Opt for a high gluten content \"00\" (DOPPIO ZERO) wheat flour. If that's not available, bread flour works as a second-best choice.\n"
    "- Water: Filtered water is preferable to tap water, which may contain yeast-killing chlorine.\n"
    "- Salt: Use fine table salt rather than coarse.\n"
    "- Yeast: We use dry yeast in our recipes. For fresh yeast, multiply the quantity by three.";
